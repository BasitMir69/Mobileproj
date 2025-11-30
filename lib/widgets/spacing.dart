import 'package:flutter/material.dart';

class AppSpacing {
  static const double hGutter = 16; // horizontal gutter
  static const double hGutterWide = 20;
  static const double v4 = 4;
  static const double v8 = 8;
  static const double v12 = 12;
  static const double v24 = 24;
}

/// Constrains child to readable max width on larger screens.
class ReadableWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ReadableWidth({super.key, required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = constraints.maxWidth > maxWidth
            ? EdgeInsets.symmetric(
                horizontal: (constraints.maxWidth - maxWidth) / 2)
            : EdgeInsets.zero;
        return Padding(padding: pad, child: child);
      },
    );
  }
}
