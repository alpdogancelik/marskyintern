import 'dart:math' as math;

import 'package:flutter/material.dart';

class SparklineMiniChart extends StatelessWidget {
  const SparklineMiniChart({
    super.key,
    required this.values,
    required this.isPositive,
    this.height = 28,
    this.width = 72,
  });

  final List<double> values;
  final bool isPositive;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(
        height: height,
        width: width,
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparkPainter(
          values: values,
          strokeColor:
              isPositive ? const Color(0xFF11B36B) : const Color(0xFFD9435A),
          fillColor: isPositive
              ? const Color(0xFF11B36B).withValues(alpha: 0.10)
              : const Color(0xFFD9435A).withValues(alpha: 0.10),
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter({
    required this.values,
    required this.strokeColor,
    required this.fillColor,
  });

  final List<double> values;
  final Color strokeColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range =
        (maxValue - minValue).abs() < 0.00001 ? 1.0 : (maxValue - minValue);

    Offset mapPoint(int i) {
      final x = (i / (values.length - 1)) * size.width;
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * size.height);
      return Offset(x, y.clamp(0, size.height));
    }

    final points = List.generate(values.length, mapPoint);
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final control = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(control.dx, control.dy, curr.dx, curr.dy);
    }

    final areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(areaPath, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor;
  }
}
