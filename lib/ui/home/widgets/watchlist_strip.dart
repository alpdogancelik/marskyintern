import 'package:flutter/material.dart';

import '../../../features/coins/domain/entities/coin.dart';
import '../../kit/coin_avatar.dart';
import '../../kit/trend_chip.dart';
import '../../theme/app_tokens.dart';

class WatchlistStrip extends StatelessWidget {
  const WatchlistStrip({
    super.key,
    required this.coins,
    required this.onTapCoin,
    required this.onSeeAll,
  });

  final List<Coin> coins;
  final ValueChanged<Coin> onTapCoin;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Watchlist',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space2),
        if (coins.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTokens.space4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              'No favorites yet. Tap the star on any coin to add to your watchlist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: coins.length.clamp(0, 6),
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTokens.space3),
              itemBuilder: (context, index) {
                final coin = coins[index];
                return _WatchlistCard(
                  coin: coin,
                  onTap: () => onTapCoin(coin),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  const _WatchlistCard({
    required this.coin,
    required this.onTap,
  });

  final Coin coin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(AppTokens.space3),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CoinAvatar(symbol: coin.symbol, size: 24),
                const SizedBox(width: AppTokens.space2),
                Expanded(
                  child: Text(
                    coin.symbol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '\$${coin.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            TrendChip(change: coin.change),
          ],
        ),
      ),
    );
  }
}
