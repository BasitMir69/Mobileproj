/// Hardcoded demo professor account for testing professor features
///
/// These credentials can be used to sign in and test the professor dashboard
/// showing student appointments.

class HardcodedProfessor {
  static const String email = 'dr.ayesha.khan@lgs.edu.pk';
  static const String password = 'Professor@123';
  static const String name = 'Dr. Ayesha Khan';
  static const String department = 'Biology';
  static const String campus = 'LGS Gulberg Campus 2';
  static const String title = 'Associate Professor';
  static const String office = 'Bio Lab 1';

  /// This map can be used to pre-populate Firestore or for reference
  static Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'department': department,
        'campus': campus,
        'title': title,
        'office': office,
      };
}
