import 'package:flutter/material.dart';

class EmeraldCard extends StatelessWidget {
  final Widget child;
  final String? badgeText;
  const EmeraldCard({super.key, required this.child, this.badgeText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Use theme surface as base, add a subtle tint based on primary for light mode
    final cardColor = isDark
        ? theme.colorScheme.surface
        : theme.colorScheme.surface.withValues(alpha: 0.98);
    final borderColor =
        theme.colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.18);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
        if (badgeText != null && badgeText!.isNotEmpty)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Text(
                badgeText!,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
