import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventDetailScreen extends StatelessWidget {
  final String title;
  final String body;

  const EventDetailScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed('search'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Appointment booking (placeholder)')));
              },
              child: const Text('Book Attendance / Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
