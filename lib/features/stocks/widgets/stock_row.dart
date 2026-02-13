import 'package:flutter/material.dart';

import '../../../ui/kit/trend_chip.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/stock.dart';
import 'sparkline_mini_chart.dart';

class StockRow extends StatelessWidget {
  const StockRow({
    super.key,
    required this.stock,
    required this.onTap,
  });

  final Stock stock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space4,
          vertical: AppTokens.space3,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            _StockBadge(symbol: stock.symbol),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stock.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTokens.space2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${stock.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                TrendChip(change: stock.changePercent),
              ],
            ),
            const SizedBox(width: AppTokens.space2),
            SparklineMiniChart(
              values: stock.sparklinePoints,
              isPositive: stock.changePercent >= 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.symbol,
  });

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hue = symbol.codeUnits.fold<int>(0, (sum, c) => sum + c) % 360;
    final bg = HSVColor.fromAHSV(1, hue.toDouble(), 0.65, 0.95).toColor();
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg.withValues(alpha: 0.14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Center(
        child: Text(
          symbol.isEmpty ? '?' : symbol.substring(0, 1),
          style: TextStyle(
            color: bg,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
