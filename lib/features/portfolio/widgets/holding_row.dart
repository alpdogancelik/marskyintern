import 'package:flutter/material.dart';

import '../../../ui/kit/coin_avatar.dart';
import '../../../ui/kit/trend_chip.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/holding.dart';
import 'portfolio_formatters.dart';

class HoldingRow extends StatelessWidget {
  const HoldingRow({
    super.key,
    required this.holding,
    this.onTap,
  });

  final Holding holding;
  final VoidCallback? onTap;

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
            CoinAvatar(symbol: holding.symbol, size: 32),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holding.symbol,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${holding.name} • ${formatQuantity(holding.quantity)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatUsd(holding.value),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                TrendChip(change: holding.pnlPercent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
