import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'coin_avatar.dart';

class CoinRow extends StatelessWidget {
  const CoinRow({
    super.key,
    required this.name,
    required this.symbol,
    required this.priceText,
    required this.changePercent,
    this.sparkline = const <double>[],
    this.iconSymbol,
    this.trailing,
    this.onTap,
  });

  final String name;
  final String symbol;
  final String priceText;
  final double changePercent;
  final List<double> sparkline;
  final String? iconSymbol;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPositive = changePercent >= 0;
    final changeColor = isPositive ? AppTokens.success : AppTokens.danger;
    final changePrefix = isPositive ? '+' : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space3,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            CoinAvatar(
              symbol: iconSymbol ?? symbol,
              size: 38,
              semanticLabel: '$symbol icon',
            ),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    symbol.toUpperCase(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              height: 24,
              child: _Sparkline(points: sparkline, color: changeColor),
            ),
            const SizedBox(width: AppTokens.space3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceText,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$changePrefix${changePercent.toStringAsFixed(2)}%',
                  style: textTheme.bodySmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppTokens.space2),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({
    required this.points,
    required this.color,
  });

  final List<double> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 32,
          height: 2,
          color: color.withValues(alpha: 0.35),
        ),
      );
    }
    return CustomPaint(
      painter: _SparklinePainter(points: points, color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.points,
    required this.color,
  });

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final min = points.reduce((a, b) => a < b ? a : b);
    final max = points.reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs() < 0.0001 ? 1.0 : (max - min);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final dx = (i / (points.length - 1)) * size.width;
      final normalized = (points[i] - min) / range;
      final dy = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.points != points;
  }
}
