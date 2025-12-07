import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an appointment slot created/managed by a teacher
class TeacherAppointment {
  final String id;
  final String teacherId; // Firebase UID of the teacher who created it
  final String teacherName;
  final String department;
  final String campus;
  final String location;
  final DateTime appointmentDateTime;
  final String dayOfWeek; // e.g., 'Monday', 'Tuesday'
  final String timeSlot; // e.g., '10:00 AM - 11:00 AM'
  final int durationMinutes;
  final String subject;
  final String description;
  final String status; // 'available', 'booked', 'cancelled'
  final List<String> bookedByStudents; // List of student UIDs who booked this
  final DateTime createdAt;
  final DateTime? updatedAt;

  TeacherAppointment({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.department,
    required this.campus,
    required this.location,
    required this.appointmentDateTime,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.durationMinutes,
    required this.subject,
    required this.description,
    required this.status,
    required this.bookedByStudents,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert Firestore document to TeacherAppointment object
  factory TeacherAppointment.fromMap(
    Map<String, dynamic> data,
    String docId,
  ) {
    return TeacherAppointment(
      id: docId,
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      department: data['department'] ?? '',
      campus: data['campus'] ?? '',
      location: data['location'] ?? '',
      appointmentDateTime: (data['appointmentDateTime'] as Timestamp).toDate(),
      dayOfWeek: data['dayOfWeek'] ?? '',
      timeSlot: data['timeSlot'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 60,
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'available',
      bookedByStudents: List<String>.from(data['bookedByStudents'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert TeacherAppointment to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
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
      'status': status,
      'bookedByStudents': bookedByStudents,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create a copy with modified fields
  TeacherAppointment copyWith({
    String? id,
    String? teacherId,
    String? teacherName,
    String? department,
    String? campus,
    String? location,
    DateTime? appointmentDateTime,
    String? dayOfWeek,
    String? timeSlot,
    int? durationMinutes,
    String? subject,
    String? description,
    String? status,
    List<String>? bookedByStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherAppointment(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      department: department ?? this.department,
      campus: campus ?? this.campus,
      location: location ?? this.location,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      timeSlot: timeSlot ?? this.timeSlot,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      bookedByStudents: bookedByStudents ?? this.bookedByStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
