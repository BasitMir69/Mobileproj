class SimpleProfessor {
  final String name;
  final String department;
  final String campus;
  const SimpleProfessor({
    required this.name,
    required this.department,
    required this.campus,
  });
}

const sampleProfessors = <SimpleProfessor>[
  SimpleProfessor(
      name: 'Dr. Ahmed Khan',
      department: 'Computer Science',
      campus: 'LGS Johar Town'),
  SimpleProfessor(
      name: 'Prof. Riffat Ali',
      department: 'Physics',
      campus: 'LGS 42B Gulberg III'),
  SimpleProfessor(
      name: 'Dr. Sana Malik', department: 'Mathematics', campus: 'LGS Paragon'),
  SimpleProfessor(
      name: 'Prof. Bilal Hussain',
      department: 'Chemistry',
      campus: 'LGS Gulberg Campus 2'),
];
