import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_wave/services/firestore_service.dart';

class CampusNewsScreen extends StatelessWidget {
  const CampusNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirestoreService.streamPublishedCampusNews(limit: 50);

    return Scaffold(
      appBar: AppBar(title: const Text('Campus News')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No published news yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'News';
              final content = data['content'] ?? '';
              final campus = data['campus'] ?? 'All Campuses';
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.campaign_outlined),
                  title: Text(title),
                  subtitle: Text('$campus'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          _NewsDetailInline(title: title, body: content),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NewsDetailInline extends StatelessWidget {
  final String title;
  final String body;
  const _NewsDetailInline({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(body),
      ),
    );
  }
}
