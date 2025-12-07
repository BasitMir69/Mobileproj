import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class LinkChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const LinkChip({
    super.key,
    required this.icon,
    required this.label,
    required this.url,
  });

  Future<void> _openExternal(BuildContext context) async {
    final uri = Uri.parse(url);
    final can = await ul.canLaunchUrl(uri);
    if (!can) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
      return;
    }
    await ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primary.withOpacity(0.12);
    final border = theme.colorScheme.primary.withOpacity(0.25);
    final fg = theme.colorScheme.onSurface;
    return ActionChip(
      avatar: Icon(icon, size: 18, color: fg),
      label: Text(label),
      onPressed: () => _openExternal(context),
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: border),
      ),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;
    final border = theme.colorScheme.primary.withOpacity(0.15);
    final fg = theme.colorScheme.onSurface;
    return ActionChip(
      avatar: Icon(icon, size: 18, color: fg),
      label: Text(label),
      onPressed: null,
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: border),
      ),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}
