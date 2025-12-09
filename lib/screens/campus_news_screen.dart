import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/services/firestore_service.dart';

class CampusNewsScreen extends StatefulWidget {
  const CampusNewsScreen({super.key});

  @override
  State<CampusNewsScreen> createState() => _CampusNewsScreenState();
}

class _CampusNewsScreenState extends State<CampusNewsScreen> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final profile = await FirestoreService.getUserProfile(user.uid);
      setState(() {
        _role = profile?['role'] ?? 'student';
      });
    } catch (_) {
      setState(() {
        _role = 'student';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirestoreService.streamPublishedCampusNews(limit: 50);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus News'),
        actions: [
          if (_role == 'admin') ...[
            IconButton(
              tooltip: 'Admin News',
              icon: const Icon(Icons.edit_note),
              onPressed: () => context.go('/admin/news'),
            ),
            IconButton(
              tooltip: 'Admin Dashboard',
              icon: const Icon(Icons.dashboard_customize),
              onPressed: () => context.go('/admin'),
            ),
          ],
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
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
              final id = d.id;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.campaign_outlined),
                  title: Text(title),
                  subtitle: Text('$campus'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _NewsDetailInline(
                        id: id,
                        title: title,
                        body: content,
                        role: _role,
                      ),
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
  final String id;
  final String title;
  final String body;
  final String? role;
  const _NewsDetailInline({
    required this.id,
    required this.title,
    required this.body,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (role == 'admin')
            IconButton(
              tooltip: 'Edit This News',
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/admin/news'),
            ),
          if (role == 'admin')
            IconButton(
              tooltip: 'Back to Admin',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/admin'),
            ),
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(body),
      ),
    );
  }
}
