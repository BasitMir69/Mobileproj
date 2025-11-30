import 'package:flutter/material.dart';
import 'package:campus_wave/widgets/lgs_image.dart';

class SportsComplexScreen extends StatelessWidget {
  const SportsComplexScreen({super.key});

  List<String> get _assetImages => const [
        'assets/lgs/facilities/sports/1.jpg',
        'assets/lgs/facilities/sports/2.jpg',
      ];

  List<String> get _fallbackUrls => const [
        'https://images.unsplash.com/photo-1517649763962-0c623066013b?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=sport1',
        'https://images.unsplash.com/photo-1504461923895-9d2f9d4e7f5d?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=sport2',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Complex'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
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
            const Text(
              'Sports Complex & Playing Grounds',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Full-size fields, indoor courts and well-maintained tracks for various sports activities and inter-school events.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening sports gallery...')),
                );
              },
              icon: const Icon(Icons.sports_soccer),
              label: const Text('View More Photos'),
            ),
          ],
        ),
      ),
    );
  }
}
