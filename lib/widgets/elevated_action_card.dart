import 'package:flutter/material.dart';

class ElevatedActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const ElevatedActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<ElevatedActionCard> createState() => _ElevatedActionCardState();
}

class _ElevatedActionCardState extends State<ElevatedActionCard> {
  double _scale = 1.0;

  void _down(_) => setState(() => _scale = 0.98);
  void _up(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final accent = theme.colorScheme.primary;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        elevation: isLight ? 2 : 0,
        borderRadius: BorderRadius.circular(12),
        color: surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          onTapDown: _down,
          onTapCancel: () => setState(() => _scale = 1.0),
          onTapUp: _up,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(widget.icon, color: accent),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: onSurface),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: onSurface.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
