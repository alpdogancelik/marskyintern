import 'package:flutter/material.dart';

import '../../../features/coins/domain/entities/coin.dart';
import '../../kit/coin_avatar.dart';
import '../../kit/trend_chip.dart';
import '../../theme/app_tokens.dart';

class CoinMarketRow extends StatelessWidget {
  const CoinMarketRow({
    super.key,
    required this.coin,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final Coin coin;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

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
            CoinAvatar(symbol: coin.symbol, size: 32),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${coin.symbol}  •  #${coin.rank}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTokens.space3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${coin.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                TrendChip(change: coin.change),
              ],
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: onToggleFavorite,
              tooltip:
                  isFavorite ? 'Remove from watchlist' : 'Add to watchlist',
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite
                    ? const Color(0xFFFFB545)
                    : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
