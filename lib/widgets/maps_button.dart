import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsButton extends StatelessWidget {
  final String url; // Google Maps URL
  final String label;
  final EdgeInsetsGeometry padding;

  const MapsButton({
    super.key,
    required this.url,
    this.label = 'Open in Google Maps',
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open Maps link')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ElevatedButton.icon(
        onPressed: () => _openUrl(context),
        icon: const Icon(Icons.map_outlined),
        label: Text(label),
      ),
    );
  }
}
