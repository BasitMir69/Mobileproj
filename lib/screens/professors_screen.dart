import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/data/campus_professors.dart';

class ProfessorsScreen extends StatelessWidget {
  const ProfessorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professors by Campus')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: campusProfessors.length,
        itemBuilder: (context, index) {
          final campusName = campusProfessors.keys.elementAt(index);
          final list = campusProfessors[campusName]!;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(campusName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...list.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(p.photoUrl),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(p.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          Text('${p.title} • ${p.department}',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color
                                                      ?.withValues(
                                                          alpha: 0.8))),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => context.pushNamed(
                                        'professorDetail',
                                        pathParameters: {'id': p.id},
                                      ),
                                      icon: const Icon(Icons.calendar_today),
                                      label: const Text('Book'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(p.bio),
                                const SizedBox(height: 8),
                                Text('Skills & Subjects',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: p.skills
                                      .map<Widget>((s) => Chip(label: Text(s)))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                Text('Achievements',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: p.achievements
                                      .map<Widget>((a) => Row(
                                            children: [
                                              const Icon(
                                                  Icons.check_circle_outline,
                                                  size: 16),
                                              const SizedBox(width: 6),
                                              Expanded(child: Text(a)),
                                            ],
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                Text('Available Slots',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: p.availableSlots
                                      .map((s) => ActionChip(
                                            avatar: const Icon(Icons.schedule,
                                                size: 18),
                                            label: Text(s),
                                            onPressed: () => context.pushNamed(
                                              'professorDetail',
                                              pathParameters: {'id': p.id},
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
