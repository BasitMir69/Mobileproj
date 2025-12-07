import 'package:flutter/material.dart';
import 'package:campus_wave/widgets/lgs_image.dart';

class HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? assetPath;
  final String? networkUrl;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final double height;

  const HeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.assetPath,
    this.networkUrl,
    this.ctaLabel,
    this.onCta,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          LgsImage(
            assetPath: assetPath,
            networkUrl: networkUrl,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(170, 0, 0, 0),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (ctaLabel != null && ctaLabel!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: onCta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(
                            0.25), // stronger opacity for visibility
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: Text(ctaLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
