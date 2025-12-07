import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/widgets/lgs_image.dart';
import 'package:campus_wave/widgets/section_header.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  List<String> get _assetImages => const [
        'assets/lgs/facilities/library/1.jpg',
        'assets/lgs/facilities/library/2.jpg',
      ];

  List<String> get _fallbackUrls => const [
        'https://images.unsplash.com/photo-1510936111840-6a8d2f1a5a1b?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=lib1',
        'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=lib2',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
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
                itemCount: _assetImages.length,
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LgsImage(
                    assetPath: _assetImages[i],
                    networkUrl: _fallbackUrls[i],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(label: 'LGS Library'),
            const SizedBox(height: 8),
            const Text(
              'A quiet, well-stocked library with a wide range of textbooks, reference materials and study spaces. Open to students and staff during school hours.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening library gallery...')),
                );
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('View More Photos'),
            ),
          ],
        ),
      ),
    );
  }
}
