import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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
