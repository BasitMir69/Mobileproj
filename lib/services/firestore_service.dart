import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Central service for Firestore operations: appointments, users, professors
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  static CollectionReference get _appointments =>
      _db.collection('appointmentID');
  static CollectionReference get _users => _db.collection('users');
  static CollectionReference get _professors => _db.collection('professors');
  static CollectionReference get _teacherAppointments =>
      _db.collection('teacherAppointments');
  static CollectionReference get _campusNews => _db.collection('campus_news');
  static CollectionReference get _campusInfo => _db.collection('campus_info');

  /// Create a new appointment booking (student → professor)
  /// Returns the new document ID

  // Campus News CRUD
  static Future<String> createCampusNews({
    required String title,
    required String content,
    required String campus,
    required String authorId,
    bool published = false,
  }) async {
    final doc = await _campusNews.add({
      'title': title,
      'content': content,
      'campus': campus,
      'authorId': authorId,
      'published': published,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Campus Info (real-time editable text by admin)
  static Stream<DocumentSnapshot> streamCampusInfo(String campusSlug) {
    return _campusInfo.doc(campusSlug).snapshots();
  }

  static Future<void> updateCampusInfo({
    required String campusSlug,
    String? overview,
    String? history,
    String? about,
  }) async {
    final data = <String, dynamic>{
      if (overview != null) 'overview': overview,
      if (history != null) 'history': history,
      if (about != null) 'about': about,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _campusInfo.doc(campusSlug).set(data, SetOptions(merge: true));
  }

  static Future<void> updateCampusNews({
    required String id,
    String? title,
    String? content,
    String? campus,
    bool? published,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (campus != null) data['campus'] = campus;
    if (published != null) data['published'] = published;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _campusNews.doc(id).update(data);
  }

  static Future<void> deleteCampusNews(String id) async {
    await _campusNews.doc(id).delete();
  }

  static Stream<QuerySnapshot> streamCampusNews(
      {String? campus, bool? published, int? limit}) {
    Query q = _campusNews.orderBy('createdAt', descending: true);
    if (campus != null) q = q.where('campus', isEqualTo: campus);
    if (published != null) q = q.where('published', isEqualTo: published);
    if (limit != null) q = q.limit(limit);
    return q.snapshots();
  }

  static Stream<QuerySnapshot> streamPublishedCampusNews({int limit = 50}) {
    return _campusNews
        .where('published', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  static Future<String> createAppointment({
    required String professorId,
    required String campus,
    required String location,
    required String requestedSlot,
    String? studentId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = studentId ?? user?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final doc = await _appointments.add({
      'ProffessorID': professorId,
      'campus': campus,
      'location': location,
      'reminderSent': false,
      'requestedSlot': requestedSlot,
      'studentID': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', // optional: pending/confirmed/cancelled
    });
    return doc.id;
  }

  /// Fetch all appointments for the current user (student perspective)
  /// Uses client-side filtering to avoid needing composite index
  static Stream<List<Map<String, dynamic>>> streamUserAppointments(
      String userId) {
    return _appointments
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      // Filter client-side to avoid needing composite index
      return snap.docs
          .where((doc) => doc['studentID'] == userId)
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    });
  }

  /// Fetch all appointments for a specific professor
  /// Uses a simpler query that doesn't require a composite index
  static Stream<List<Map<String, dynamic>>> streamProfessorAppointments(
      String professorId) {
    return _appointments
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      // Filter client-side to avoid needing composite index
      return snap.docs
          .where((doc) => doc['ProffessorID'] == professorId)
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    });
  }

  /// Delete an appointment by ID
  static Future<void> deleteAppointment(String appointmentId) async {
    await _appointments.doc(appointmentId).delete();
  }

  /// Update appointment reminder flag
  static Future<void> markReminderSent(String appointmentId) async {
    await _appointments.doc(appointmentId).update({'reminderSent': true});
  }

  /// Update appointment status (for professor approval/rejection)
  static Future<void> updateAppointmentStatus(
    String appointmentId,
    String status, {
    String? professorNotes,
  }) async {
    final updateData = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (professorNotes != null) {
      updateData['professorNotes'] = professorNotes;
    }
    await _appointments.doc(appointmentId).update(updateData);
  }

  /// Clear all appointments (for professors to reset their bookings)
  static Future<void> clearAllAppointments() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    // Get professor doc to find appointments
    final prof = await getProfessorByUserId(uid);
    if (prof != null) {
      final professorId = prof['id'] as String;
      // Delete all appointments for this professor
      final snap = await _appointments
          .where('ProffessorID', isEqualTo: professorId)
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }
  }

  /// Submit admission form to Firestore
  static Future<String> submitAdmission({
    required String childName,
    required String parentName,
    required String parentEmail,
    required String phone,
    required String campus,
    required String gradeApplying,
    required String childDob,
    required String gender,
    String? notes,
    String? imageBase64,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _db.collection('admission_submissions').add({
      'studentID': user.uid,
      'childName': childName,
      'parentName': parentName,
      'parentEmail': parentEmail,
      'phone': phone,
      'campus': campus,
      'gradeApplying': gradeApplying,
      'childDob': childDob,
      'gender': gender,
      'notes': notes ?? '',
      'imageBase64': imageBase64,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Stream student's admission submissions
  static Stream<QuerySnapshot> streamStudentAdmissions(String studentId) {
    return _db
        .collection('admission_submissions')
        .where('studentID', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get user profile document
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return doc.data() as Map<String, dynamic>?;
  }

  /// Update or create user profile (called after signup or profile edit)
  static Future<void> setUserProfile({
    required String userId,
    required String displayName,
    required String email,
    String role = 'student',
  }) async {
    debugPrint('📝 Saving user profile to Firestore...');
    debugPrint('   userId: $userId');
    debugPrint('   displayName: $displayName');
    debugPrint('   email: $email');
    debugPrint('   role: $role');

    await _users.doc(userId).set({
      'displayName': displayName,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('✅ User profile saved successfully');
  }

  /// Get professor details by userID
  static Future<Map<String, dynamic>?> getProfessorByUserId(
      String userId) async {
    // Primary lookup: by userID field
    final snap = await _professors.where('userID', isEqualTo: userId).get();

    // If we found a doc, prefer the hardcoded demo_professor if it matches
    if (snap.docs.isNotEmpty) {
      final first = snap.docs.first;

      // Check if demo_professor exists and belongs to this user
      final demoDoc = await _professors.doc('demo_professor').get();
      if (demoDoc.exists) {
        final demoData = demoDoc.data() as Map<String, dynamic>;
        if (demoData['userID'] == userId) {
          return {'id': demoDoc.id, ...demoData};
        }
      }

      // Otherwise return the first match
      return {'id': first.id, ...first.data() as Map<String, dynamic>};
    }

    // Fallback: demo professor document
    final demoDoc = await _professors.doc('demo_professor').get();
    if (!demoDoc.exists) return null;

    final data = demoDoc.data() as Map<String, dynamic>;

    // If demo doc missing userID, link it to this user
    if (data['userID'] == null) {
      await _professors.doc('demo_professor').set({
        'userID': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      data['userID'] = userId;
    }

    return {'id': demoDoc.id, ...data};
  }

  /// Get professor details by document ID
  static Future<Map<String, dynamic>?> getProfessorById(
      String professorId) async {
    final doc = await _professors.doc(professorId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
  }

  /// Fetch all professors (optionally filter by campus)
  static Stream<List<Map<String, dynamic>>> streamProfessors({String? campus}) {
    Query query = _professors;
    if (campus != null && campus.isNotEmpty) {
      query = query.where('Campus', isEqualTo: campus);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList());
  }

  /// Create or update professor profile with a specific document ID
  /// This is used for the demo professor to match the static professor ID
  static Future<void> setProfessorProfileWithId({
    required String docId,
    required String userId,
    required String name,
    required String campus,
    required String department,
    String title = 'Sir',
  }) async {
    await _professors.doc(docId).set({
      'userID': userId,
      'name': name,
      'Campus': campus,
      'Department': department,
      'Title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Create or update professor profile
  static Future<void> setProfessorProfile({
    required String userId,
    required String name,
    required String campus,
    required String department,
    String title = 'Sir',
  }) async {
    // Check if professor doc already exists for this user
    final existing = await getProfessorByUserId(userId);
    if (existing != null) {
      await _professors.doc(existing['id']).update({
        'name': name,
        'Campus': campus,
        'Department': department,
        'Title': title,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _professors.add({
        'userID': userId,
        'name': name,
        'Campus': campus,
        'Department': department,
        'Title': title,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Bulk import professors from static data (one-time sync)
  static Future<void> importProfessorsFromStatic(
    List<Map<String, dynamic>> professorsList,
  ) async {
    final batch = _db.batch();
    for (final prof in professorsList) {
      final docRef = _professors.doc(); // Auto-generate ID
      batch.set(docRef, {
        'userID': prof['id'] ?? docRef.id, // Use prof ID as userID fallback
        'name': prof['name'] ?? '',
        'Title': prof['title'] ?? 'Sir',
        'Campus': prof['campus'] ?? '',
        'Department': prof['department'] ?? '',
        'bio': prof['bio'] ?? '',
        'office': prof['office'] ?? '',
        'photoURL': prof['photoUrl'] ?? '',
        'availableSlots': prof['availableSlots'] ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': true,
      });
    }
    await batch.commit();
  }

  // ==================== TEACHER APPOINTMENT METHODS ====================
  // Separate collection for teacher-uploaded appointments (independent system)

  /// Create a new appointment uploaded by a teacher
  /// Returns the new document ID
  static Future<String> createTeacherAppointment({
    required String teacherId,
    required String teacherName,
    required String department,
    required String campus,
    required String location,
    required DateTime appointmentDateTime,
    required String dayOfWeek,
    required String timeSlot,
    required int durationMinutes,
    required String subject,
    required String description,
  }) async {
    final doc = await _teacherAppointments.add({
      'teacherId': teacherId,
      'teacherName': teacherName,
      'department': department,
      'campus': campus,
      'location': location,
      'appointmentDateTime': Timestamp.fromDate(appointmentDateTime),
      'dayOfWeek': dayOfWeek,
      'timeSlot': timeSlot,
      'durationMinutes': durationMinutes,
      'subject': subject,
      'description': description,
      'status': 'available',
      'bookedByStudents': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Get all appointments created by a teacher
  static Stream<List<Map<String, dynamic>>> streamTeacherAppointments(
      String teacherId) {
    return _teacherAppointments
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('appointmentDateTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
  }

  /// Get all available appointments (for students to browse)
  static Stream<List<Map<String, dynamic>>> streamAllTeacherAppointments({
    String? campus,
    String? department,
  }) {
    Query query = _teacherAppointments.where('status', isEqualTo: 'available');

    if (campus != null && campus.isNotEmpty) {
      query = query.where('campus', isEqualTo: campus);
    }
    if (department != null && department.isNotEmpty) {
      query = query.where('department', isEqualTo: department);
    }

    return query
        .orderBy('appointmentDateTime', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
  }

  /// Update a teacher appointment (time, subject, description, etc.)
  static Future<void> updateTeacherAppointment(
    String appointmentId,
    Map<String, dynamic> updates,
  ) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _teacherAppointments.doc(appointmentId).update(updates);
  }

  /// Delete a teacher appointment
  static Future<void> deleteTeacherAppointment(String appointmentId) async {
    await _teacherAppointments.doc(appointmentId).delete();
  }

  /// Student books a teacher appointment
  static Future<void> bookTeacherAppointment(
    String appointmentId,
    String studentId,
  ) async {
    await _teacherAppointments.doc(appointmentId).update({
      'bookedByStudents': FieldValue.arrayUnion([studentId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Student cancels booking on a teacher appointment
  static Future<void> cancelTeacherAppointmentBooking(
    String appointmentId,
    String studentId,
  ) async {
    await _teacherAppointments.doc(appointmentId).update({
      'bookedByStudents': FieldValue.arrayRemove([studentId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get single teacher appointment by ID
  static Future<Map<String, dynamic>?> getTeacherAppointment(
      String appointmentId) async {
    final doc = await _teacherAppointments.doc(appointmentId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
  }

  /// Check if student already booked this teacher appointment
  static Future<bool> isStudentBookedTeacherAppointment(
    String appointmentId,
    String studentId,
  ) async {
    final doc = await getTeacherAppointment(appointmentId);
    if (doc == null) return false;
    final bookedByStudents = List<String>.from(doc['bookedByStudents'] ?? []);
    return bookedByStudents.contains(studentId);
  }
}
