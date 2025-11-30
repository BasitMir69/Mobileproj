import 'package:flutter/material.dart';

/// Simple CW logo using CustomPaint to fill header space.
class CwLogo extends StatelessWidget {
  final double size;
  final Color color;
  const CwLogo({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CwPainter(color),
    );
  }
}

class _CwPainter extends CustomPainter {
  final Color color;
  _CwPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Outer C ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.25 * 3.14159,
      1.5 * 3.14159,
      false,
      stroke,
    );

    // Inner W stylized
    final path = Path();
    final y = center.dy + radius * 0.25;
    final left = center.dx - radius * 0.6;
    final right = center.dx + radius * 0.6;
    final midL = center.dx - radius * 0.2;
    final midR = center.dx + radius * 0.2;
    path.moveTo(left, y);
    path.lineTo(midL, y - radius * 0.35);
    path.lineTo(center.dx, y);
    path.lineTo(midR, y - radius * 0.35);
    path.lineTo(right, y);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
