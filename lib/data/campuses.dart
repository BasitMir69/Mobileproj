// Campus data model and enriched static list.

class Campus {
  final String name;
  final String location;
  final String imageUrl; // remote fallback
  final String description; // short teaser
  final List<String> features; // bullet points
  final String history; // multi-paragraph history / profile
  final List<String> academicHighlights; // notable programs
  final List<String> facilityHighlights; // facility oriented notes
  final Map<String, String> photoCaptions; // assetPath -> caption

  const Campus({
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.features,
    required this.history,
    required this.academicHighlights,
    required this.facilityHighlights,
    required this.photoCaptions,
  });
}

// Helper to create photo caption map quickly.
Map<String, String> captions(List<MapEntry<String, String>> entries) =>
    {for (final e in entries) e.key: e.value};

final List<Campus> campuses = [
  const Campus(
    name: 'LGS 1A1',
    location: 'Sector 1A1, Lahore',
    imageUrl:
        'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=1a1',
    description:
        'Historic campus known for balanced academics, co-curricular excellence, and strong community values. Offers rich lab experiences and competitive sports.',
    features: [
      'Science & Computer Labs',
      'Sports Grounds',
      'Debate & MUN Clubs',
      'Auditorium',
    ],
    history:
        'Established as one of the early LGS branches, 1A1 nurtured a culture of academic curiosity and holistic development. The campus has hosted inter-school debates, science exhibitions, and community service initiatives. Over time, it expanded its lab infrastructure, digital resources, and sports coaching to support diverse student ambitions.',
    academicHighlights: [
      'Consistent board exam performance',
      'STEM fairs and lab immersion',
      'Active humanities & arts programs',
      'University placement guidance',
    ],
    facilityHighlights: [
      'Modernized labs and collaborative classrooms',
      'Multi-purpose auditorium for events',
      'Outdoor courts and training areas',
      'Library with quiet study corners',
    ],
    photoCaptions: const {
      'assets/Lgsgallerypics/1A1/1.jpg': 'Campus info overview',
      'assets/Lgsgallerypics/1A1/2.jpg': 'Main building',
      'assets/Lgsgallerypics/1A1/3.jpg': 'Campus entrance',
    },
  ),
  const Campus(
    name: 'LGS 42 B-III Gulberg',
    location: 'Gulberg, Lahore',
    imageUrl:
        'https://images.unsplash.com/photo-1524499982521-1ffd58dd89ea?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=gulbergb3',
    description:
        'Central Gulberg campus with vibrant academic culture, arts showcase, and accessible city connectivity. Emphasis on holistic development and alumni mentorship.',
    features: [
      'Studio & Activity Rooms',
      'STEM & Robotics Club',
      'Debate & Dramatics',
      'City-accessible transport links',
    ],
    history:
        'Located in Gulberg’s educational hub, 42 B-III built its reputation through strong inter-school representation in debates, dramatics, and science. The campus leverages its central location for partnerships, guest talks, and exposure trips, encouraging students to blend academic rigor with civic awareness.',
    academicHighlights: [
      'Competitive debating squads',
      'Community projects and city internships',
      'Interdisciplinary fairs',
      'Language & arts enrichment',
    ],
    facilityHighlights: [
      'Activity studios and performance spaces',
      'Dedicated maker corners',
      'Refreshed classrooms and seminar halls',
      'Reading lounge and resource center',
    ],
    photoCaptions: const {
      'assets/Lgsgallerypics/42 BIII gulberg/1.jpg': 'Gulberg campus view 1',
      'assets/Lgsgallerypics/42 BIII gulberg/2.jpg': 'Gulberg campus view 2',
      'assets/Lgsgallerypics/42 BIII gulberg/3.jpg': 'Gulberg campus view 3',
    },
  ),
  const Campus(
    name: 'LGS Gulberg Campus 2',
    location: 'Gulberg, Lahore',
    imageUrl:
        'https://images.unsplash.com/photo-1524499982521-1ffd58dd89ea?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=gulberg2',
    description:
        'Sibling Gulberg campus focusing on modern pedagogy, collaborative learning, and project-based assessments. Strong emphasis on research, writing, and presentations.',
    features: [
      'Project Labs',
      'Presentation & Media Rooms',
      'Peer Mentorship',
      'Sports & Wellness',
    ],
    history:
        'Gulberg Campus 2 complements the Gulberg academic ecosystem, experimenting with collaborative classrooms and cross-grade projects. Its faculty cultivates research-backed assignments, encouraging students to present, debate, and synthesize knowledge across disciplines.',
    academicHighlights: [
      'Project-based evaluation cycles',
      'Research & writing workshops',
      'Interdisciplinary showcases',
      'Mentor-led study circles',
    ],
    facilityHighlights: [
      'Flexible classrooms for group work',
      'Presentation studios and media equipment',
      'Play areas and fitness routines',
      'Library with curated periodicals',
    ],
    photoCaptions: const {
      'assets/Lgsgallerypics/Gulberg Campus 2/1.jpg':
          'Gulberg Campus 2 - view 1',
      'assets/Lgsgallerypics/Gulberg Campus 2/2.jpg':
          'Gulberg Campus 2 - view 2',
      'assets/Lgsgallerypics/Gulberg Campus 2/3.jpg':
          'Gulberg Campus 2 - view 3',
    },
  ),
  const Campus(
    name: 'LGS IB PHASE',
    location: 'DHA/Phase area, Lahore',
    imageUrl:
        'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=ib',
    description:
        'International Baccalaureate-focused stream with inquiry-driven learning, reflective thinking, and global-mindedness. Strong advisory and extended essay scaffolding.',
    features: [
      'IB labs & study rooms',
      'TOK seminars and CAS facilitation',
      'Extended Essay guidance',
      'University counseling',
    ],
    history:
        'IB Phase stream established to nurture globally aware learners through inquiry, reflection, and service. The program emphasizes academic honesty, research methodologies, and sustained mentorship—culminating in extended essays and CAS portfolios that reflect student passions and community impact.',
    academicHighlights: [
      'TOK colloquia and reflective journals',
      'EE workshops and supervisor meetings',
      'CAS project incubations',
      'Global university fairs',
    ],
    facilityHighlights: [
      'Seminar rooms optimized for discussion',
      'Lab spaces for IB sciences',
      'Silent study areas',
      'Counseling suite',
    ],
    photoCaptions: const {
      'assets/Lgsgallerypics/IB phase/1.jpg': 'IB Phase - view 1',
      'assets/Lgsgallerypics/IB phase/2.jpg': 'IB Phase - view 2',
      'assets/Lgsgallerypics/IB phase/3.jpg': 'IB Phase - view 3',
    },
  ),
  const Campus(
    name: 'LGS JT',
    location: 'Johar Town, Lahore',
    imageUrl:
        'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=jt',
    description:
        'Expansive campus with strong STEM programs, competitive sports, and inter-school event hosting. Known for science fairs and auditorium showcases.',
    features: [
      'Advanced Science Labs',
      'Auditorium & Events',
      'Sports Complex',
      'Debate & Robotics',
    ],
    history:
        'The Johar Town campus evolved into a flagship learning hub, integrating modern laboratories and multi-purpose venues. It regularly hosts inter-school debates, science fairs, and district-level sports meets while promoting mentorship for admissions and Olympiads.',
    academicHighlights: [
      'STEM olympiad participation',
      'Lab immersion tracks',
      'Admissions mentoring',
      'Math & coding clubs',
    ],
    facilityHighlights: [
      'Well-equipped labs and makerspaces',
      'Auditorium with AV facilities',
      'Courts and training fields',
      'Reading zones and library carrels',
    ],
    photoCaptions: const {
      'assets/Lgsgallerypics/JT/1.jpg': 'Johar Town - view 1',
      'assets/Lgsgallerypics/JT/2.jpg': 'Johar Town - view 2',
      'assets/Lgsgallerypics/JT/3.jpg': 'Johar Town - view 3',
    },
  ),
  const Campus(
    name: 'LGS PARAGON',
    location: 'Paragon City, Lahore',
    imageUrl:
        'https://images.unsplash.com/photo-1510936111840-6a8d2f1a5a1b?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=paragon',
    description:
        'Growing campus emphasizing balanced academics, extracurriculars, and community engagement. Focus on student leadership and skill-building clubs.',
    features: [
      'Science & IT Labs',
      'Sports & Fitness',
      'Leadership & Service Clubs',
      'Art & Culture Societies',
    ],
    history:
        'Paragon campus has steadily expanded facilities and academic programming, encouraging student leadership through clubs and service. With regular inter-house events, it cultivates teamwork, creativity, and civic responsibility among students.',
    academicHighlights: [
      'STEAM showcases',
      'Inter-house competitions',
      'Counseling and mentorship',
      'Reading & writing labs',
    ],
    facilityHighlights: [
      'Refreshed classrooms and labs',
      'Play courts and fitness routines',
      'Art studios and activity rooms',
      'Library collections and study spaces',
    ],
    photoCaptions: const {
      'assets/Lgsgallerypics/Paragon/1.jpg': 'Paragon - view 1',
      'assets/Lgsgallerypics/Paragon/2.jpg': 'Paragon - view 2',
      'assets/Lgsgallerypics/Paragon/3.jpg': 'Paragon - view 3',
    },
  ),
];
