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
                final ProfessorExtended p = list[i];
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final achievements = p.achievements.take(2).toList();
                return Card(
                  color: isDark ? const Color(0xFF1E1E1E) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(p.photoUrl),
                      ),
                      title: Text(p.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${p.title} • ${p.department}',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.8))),
                          if (achievements.isNotEmpty)
                            const SizedBox(height: 6),
                          if (achievements.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: achievements
                                  .map((a) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          a,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ))
                                  .toList(),
                            ),
                        ],
                      ),
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
                      isThreeLine: achievements.isNotEmpty,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
