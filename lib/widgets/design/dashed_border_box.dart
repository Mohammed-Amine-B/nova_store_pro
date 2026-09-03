import 'package:flutter/material.dart';

/// A rounded-rect box with a dashed border, used for empty/placeholder
/// states in the new design language (see theme/design_tokens.dart). No
/// third-party dependency — a small reusable CustomPainter.
class DashedBorderBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const DashedBorderBox({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.color = const Color(0xFFE6E0D5),
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.gapLength = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        radius: borderRadius,
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  _DashedRRectPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.gapLength != gapLength;
}
