import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_wave/services/firestore_service.dart';
import 'package:campus_wave/data/campuses.dart';

class ChatbotIntentResult {
  final String type; // 'book' | 'cancel' | 'status' | 'campus_info' | 'unknown'
  final String? professorId;
  final String? slot;
  final String? campus;
  final String? location;
  final String? appointmentId;
  final String? campusQuery;
  final String? feature; // for navigation requests like "open news"
  ChatbotIntentResult({
    required this.type,
    this.professorId,
    this.slot,
    this.campus,
    this.location,
    this.appointmentId,
    this.campusQuery,
    this.feature,
  });
}

class ChatbotIntents {
  static Future<List<Map<String, String>>> listProfessorCandidates(
      String nameLike,
      {int limit = 10}) async {
    final t = nameLike.trim().toLowerCase();
    final snap = await FirebaseFirestore.instance
        .collection('professors')
        .limit(100)
        .get();
    final results = <Map<String, String>>[];
    for (final d in snap.docs) {
      final data = d.data();
      final name = (data['name'] ?? '').toString();
      if (name.toLowerCase().contains(t)) {
        results.add({'id': d.id, 'name': name});
        if (results.length >= limit) break;
      }
    }
    return results;
  }

  static Future<String?> _lookupProfessorIdByName(String nameLike) async {
    final t = nameLike.trim().toLowerCase();
    final snap = await FirebaseFirestore.instance
        .collection('professors')
        .limit(50)
        .get();
    for (final d in snap.docs) {
      final data = d.data();
      final name = (data['name'] ?? '').toString().toLowerCase();
      if (name.contains(t)) return d.id;
    }
    return null;
  }

  static ChatbotIntentResult detect(String text) {
    final t = text.toLowerCase();
    // Simple keyword-based detection
    if (t.contains('cancel') && t.contains('appointment') ||
        t.contains('cancel booking')) {
      return ChatbotIntentResult(type: 'cancel');
    }
    // Help / features overview
    if (t.contains('help') ||
        t.contains('features') ||
        t.contains('what can you do')) {
      return ChatbotIntentResult(type: 'help');
    }
    // Open feature navigation (handled in UI)
    if (t.startsWith('open ') ||
        t.startsWith('go to ') ||
        t.contains('navigate to')) {
      final m =
          RegExp(r'(open|go to|navigate to)\s+([a-z\s]+)', caseSensitive: false)
              .firstMatch(t);
      final feat = m != null ? m.group(2)?.trim() : null;
      return ChatbotIntentResult(type: 'open_feature', feature: feat);
    }
    // Campus info queries, e.g., "tell me about LGS 1A1"
    if (t.contains('tell me about') ||
        t.contains('about this campus') ||
        t.contains('campus info') ||
        t.contains('about lgs')) {
      // Try to extract a likely campus token after the word 'about'
      String? cq;
      final aboutIdx = t.indexOf('about');
      if (aboutIdx >= 0) {
        final after = t.substring(aboutIdx + 5).trim();
        // capture from first 'lgs' if present, otherwise take the trailing words
        final lgsIdx = after.indexOf('lgs');
        cq = (lgsIdx >= 0 ? after.substring(lgsIdx) : after).trim();
      }
      return ChatbotIntentResult(type: 'campus_info', campusQuery: cq);
    }
    if (t.contains('book') ||
        t.contains('schedule') ||
        t.contains('make a booking')) {
      // Extract professor name token, allow spaces and dots (e.g., "Dr Ayesha Khan")
      final m =
          RegExp(r'(professor|dr)\s+([a-z][a-z\s\.\-]+)', caseSensitive: false)
              .firstMatch(t);
      final profToken = m != null ? m.group(2)?.trim() : null;
      return ChatbotIntentResult(type: 'book', professorId: profToken);
    }
    if (t.contains('next appointment') ||
        t.contains('my appointments') ||
        t.contains('view bookings')) {
      return ChatbotIntentResult(type: 'status');
    }
    return ChatbotIntentResult(type: 'unknown');
  }

  static Future<String> perform(ChatbotIntentResult intent) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Please log in to use booking features.';

    // Load role from users/{uid}
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final role = (snap.data()?['role'] ?? 'student') as String;

