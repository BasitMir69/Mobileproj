import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
            return FutureBuilder<File?>(
              future: _cachedFileForUrl(networkUrl!),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.done &&
                    snap.data != null &&
                    snap.data!.existsSync()) {
                  return Image.file(
                    snap.data!,
                    fit: fit,
                    width: width,
                    height: height,
                    errorBuilder: (c3, e3, s3) => _placeholder(),
                  );
                }
                // Show network image while caching in background
                _cacheNetworkImage(networkUrl!);
                return Image.network(
                  networkUrl!,
                  fit: fit,
                  width: width,
                  height: height,
                  errorBuilder: (c2, e2, s2) => _placeholder(),
                );
              },
            );
          }
          return _placeholder();
        },
      );
    }
    // Directly use network if no asset path.
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return FutureBuilder<File?>(
        future: _cachedFileForUrl(networkUrl!),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done &&
              snap.data != null &&
              snap.data!.existsSync()) {
            return Image.file(
              snap.data!,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (c3, e3, s3) => _placeholder(),
            );
          }
          _cacheNetworkImage(networkUrl!);
          return Image.network(
            networkUrl!,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (c, e, s) => _placeholder(),
          );
        },
      );
    }
    return _placeholder();
  }

  static Future<File?> _cachedFileForUrl(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'img_cache_${url.hashCode}.bin';
      return File('${dir.path}/$fileName');
    } catch (_) {
      return null;
    }
  }

  static Future<void> _cacheNetworkImage(String url) async {
    try {
      final f = await _cachedFileForUrl(url);
      if (f == null) return;
      if (await f.exists()) return;
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        await f.writeAsBytes(resp.bodyBytes);
      }
    } catch (_) {
      // ignore
    }
  }

  /// Public helper to prefetch/cache a network image for offline use.
  static Future<void> cacheImage(String? url) async {
    if (url == null || url.isEmpty) return;
    await _cacheNetworkImage(url);
  }
}
