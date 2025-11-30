class Appointment {
  final String id;
  final String userId;
  final String professorId;
  final DateTime start;
  final DateTime end;
  final String location;

  const Appointment({
    required this.id,
    required this.userId,
    required this.professorId,
    required this.start,
    required this.end,
    required this.location,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'professorId': professorId,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'location': location,
      };
}

const demoUserId = 'demo-user';

final sampleAppointments = <Appointment>[
  Appointment(
    id: 'a1',
    userId: demoUserId,
    professorId: 'p1',
    start: DateTime.now().add(const Duration(days: 1, hours: 2)),
    end: DateTime.now().add(const Duration(days: 1, hours: 3)),
    location: 'Admin Block, Room 203',
  ),
  Appointment(
    id: 'a2',
    userId: demoUserId,
    professorId: 'p3',
    start: DateTime.now().add(const Duration(days: 3, hours: 1)),
    end: DateTime.now().add(const Duration(days: 3, hours: 2)),
    location: 'Science Building, Lab A',
  ),
];
