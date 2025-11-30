class Professor {
  final String id;
  final String name;
  final String title;
  final String department;
  final String photoUrl;
  final String office;
  final String bio;
  final List<String> availableSlots; // ISO strings or readable labels

  const Professor({
    required this.id,
    required this.name,
    required this.title,
    required this.department,
    required this.photoUrl,
    required this.office,
    required this.bio,
    required this.availableSlots,
  });
}

// Note: Extended professor info (skills, achievements) is provided via
// ProfessorExtended in data/campus_professors.dart to keep base model small.
