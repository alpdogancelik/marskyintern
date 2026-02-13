import 'package:flutter/material.dart';

import '../../kit/app_card.dart';
import '../../theme/app_tokens.dart';

class GetStartedHeader extends StatelessWidget {
  const GetStartedHeader({
    super.key,
    this.showAssetPreview = false,
  });

  final bool showAssetPreview;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: showAssetPreview ? 220 : 180,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ArcPainter(
                lineColor: colors.primary.withValues(alpha: 0.24),
                dotColor: colors.primary.withValues(alpha: 0.38),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 46,
            child: _TinyBadge(
              color: const Color(0xFF5B8DFF),
              borderColor: colors.outlineVariant,
            ),
          ),
          Positioned(
            left: 32,
            top: 86,
            child: _TinyBadge(
              color: const Color(0xFFFF5D79),
              borderColor: colors.outlineVariant,
            ),
          ),
          Positioned(
            right: 26,
            top: 74,
            child: _PillLine(color: colors.primary.withValues(alpha: 0.8)),
          ),
          Positioned(
            right: 14,
            top: 112,
            child: _PillLine(color: colors.primary.withValues(alpha: 0.55)),
          ),
          if (showAssetPreview)
            Positioned(
              top: 8,
              left: 36,
              right: 36,
              child: _AssetValueCard(),
            ),
        ],
      ),
    );
  }
}

class _AssetValueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total asset value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$56,890.00',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space3),
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({
    required this.color,
    required this.borderColor,
  });

  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
    );
  }
}

class _PillLine extends StatelessWidget {
  const _PillLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.lineColor,
    required this.dotColor,
  });

  final Color lineColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final path1 = Path()
      ..moveTo(size.width * 0.08, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.35,
        size.width * 0.92,
        size.height * 0.7,
      );
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(size.width * 0.16, size.height * 0.83)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.5,
        size.width * 0.88,
        size.height * 0.82,
      );
    canvas.drawPath(path2, paint);

    final dotPaint = Paint()..color = dotColor;
    canvas.drawCircle(
        Offset(size.width * 0.31, size.height * 0.53), 3.2, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.67, size.height * 0.56), 3.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.dotColor != dotColor;
  }
}
