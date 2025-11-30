import 'package:flutter/material.dart';

/// Unified image widget that prefers a local asset and falls back to a network
/// URL, then a placeholder container if both fail.
class LgsImage extends StatelessWidget {
  final String? assetPath;
  final String? networkUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? debugLabel; // optional, shown on placeholder/error

  const LgsImage({
    super.key,
    this.assetPath,
    this.networkUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.debugLabel,
  });

  Widget _placeholder() => Container(
        color: Colors.grey[800],
        width: width,
        height: height,
        child: const Center(
          child: Icon(Icons.photo, size: 48, color: Colors.white54),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Try asset first if provided.
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (c, e, s) {
          // Show a hint when asset fails to load
          if (debugLabel != null && debugLabel!.isNotEmpty) {
            return Container(
              color: Colors.grey[850],
              width: width,
              height: height,
              child: Center(
                child: Text(
                  'Missing asset:\n${debugLabel!}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            );
          }
          // Fallback to network if available.
          if (networkUrl != null && networkUrl!.isNotEmpty) {
            return Image.network(
              networkUrl!,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (c2, e2, s2) => _placeholder(),
            );
          }
          return _placeholder();
        },
      );
    }
    // Directly use network if no asset path.
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Image.network(
        networkUrl!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (c, e, s) => _placeholder(),
      );
    }
    return _placeholder();
  }
}
