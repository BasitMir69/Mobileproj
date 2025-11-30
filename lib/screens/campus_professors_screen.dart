import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/data/campus_professors.dart';

class CampusProfessorsScreen extends StatelessWidget {
  final String campusName;
  const CampusProfessorsScreen({super.key, required this.campusName});

  @override
  Widget build(BuildContext context) {
    final list = professorsForCampus(campusName);
    return Scaffold(
      appBar: AppBar(
        title: Text('$campusName Professors'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed('search'),
          ),
        ],
      ),
      body: list.isEmpty
          ? const Center(
              child: Text('No professors listed for this campus yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = list[i];
                return Card(
                  color: const Color(0xFF1E1E1E),
                  child: ListTile(
                    leading:
                        CircleAvatar(backgroundImage: NetworkImage(p.photoUrl)),
                    title: Text(p.name,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${p.title} • ${p.department}',
                        style: TextStyle(color: Colors.grey[400])),
                    trailing: Semantics(
                      button: true,
                      label: 'Book appointment',
                      hint: 'Choose a slot with ${p.name}',
                      child: Tooltip(
                        message: 'Book ${p.name}',
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Book'),
                          onPressed: () => context.pushNamed(
                            'professorDetail',
                            pathParameters: {'id': p.id},
                          ),
                        ),
                      ),
                    ),
                    onTap: () => context.pushNamed(
                      'professorDetail',
                      pathParameters: {'id': p.id},
                    ),
                  ),
                );
              },
            ),
    );
  }
}
