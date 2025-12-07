import 'package:campus_wave/models/professor.dart';

// Sample per-campus professors (5 each) with skills & achievements.
// In a real app this would come from an API.
class ProfessorExtended extends Professor {
  final List<String> skills; // Key academic skills / subjects
  final List<String> achievements; // Notable student grade outcomes / accolades

  const ProfessorExtended({
    required super.id,
    required super.name,
    required super.title,
    required super.department,
    required super.photoUrl,
    required super.office,
    required super.bio,
    required super.availableSlots,
    required this.skills,
    required this.achievements,
  });
}

// Helper typedef so callers can treat them as Professor as well.
typedef CampusProfessorsMap = Map<String, List<ProfessorExtended>>;

final CampusProfessorsMap campusProfessors = {
  // LGS 1A1
  'LGS 1A1': [
    const ProfessorExtended(
      id: '1a1_p1',
      name: 'Dr. Sara Malik',
      title: 'Associate Professor',
      department: 'Computer Science',
      photoUrl: 'https://i.pravatar.cc/150?img=12',
      office: 'Admin Block 204',
      bio:
          'Researches algorithms, human-centered computing, and learning technologies. Mentors robotics and coding clubs, guiding teams through problem decomposition and code review. Encourages portfolio building, ethics in AI, and collaborative software practices.',
      availableSlots: [
        '2025-12-08 10:00',
        '2025-12-09 14:00',
        '2025-12-11 11:30'
      ],
      skills: ['Algorithms', 'Data Structures', 'Python', 'Robotics'],
      achievements: [
        'Coached IOI qualifiers',
        'Published 12+ peer-reviewed papers',
        'Launched student open-source initiative'
      ],
    ),
    const ProfessorExtended(
      id: '1a1_p2',
      name: 'Prof. Ali Raza',
      title: 'Senior Lecturer',
      department: 'Mathematics',
      photoUrl: 'https://i.pravatar.cc/150?img=23',
      office: 'Math Wing 112',
      bio:
          'Calculus and discrete mathematics specialist with focus on problem-solving heuristics. Organizes math contests and prepares training sets that emphasize proofs, invariants, and combinatorial arguments.',
      availableSlots: ['2025-12-09 09:00', '2025-12-11 12:30'],
      skills: ['Calculus', 'Combinatorics', 'Number Theory'],
      achievements: [
        'Math Olympiad coach',
        'Curriculum designer',
        'Inquiry-based learning modules'
      ],
    ),
    const ProfessorExtended(
      id: '1a1_p3',
      name: 'Dr. Mehak Javed',
      title: 'Assistant Professor',
      department: 'Physics',
      photoUrl: 'https://i.pravatar.cc/150?img=32',
      office: 'Physics Lab A',
      bio:
          'Optics and materials researcher; leads the science fair committee and builds hands-on lab modules. Promotes measurement accuracy, lab journals, and safety-first experimentation.',
      availableSlots: ['2025-12-08 10:30', '2025-12-11 15:00'],
      skills: ['Optics', 'Materials', 'Experimental Methods'],
      achievements: [
        'Regional science fair winners',
        'Lab modernization',
        'Student-led optics demos'
      ],
    ),
    const ProfessorExtended(
      id: '1a1_p4',
      name: 'Prof. Hira Farooq',
      title: 'Lecturer',
      department: 'Chemistry',
      photoUrl: 'https://i.pravatar.cc/150?img=45',
      office: 'Chem Lab 3',
      bio:
          'Organic chemistry lead with interest in spectroscopy and synthesis. Runs inter-school lab competitions and workshops on technique, documentation, and lab hygiene.',
      availableSlots: ['2025-12-08 13:00', '2025-12-10 10:00'],
      skills: ['Organic Chem', 'Lab Safety', 'Spectroscopy'],
      achievements: [
        'Chem olympiad mentoring',
        'New lab kits rollout',
        'Student safety certification drive'
      ],
    ),
    const ProfessorExtended(
      id: '1a1_p5',
      name: 'Dr. Kamran Akhtar',
      title: 'Associate Professor',
      department: 'English',
      photoUrl: 'https://i.pravatar.cc/150?img=5',
      office: 'Humanities 201',
      bio:
          'Leads literature circles and debate with emphasis on rhetoric and style. Guides academic writing, citation habits, and oral presentation craft for conferences and MUN.',
      availableSlots: ['2025-12-09 12:00', '2025-12-11 09:30'],
      skills: ['Academic Writing', 'Literature', 'Debate Coaching'],
      achievements: [
        'Debate tournament wins',
        'Writing workshops',
        'School literary magazine advisor'
      ],
    ),
  ],

  // LGS 42 B-III Gulberg
  'LGS 42 B-III Gulberg': [
    const ProfessorExtended(
      id: '42b_p1',
      name: 'Dr. Rania Siddiq',
      title: 'Assistant Professor',
      department: 'Economics',
      photoUrl: 'https://i.pravatar.cc/150?img=11',
      office: 'Business 105',
      bio:
          'Macroeconomics, data literacy, and visualization advocate. Faculty advisor for finance club, coaching students on policy briefs and data-backed presentations.',
      availableSlots: ['2025-12-09 15:00', '2025-12-11 11:30'],
      skills: ['Macroecon', 'Statistics', 'Data Viz'],
      achievements: ['Student research awards', 'City policy brief showcase'],
    ),
    const ProfessorExtended(
      id: '42b_p2',
      name: 'Prof. Danish Latif',
      title: 'Senior Lecturer',
      department: 'Computer Science',
      photoUrl: 'https://i.pravatar.cc/150?img=9',
      office: 'IT 210',
      bio:
          'Software engineering, databases, and mobile apps. Hackathon mentor helping teams architect clean codebases, plan sprints, and ship demos with clear READMEs.',
      availableSlots: ['2025-12-10 14:15', '2025-12-11 16:00'],
      skills: ['Databases', 'Flutter', 'APIs'],
      achievements: ['Hackathon coaching', 'Student app showcase'],
    ),
    const ProfessorExtended(
      id: '42b_p3',
      name: 'Dr. Saira Nadeem',
      title: 'Associate Professor',
      department: 'Biology',
      photoUrl: 'https://i.pravatar.cc/150?img=36',
      office: 'Bio Lab 1',
      bio:
          'Molecular biology and field research; patron of the biology society. Designs inquiry labs and encourages authentic data collection and reflection.',
      availableSlots: ['2025-12-08 09:15', '2025-12-10 11:00'],
      skills: ['Microbiology', 'Field Research', 'Lab Techniques'],
      achievements: ['Biology olympiad coaching', 'Field survey projects'],
    ),
    const ProfessorExtended(
      id: '42b_p4',
      name: 'Prof. Nida Ejaz',
      title: 'Lecturer',
      department: 'History',
      photoUrl: 'https://i.pravatar.cc/150?img=29',
      office: 'Humanities 109',
      bio:
          'World history survey with focus on sources and context. Model UN advisor guiding research memos, speeches, and moderated caucus strategy.',
      availableSlots: ['2025-12-09 11:00', '2025-12-11 10:30'],
      skills: ['Modern History', 'Research', 'Public Speaking'],
      achievements: ['MUN delegation awards', 'Archive-reading workshops'],
    ),
    const ProfessorExtended(
      id: '42b_p5',
      name: 'Dr. Farhan Iqbal',
      title: 'Assistant Professor',
      department: 'Physics',
      photoUrl: 'https://i.pravatar.cc/150?img=13',
      office: 'Physics 205',
      bio:
          'Mechanics, circuits, and hands-on electronics; makerspace lead. Promotes iteration, documentation, and safety while building prototypes and demos.',
      availableSlots: ['2025-12-08 12:30', '2025-12-11 10:00'],
      skills: ['Mechanics', 'Circuits', 'Arduino'],
      achievements: ['Robotics expo wins', 'Intro-to-electronics bootcamps'],
    ),
  ],

  // LGS Gulberg Campus 2
  'LGS Gulberg Campus 2': [
    const ProfessorExtended(
      id: 'demo_professor',
      name: 'Dr. Ayesha Khan',
      title: 'Associate Professor',
      department: 'Biology',
      photoUrl: 'https://i.pravatar.cc/150?img=47',
      office: 'Bio Lab 1',
      bio:
          'Experienced biology educator passionate about practical learning and hands-on experiments. Specializes in cell biology, genetics, and laboratory techniques. Mentors students through detailed lab sessions and provides one-on-one guidance on research methodologies.',
      availableSlots: [
        '2025-12-08 10:00',
        '2025-12-09 14:00',
        '2025-12-10 11:30',
        '2025-12-11 15:00'
      ],
      skills: [
        'Cell Biology',
        'Genetics',
        'Lab Techniques',
        'Research Methods'
      ],
      achievements: [
        'Published 8 peer-reviewed papers',
        'Mentored 20+ undergraduate researchers',
        'Best Teacher Award 2024'
      ],
    ),
    const ProfessorExtended(
      id: 'g2_p1',
      name: 'Dr. Hammad Qureshi',
      title: 'Associate Professor',
      department: 'Computer Science',
      photoUrl: 'https://i.pravatar.cc/150?img=21',
      office: 'IT 205',
      bio:
          'Data science and ML with emphasis on reproducibility and model ethics. Supervises project labs and reviews experiment logs, helping teams communicate insights.',
      availableSlots: ['2025-12-08 10:00', '2025-12-11 12:00'],
      skills: ['Machine Learning', 'Python', 'Data Analysis'],
      achievements: ['ML project showcases', 'Reproducibility best-practices'],
    ),
    const ProfessorExtended(
      id: 'g2_p2',
      name: 'Prof. Rabia Imran',
      title: 'Senior Lecturer',
      department: 'English',
      photoUrl: 'https://i.pravatar.cc/150?img=28',
      office: 'Humanities 210',
      bio:
          'Rhetoric and composition; conducts debate and writing workshops. Coaches evidence-based argumentation and narrative clarity in academic contexts.',
      availableSlots: ['2025-12-09 11:30', '2025-12-10 13:00'],
      skills: ['Academic Writing', 'Public Speaking', 'Lit Analysis'],
      achievements: ['Debate tournament wins', 'Writing clinic series'],
    ),
    const ProfessorExtended(
      id: 'g2_p3',
      name: 'Dr. Zainab Tariq',
      title: 'Assistant Professor',
      department: 'Chemistry',
      photoUrl: 'https://i.pravatar.cc/150?img=31',
      office: 'Chem Lab 2',
      bio:
          'Analytical chemistry; coordinates lab safety training and calibration routines. Encourages meticulous record keeping and collaborative lab protocols.',
      availableSlots: ['2025-12-10 10:00', '2025-12-11 15:30'],
      skills: ['Analytical Chem', 'Spectrometry', 'Safety'],
      achievements: ['New lab SOPs implemented', 'Calibration workshops'],
    ),
    const ProfessorExtended(
      id: 'g2_p4',
      name: 'Prof. Umair Shafi',
      title: 'Lecturer',
      department: 'Physics',
      photoUrl: 'https://i.pravatar.cc/150?img=7',
      office: 'Physics Lab B',
      bio:
          'Electromagnetism and circuits; physics club advisor who runs peer-instruction sessions and demo builds for conceptual understanding.',
      availableSlots: ['2025-12-09 09:30', '2025-12-10 11:00'],
      skills: ['EM Theory', 'Circuits', 'Arduino'],
      achievements: ['Science fair mentorship', 'Demo build-a-thons'],
    ),
    const ProfessorExtended(
      id: 'g2_p5',
      name: 'Dr. Mariam Shah',
      title: 'Assistant Professor',
      department: 'Mathematics',
      photoUrl: 'https://i.pravatar.cc/150?img=52',
      office: 'Math Wing 108',
      bio:
          'Statistics and probability; coordinates math circles that highlight intuition, visualization, and problem narratives to build confidence.',
      availableSlots: ['2025-12-08 15:00', '2025-12-11 10:30'],
      skills: ['Probability', 'Statistics', 'Problem Solving'],
      achievements: ['Math circle program', 'Data storytelling series'],
    ),
  ],

  // LGS IB PHASE
  'LGS IB PHASE': [
    const ProfessorExtended(
      id: 'ib_p1',
      name: 'Dr. Anam Sheikh',
      title: 'IB Coordinator',
      department: 'TOK / Humanities',
      photoUrl: 'https://i.pravatar.cc/150?img=17',
      office: 'IB Suite 1',
      bio:
          'TOK seminars and CAS facilitation; mentors extended essays with attention to research integrity and reflective writing. Helps students frame questions and structure arguments.',
      availableSlots: ['2025-12-09 10:00', '2025-12-11 13:00'],
      skills: ['TOK', 'EE Mentoring', 'CAS Projects'],
      achievements: ['EE distinction projects', 'Academic honesty workshops'],
    ),
    const ProfessorExtended(
      id: 'ib_p2',
      name: 'Prof. Bilal Hussain',
      title: 'Senior Lecturer',
      department: 'Physics (IB)',
      photoUrl: 'https://i.pravatar.cc/150?img=19',
      office: 'Science 301',
      bio:
          'IB physics labs and IA guidance; supports lab design, data analysis, and clear communication of results. Also coaches physics Olympiad prep.',
      availableSlots: ['2025-12-08 11:00', '2025-12-10 12:00'],
      skills: ['IB IA', 'Mechanics', 'Waves'],
      achievements: ['IB top scores', 'IA exemplar repository'],
    ),
    const ProfessorExtended(
      id: 'ib_p3',
      name: 'Dr. Sana Malik',
      title: 'Assistant Professor',
      department: 'Biology (IB)',
      photoUrl: 'https://i.pravatar.cc/150?img=24',
      office: 'Bio Lab 4',
      bio:
          'IB biology practicals and field modules; emphasizes observation, methodology, and ethical sampling. Guides students toward actionable reflections.',
      availableSlots: ['2025-12-10 13:00', '2025-12-11 09:30'],
      skills: ['Cell Bio', 'Ecology', 'Field Methods'],
      achievements: ['CAS biodiversity projects', 'Field notebook clinics'],
    ),
    const ProfessorExtended(
      id: 'ib_p4',
      name: 'Prof. Hina Qamar',
      title: 'Lecturer',
      department: 'English (IB)',
      photoUrl: 'https://i.pravatar.cc/150?img=39',
      office: 'Humanities 305',
      bio:
          'Language & Literature; practices IO, commentary, and comparative analysis. Encourages textual evidence, clarity, and command of register.',
      availableSlots: ['2025-12-09 12:00', '2025-12-10 10:00'],
      skills: ['IB Lang&Lit', 'IO', 'Commentary'],
      achievements: ['Lang&Lit high marks', 'Reading circles initiative'],
    ),
    const ProfessorExtended(
      id: 'ib_p5',
      name: 'Dr. Adeel Karim',
      title: 'Assistant Professor',
      department: 'Mathematics (IB)',
      photoUrl: 'https://i.pravatar.cc/150?img=41',
      office: 'Math Wing 207',
      bio:
          'AA/AI curriculum specialist; mentors IAs, exam strategy, and mathematical communication. Focus on clarity of reasoning and structure.',
      availableSlots: ['2025-12-08 09:30', '2025-12-11 14:30'],
      skills: ['IB AA/AI', 'IA Guidance', 'Exam Strategy'],
      achievements: ['Consistent 6-7 scores', 'IA writing workshops'],
    ),
  ],

  // LGS JT (Johar Town)
  'LGS JT': [
    const ProfessorExtended(
      id: 'jt_p1',
      name: 'Dr. Sara Malik',
      title: 'Associate Professor',
      department: 'Computer Science',
      photoUrl: 'https://i.pravatar.cc/150?img=12',
      office: 'Admin Block 204',
      bio:
          'Focuses on algorithms and data structures; mentors coding clubs and robotics teams. Organizes code walkthroughs and debugging clinics to build problem-solving habits.',
      availableSlots: [
        '2025-12-08 10:00',
        '2025-12-09 14:00',
        '2025-12-11 11:30'
      ],
      skills: ['Algorithms', 'Data Structures', 'Python', 'Robotics'],
      achievements: ['Coached IOI qualifiers', 'Published 12+ papers'],
    ),
    const ProfessorExtended(
      id: 'jt_p2',
      name: 'Prof. Ali Raza',
      title: 'Senior Lecturer',
      department: 'Mathematics',
      photoUrl: 'https://i.pravatar.cc/150?img=23',
      office: 'Math Wing 112',
      bio:
          'Teaches calculus and discrete math; designs math contests and training sessions. Highlights proof strategies, estimation, and modeling.',
      availableSlots: ['2025-12-10 09:00', '2025-12-12 12:30'],
      skills: ['Calculus', 'Combinatorics', 'Number Theory'],
      achievements: ['Math Olympiad coach', 'Curriculum designer'],
    ),
    const ProfessorExtended(
      id: 'jt_p3',
      name: 'Dr. Mehak Javed',
      title: 'Assistant Professor',
      department: 'Physics',
      photoUrl: 'https://i.pravatar.cc/150?img=32',
      office: 'Physics Lab A',
      bio:
          'Research in optics and materials; runs science fair committee and student demo labs with a focus on visualization and precision.',
      availableSlots: ['2025-12-09 10:30', '2025-12-11 15:00'],
      skills: ['Optics', 'Materials', 'Experimental Methods'],
      achievements: ['Regional science fair winners', 'Lab modernization'],
    ),
    const ProfessorExtended(
      id: 'jt_p4',
      name: 'Prof. Hira Farooq',
      title: 'Lecturer',
      department: 'Chemistry',
      photoUrl: 'https://i.pravatar.cc/150?img=45',
      office: 'Chem Lab 3',
      bio:
          'Organic chemistry lead; organizes inter-school lab competitions and skill drills for practicals and documentation.',
      availableSlots: ['2025-12-08 13:00', '2025-12-12 10:00'],
      skills: ['Organic Chem', 'Lab Safety', 'Spectroscopy'],
      achievements: ['Chem olympiad mentoring', 'New lab kits rollout'],
    ),
    const ProfessorExtended(
      id: 'jt_p5',
      name: 'Dr. Kamran Akhtar',
      title: 'Associate Professor',
      department: 'English',
      photoUrl: 'https://i.pravatar.cc/150?img=5',
      office: 'Humanities 201',
      bio:
          'Leads literature circles and debate; focuses on academic writing, research notes, and oral presentation craft.',
      availableSlots: ['2025-12-09 12:00', '2025-12-11 09:30'],
      skills: ['Academic Writing', 'Literature', 'Debate Coaching'],
      achievements: ['Debate wins', 'Writing workshops'],
    ),
  ],

  // LGS PARAGON
  'LGS PARAGON': [
    const ProfessorExtended(
      id: 'pg_p1',
      name: 'Dr. Ayesha Noor',
      title: 'Assistant Professor',
      department: 'Biology',
      photoUrl: 'https://i.pravatar.cc/150?img=54',
      office: 'Bio Lab 1',
      bio:
          'Leads microbiology modules; organizes field visits and community awareness drives around hygiene and public health basics.',
      availableSlots: ['2025-12-08 09:15', '2025-12-10 11:00'],
      skills: ['Microbiology', 'Field Research', 'Lab Techniques'],
      achievements: ['Biology olympiad coaching'],
    ),
    const ProfessorExtended(
      id: 'pg_p2',
      name: 'Prof. Danish Latif',
      title: 'Senior Lecturer',
      department: 'Economics',
      photoUrl: 'https://i.pravatar.cc/150?img=8',
      office: 'Business 105',
      bio:
          'Macroeconomics and data literacy; runs finance society and supports policy case competitions with evidence-based analysis.',
      availableSlots: ['2025-12-09 15:00', '2025-12-11 11:30'],
      skills: ['Macroecon', 'Statistics', 'Data Viz'],
      achievements: ['Student research awards'],
    ),
    const ProfessorExtended(
      id: 'pg_p3',
      name: 'Dr. Usman Tariq',
      title: 'Associate Professor',
      department: 'Computer Science',
      photoUrl: 'https://i.pravatar.cc/150?img=62',
      office: 'IT 210',
      bio:
          'Software engineering and databases; hackathon mentor guiding API design, schema planning, and testing culture.',
      availableSlots: ['2025-12-10 14:15', '2025-12-11 16:00'],
      skills: ['Databases', 'Flutter', 'APIs'],
      achievements: ['Hackathon coaching'],
    ),
    const ProfessorExtended(
      id: 'pg_p4',
      name: 'Prof. Nida Ejaz',
      title: 'Lecturer',
      department: 'History',
      photoUrl: 'https://i.pravatar.cc/150?img=67',
      office: 'Humanities 109',
      bio:
          'World history survey; Model UN advisor encouraging research memos and speech clarity.',
      availableSlots: ['2025-12-09 11:00', '2025-12-11 10:30'],
      skills: ['Modern History', 'Research', 'Public Speaking'],
      achievements: ['MUN delegation awards'],
    ),
    const ProfessorExtended(
      id: 'pg_p5',
      name: 'Dr. Farhan Iqbal',
      title: 'Assistant Professor',
      department: 'Physics',
      photoUrl: 'https://i.pravatar.cc/150?img=14',
      office: 'Physics 205',
      bio:
          'Mechanics and circuits; makerspace lead who supports safety, documentation, and iterative prototyping.',
      availableSlots: ['2025-12-08 12:30', '2025-12-11 10:00'],
      skills: ['Mechanics', 'Circuits', 'Arduino'],
      achievements: ['Robotics expo wins'],
    ),
  ],
};

List<ProfessorExtended> professorsForCampus(String campusName) =>
    campusProfessors[campusName] ?? const [];
