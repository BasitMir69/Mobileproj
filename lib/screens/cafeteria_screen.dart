import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CafeteriaScreen extends StatelessWidget {
  const CafeteriaScreen({super.key});

  final List<String> _images = const [
    // Replace with LGS Lahore cafeteria photos
    'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=1200',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafeteria'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed('search'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: _images.length,
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[800],
                      child: const Center(child: Icon(Icons.photo, size: 48)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cafeteria',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'A clean, healthy and welcoming cafeteria offering nutritious meals and snacks for students and staff.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening cafeteria gallery...')),
                );
              },
              icon: const Icon(Icons.restaurant),
              label: const Text('View More Photos'),
            ),
          ],
        ),
      ),
    );
  }
}
