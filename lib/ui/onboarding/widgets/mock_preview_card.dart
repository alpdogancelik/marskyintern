import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class MockPreviewCard extends StatelessWidget {
  const MockPreviewCard({
    super.key,
    this.variant = 0,
  });

  final int variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 230,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 214,
            height: 214,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary.withValues(alpha: 0.18),
                  colors.surfaceContainerHighest,
                ],
              ),
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            ),
          ),
          Transform.rotate(
            angle: variant == 0 ? -0.05 : 0.05,
            child: Container(
              width: 162,
              height: 188,
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.09),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusPill),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space3),
                    Expanded(
                      child: CustomPaint(
                        painter: _MiniChartPainter(
                          stroke: colors.primary,
                          fill: colors.primary.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space2),
                    Row(
                      children: List.generate(3, (index) {
                        final palette = [
                          colors.primary,
                          const Color(0xFFFFB646),
                          const Color(0xFF4DA6FF),
                        ];
                        return Container(
                          width: 18,
                          height: 18,
                          margin:
                              const EdgeInsets.only(right: AppTokens.space2),
                          decoration: BoxDecoration(
                            color: palette[index],
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: variant == 0 ? 22 : 30,
            right: 16,
            child: _FloatingChip(
              background: colors.primary.withValues(alpha: 0.14),
              foreground: colors.primary,
            ),
          ),
          Positioned(
            bottom: variant == 0 ? 22 : 32,
            left: 14,
            child: _FloatingChip(
              background: colors.surface,
              foreground: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingChip extends StatelessWidget {
  const _FloatingChip({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: foreground.withValues(alpha: 0.15)),
      ),
      child: Icon(
        Icons.currency_bitcoin_rounded,
        size: 20,
        color: foreground,
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  const _MiniChartPainter({
    required this.stroke,
    required this.fill,
  });

  final Color stroke;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.18, size.height * 0.6),
      Offset(size.width * 0.34, size.height * 0.64),
      Offset(size.width * 0.5, size.height * 0.48),
      Offset(size.width * 0.7, size.height * 0.52),
      Offset(size.width * 0.84, size.height * 0.38),
      Offset(size.width, size.height * 0.3),
    ];

    final area = Path()..moveTo(0, size.height);
    for (final point in points) {
      area.lineTo(point.dx, point.dy);
    }
    area.lineTo(size.width, size.height);
    area.close();

    canvas.drawPath(area, Paint()..color = fill);

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final control = Offset(
          (previous.dx + current.dx) / 2, math.min(previous.dy, current.dy));
      path.quadraticBezierTo(control.dx, control.dy, current.dx, current.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) {
    return oldDelegate.stroke != stroke || oldDelegate.fill != fill;
  }
}
