import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(user?.email ?? 'Admin'),
              subtitle: const Text('Signed in as Admin'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Feedback',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('feedback')
                        .orderBy('createdAt', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Text('No feedback yet');
                      }
                      return Column(
                        children: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final msg = data['message'] ?? '';
                          final rating = (data['rating'] ?? 0) as int;
                          return ListTile(
                            leading: Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            title: Text(msg),
                            subtitle: Text('Rating: ${rating}/5'),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Admissions Management'),
              subtitle: const Text('Approve or reject admission submissions'),
              onTap: () => context.push('/admin/admissions'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Campus News'),
              subtitle: const Text('Create, edit and publish campus news'),
              onTap: () => context.push('/admin/news'),
            ),
          ),
          // Professors Overview removed from admin dashboard
        ],
      ),
    );
  }
}
