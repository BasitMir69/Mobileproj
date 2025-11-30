import 'package:flutter/material.dart';

/// Reusable button supporting primary (solid) and secondary (tinted + border) styles
/// Handles loading state and optional leading icon.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool secondary; // if true -> tinted style
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.secondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final tintedFill =
        isDark ? const Color(0xFF115E4A) : const Color(0xFFE6F5F2);

    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    Widget childContent = loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 22,
                    color: secondary
                        ? (isDark ? Colors.white : const Color(0xFF0F4E45))
                        : Colors.white),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: secondary
                        ? (isDark ? Colors.white : const Color(0xFF0F4E45))
                        : Colors.white,
                  ),
                ),
              ),
            ],
          );

    if (!secondary) {
      return SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: isDark ? 0 : 2,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: shape,
          ),
          child: childContent,
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: tintedFill,
          foregroundColor: isDark ? Colors.white : const Color(0xFF0F4E45),
          side: BorderSide(color: primary, width: 1.1),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: shape,
        ),
        child: childContent,
      ),
    );
  }
}
