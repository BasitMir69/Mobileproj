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

const String _lgsOverview =
    'Lahore Grammar School (LGS) was established in 1979 by a group of women aiming to provide quality education. It began as a girls’ school and later expanded to include boys, O/A Levels (Cambridge / GCE), and many branches across Lahore and other major cities in Pakistan. LGS emphasizes holistic development—balancing academic excellence (Cambridge curriculum, Matric, O/A Levels) with co-curriculars such as debating, environmental initiatives, community service, clubs, trips, and more. The Gulberg network alone cites 200+ teachers and 2,500+ students across campuses, reflecting the system’s scale and resources.';

final List<Campus> campuses = [
  const Campus(
    name: 'LGS 1A1',
    location: '1-A/1 Ghalib Market, Gulberg III, Lahore',
    imageUrl:
        'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=1a1',
    description:
        'Mainstream LGS branch in Gulberg III with quality academics (Matric / O & A Levels), English‑medium instruction, and active co‑curriculars. Emphasizes small‑to‑medium class sizes and balanced development. Offers rich lab experiences, competitive sports, and a supportive advisory system. Official: lahoregrammar.school',
    features: [
      'Science & Computer Labs',
      'Sports Grounds',
      'Debate & MUN Clubs',
      'Auditorium',
      'English‑medium instruction',
      'Small‑to‑medium class sizes',
      'Balanced academics + co‑curriculars',
    ],
    history:
        '$_lgsOverview\n\nEstablished as one of the early LGS branches, 1A1 nurtured a culture of academic curiosity and holistic development. As part of LGS’s mainstream branch network, 1A1 serves both girls and boys and aligns with the system’s English‑medium, co‑curricular model. The campus has hosted inter‑school debates, science exhibitions, and community service initiatives. Over time, it expanded its lab infrastructure, digital resources, and sports coaching to support diverse student ambitions. In recent years, 1A1 has strengthened alumni engagement and study skills bootcamps, helping learners develop research habits and presentation confidence.',
    academicHighlights: [
      'Consistent board exam performance',
      'STEM fairs and lab immersion',
      'Active humanities & arts programs',
      'University placement guidance',
      'Inter-school debate & science exhibition hosts',
      'Alumni study skills bootcamps and mentorship',
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
        'Central Gulberg campus with vibrant academic culture, arts showcase, and accessible city connectivity. Emphasis on holistic development, student-led events, and alumni mentorship that connects learners with real-world perspectives.',
    features: [
      'Studio & Activity Rooms',
      'STEM & Robotics Club',
      'Debate & Dramatics',
      'City-accessible transport links',
    ],
    history:
        '$_lgsOverview\n\nLocated in Gulberg’s educational hub, 42 B-III built its reputation through strong inter-school representation in debates, dramatics, and science. The campus leverages its central location for partnerships, guest talks, and exposure trips, encouraging students to blend academic rigor with civic awareness. Student councils regularly organize city outreach, art festivals, and themed research fairs that promote interdisciplinary learning.',
    academicHighlights: [
      'Competitive debating squads',
      'Community projects and city internships',
      'Interdisciplinary fairs',
      'Language & arts enrichment',
      'City outreach and guest talk series',
      'Art festivals and themed research fairs',
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
        'Purpose‑built Gulberg campus focusing on modern pedagogy, collaborative learning, and project‑based assessments. As part of the Gulberg network (200+ teachers, 2,500+ students), Campus 2 shares in holistic development across academics, co‑curriculars, and personal growth. Strong emphasis on research, writing, and presentations with faculty‑led feedback cycles and showcase days.',
    features: [
      'Project Labs',
      'Presentation & Media Rooms',
      'Peer Mentorship',
      'Sports & Wellness',
    ],
    history:
        '$_lgsOverview\n\nGulberg Campus 2 complements the Gulberg academic ecosystem, experimenting with collaborative classrooms and cross-grade projects. Its faculty cultivates research-backed assignments, encouraging students to present, debate, and synthesize knowledge across disciplines. The campus emphasizes reflective journals, peer review, and public speaking practice to build communication fluency.',
    academicHighlights: [
      'Project-based evaluation cycles',
      'Research & writing workshops',
      'Interdisciplinary showcases',
      'Mentor-led study circles',
      'Showcase days for cross-grade projects',
      'Peer review and public speaking practice',
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
        'International Baccalaureate-focused stream with inquiry-driven learning, reflective thinking, and global-mindedness. Strong advisory and extended essay scaffolding with regular supervisor check-ins and research clinics.',
    features: [
      'IB labs & study rooms',
      'TOK seminars and CAS facilitation',
      'Extended Essay guidance',
      'University counseling',
    ],
    history:
        '$_lgsOverview\n\nIB Phase stream established to nurture globally aware learners through inquiry, reflection, and service. The program emphasizes academic honesty, research methodologies, and sustained mentorship—culminating in extended essays and CAS portfolios that reflect student passions and community impact. Students are supported through internal workshops on citations, primary research, and oral presentation rehearsals.',
    academicHighlights: [
      'TOK colloquia and reflective journals',
      'EE workshops and supervisor meetings',
      'CAS project incubations',
      'Global university fairs',
      'IB-DP alignment and academic honesty workshops',
      'Primary research and oral presentation rehearsals',
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
    location: '364-E/1, MA Block E1, Johar Town, Phase 1, Lahore',
    imageUrl:
        'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=jt',
    description:
        'Expansive campus with strong STEM programs, competitive sports, and inter‑school events. Includes preschool, junior, middle girls and boys campuses under the broader LGS JT network. Johar Town International (co‑ed) is IB Diploma Programme (IB‑DP) authorized (15 Mar 2023), offering an internationally aligned pathway alongside Cambridge/GCE.',
    features: [
      'Advanced Science Labs',
      'Auditorium & Events',
      'Sports Complex',
      'Debate & Robotics',
    ],
    history:
        '$_lgsOverview\n\nThe Johar Town campus evolved into a flagship learning hub, integrating modern laboratories and multi-purpose venues. It regularly hosts inter-school debates, science fairs, and district-level sports meets while promoting mentorship for admissions and Olympiads. Collaborative ties with neighboring schools and community organizations enable student-led service and experiential learning.',
    academicHighlights: [
      'IB Diploma Programme authorization (Johar Town International, 15 Mar 2023)',
      'Cambridge/GCE and IB choice of pathways',
      'STEM olympiad participation',
      'Lab immersion tracks',
      'Admissions mentoring',
      'Math & coding clubs',
      'Inter-school debates and district-level sports meets',
      'Student-led service and experiential learning initiatives',
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
    location: 'Main Boulevard, Paragon City, Lahore',
    imageUrl:
        'https://images.unsplash.com/photo-1510936111840-6a8d2f1a5a1b?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=paragon',
    description:
        'LGS Paragon is part of the broader LGS network serving Lahore’s expanding residential areas. It emphasizes Cambridge-based academics (GCE), English‑medium instruction, co‑curricular activities, and the development of well‑rounded students. Inter‑house programs, clubs, and service cultivate teamwork, initiative, and values‑based education.',
    features: [
      'Science & IT Labs',
      'Sports & Fitness',
      'Leadership & Service Clubs',
      'Art & Culture Societies',
    ],
    history:
        '$_lgsOverview\n\nParagon campus has steadily expanded facilities and academic programming, encouraging student leadership through clubs and service. With regular inter-house events, it cultivates teamwork, creativity, and civic responsibility among students. Faculty advisories reinforce study habits, wellness routines, and community-minded values.',
    academicHighlights: [
      'Cambridge/GCE curriculum',
      'English‑medium instruction',
      'STEAM showcases',
      'Inter-house competitions',
      'Counseling and mentorship',
      'Reading & writing labs',
      'Service clubs and leadership programs',
      'Community engagement events',
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
