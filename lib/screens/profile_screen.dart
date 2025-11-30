import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed('search'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            const Text('Parent Name',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 6),
            Text('user@example.com', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => context.pushNamed('appointments'),
                child: const Text('Manage Appointments')),
          ],
        ),
      ),
    );
  }
}