    switch (intent.type) {
      case 'campus_info':
        try {
          final raw = (intent.campusQuery ?? intent.campus ?? '').trim();
          String norm(String s) => s
              .toLowerCase()
              .replaceAll(RegExp(r"[^a-z0-9 ]"), ' ')
              .replaceAll(RegExp(r"\s+"), ' ')
              .trim();

          final nq = norm(raw);
          Campus? found;
          // 1) Exact/contains match against known campus names
          for (final c in campuses) {
            final nn = norm(c.name);
            if (nq.isEmpty) {
              found = c;
              break;
            }
            if (nn.contains(nq) || nq.contains(nn)) {
              found = c;
              break;
            }
          }

          // 2) Synonym-based mapping if not found
          if (found == null) {
            final synonyms = <String, Campus>{
              'lgs 1a1': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('1a1'),
                  orElse: () => campuses.first),
              '1a1': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('1a1'),
                  orElse: () => campuses.first),
              'lgs 42 b iii gulberg': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('42 b-iii'),
                  orElse: () => campuses.first),
              '42 b iii': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('42 b-iii'),
                  orElse: () => campuses.first),
              '42b': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('42 b-iii'),
                  orElse: () => campuses.first),
              'gulberg campus 2': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('gulberg campus 2'),
                  orElse: () => campuses.first),
              'ib phase': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('ib phase'),
                  orElse: () => campuses.first),
              'jt': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('jt'),
                  orElse: () => campuses.first),
              'johar town': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('jt'),
                  orElse: () => campuses.first),
              'paragon': campuses.firstWhere(
                  (c) => c.name.toLowerCase().contains('paragon'),
                  orElse: () => campuses.first),
            };
            for (final entry in synonyms.entries) {
              if (nq.contains(entry.key)) {
                found = entry.value;
                break;
              }
            }
          }

          // 3) Fallback to Firestore collection if provided by admin
          String? fsDetails;
          try {
            final snap = await FirebaseFirestore.instance
                .collection('campus_info')
                .limit(50)
                .get();
            Map<String, dynamic>? match;
            for (final d in snap.docs) {
              final data = d.data();
              final name = (data['name'] ?? '').toString();
              if (name.isEmpty) continue;
              if (nq.isNotEmpty && norm(name).contains(nq)) {
                match = data;
                break;
              }
            }
            if (match != null) {
              final cname = (match['name'] ?? 'Campus').toString();
              final desc = (match['description'] ?? 'No description available')
                  .toString();
              final address = (match['address'] ?? '').toString();
              final phone = (match['phone'] ?? '').toString();
              final hours = (match['hours'] ?? '').toString();
              fsDetails = [
                cname,
                desc,
                if (address.isNotEmpty) 'Address: $address',
                if (phone.isNotEmpty) 'Phone: $phone',
                if (hours.isNotEmpty) 'Hours: $hours',
              ].join('\n');
            }
          } catch (_) {
            // ignore Firestore errors for this optional source
          }

          if (fsDetails != null) {
            final actions =
                '\n\nYou can:\n- Type "book admission" to start an admission booking\n- Type "book with Dr <name>" to schedule with a professor';
            return '$fsDetails$actions';
          }

          if (found == null) {
            return 'I could not find that campus. Try e.g., "LGS 1A1" or "Gulberg Campus 2".';
          }

          // Build answer from local dataset
          final c = found;
          final details = [
            c.name,
            c.description,
          ].join('\n');
          final actions =
              '\n\nYou can:\n- Type "book admission" to start an admission booking\n- Type "book with Dr <name>" to schedule with a professor';
          return '$details$actions';
        } catch (e) {
          return 'Could not load campus info: ${e.toString()}';
        }

      case 'book':
        if (role != 'student') {
          return 'Only student accounts can create bookings.';
        }
        if (intent.professorId == null) {
          return 'Which professor would you like to book? Please say, for example: book with Dr Khan tomorrow 3pm.';
        }
        // If a name token was provided, resolve to an actual professor ID
        String professorId = intent.professorId!;
        if (!RegExp(r'^[a-z0-9_\-]{6,}$').hasMatch(professorId)) {
          final resolved = await _lookupProfessorIdByName(professorId);
          if (resolved == null) {
            return 'I could not find that professor. Please try exact name, e.g., book with Dr Ayesha.';
          }
          professorId = resolved;
        }
        final slot = intent.slot ?? 'TBD';
        final campus = intent.campus ?? 'Main Campus';
        final location = intent.location ?? 'Admin Block';
        try {
          final id = await FirestoreService.createAppointment(
            professorId: professorId,
            campus: campus,
            location: location,
            requestedSlot: slot,
          );
          return 'Booking request created (pending). Reference: $id';
        } catch (e) {
          return 'Booking failed: ${e.toString()}';
        }

      case 'cancel':
        if (role != 'student') {
          return 'Only student accounts can cancel their own bookings.';
        }
        // Fetch latest pending/confirmed appointment for user and cancel it
        try {
          final apps = await FirebaseFirestore.instance
              .collection('appointmentID')
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();
          if (apps.docs.isEmpty)
            return 'No recent appointments found to cancel.';
          final doc = apps.docs.first;
          final data = doc.data();
          if (data['studentID'] != user.uid) {
            return 'No appointments you own were found to cancel.';
          }
          final status = (data['status'] ?? 'pending') as String;
          if (status == 'rejected' || status == 'cancelled') {
            return 'The latest appointment is already ${status}.';
          }
          await FirestoreService.updateAppointmentStatus(doc.id, 'cancelled');
          return 'Your latest appointment has been cancelled.';
        } catch (e) {
          return 'Cancel failed: ${e.toString()}';
        }

      case 'status':
        try {
          final snap = await FirebaseFirestore.instance
              .collection('appointmentID')
              .where('studentID', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .limit(3)
              .get();
          if (snap.docs.isEmpty) return 'You have no bookings.';
          final items = snap.docs.map((d) => d.data()).toList();
          final lines = items
              .map((a) =>
                  '${a['ProffessorID'] ?? 'Professor'} • ${a['status'] ?? 'pending'} • ${a['requestedSlot'] ?? ''}')
              .join('\n');
          return 'Your recent bookings:\n$lines';
        } catch (e) {
          return 'Could not retrieve bookings: ${e.toString()}';
        }

      default:
        return 'I can help with: \n- campus info (e.g., "tell me about LGS 1A1")\n- bookings ("book with Dr <name>")\n- cancel booking\n- view bookings\n- open features (e.g., "open campus news", "open settings").';
    }
  }
}
