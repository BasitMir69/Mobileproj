class AdmissionForm {
  final int? id;
  final String parentName;
  final String parentEmail;
  final String phone;
  final String childName;
  final String childDob; // ISO string for simplicity
  final String gradeApplying; // e.g., "Grade 1"
  final String campus; // campus name
  final String notes; // optional
  final String gender; // Male/Female/Other
  final String? documentPath; // CNIC/B-Form image stored locally
  final String status; // pending, approved, rejected
  final String? testDate; // optional test/interview date when approved

  const AdmissionForm({
    this.id,
    required this.parentName,
    required this.parentEmail,
    required this.phone,
    required this.childName,
    required this.childDob,
    required this.gradeApplying,
    required this.campus,
    required this.notes,
    required this.gender,
    this.documentPath,
    this.status = 'pending',
    this.testDate,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'parentName': parentName,
        'parentEmail': parentEmail,
        'phone': phone,
        'childName': childName,
        'childDob': childDob,
        'gradeApplying': gradeApplying,
        'campus': campus,
        'notes': notes,
        'gender': gender,
        'documentPath': documentPath,
        'status': status,
        'testDate': testDate,
      };

  static AdmissionForm fromMap(Map<String, Object?> map) => AdmissionForm(
        id: map['id'] as int?,
        parentName: (map['parentName'] ?? '') as String,
        parentEmail: (map['parentEmail'] ?? '') as String,
        phone: (map['phone'] ?? '') as String,
        childName: (map['childName'] ?? '') as String,
        childDob: (map['childDob'] ?? '') as String,
        gradeApplying: (map['gradeApplying'] ?? '') as String,
        campus: (map['campus'] ?? '') as String,
        notes: (map['notes'] ?? '') as String,
        gender: (map['gender'] ?? '') as String,
        documentPath: map['documentPath'] as String?,
        status: (map['status'] ?? 'pending') as String,
        testDate: map['testDate'] as String?,
      );
}
