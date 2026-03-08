import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/error_presenter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../coins/data/repositories.dart';
import '../../coins/domain/entities/coin.dart';
import '../../coins/presentation/coin_details_sheet.dart';
import '../../coins/presentation/home_controller.dart';
import 'favorites_controller.dart';

final favoriteCoinsProvider = FutureProvider<List<Coin>>((ref) async {
  final favoriteIds =
      ref.watch(favoritesControllerProvider).valueOrNull ?? const <String>{};
  if (favoriteIds.isEmpty) {
    return const <Coin>[];
  }

  final cachedCoins =
      ref.watch(homeControllerProvider).valueOrNull?.items ?? const <Coin>[];
  final cachedById = <String, Coin>{
    for (final coin in cachedCoins) coin.uuid: coin,
  };

  final result = <Coin>[];
  final missingIds = <String>[];
  for (final id in favoriteIds) {
    final cached = cachedById[id];
    if (cached != null) {
      result.add(cached);
    } else {
      missingIds.add(id);
    }
  }

  if (missingIds.isEmpty) {
    return result;
  }

  final repository = ref.watch(coinsRepositoryProvider);
  final fetched = await Future.wait(
    missingIds.map(repository.getCoinByUuid),
  );
  return [...result, ...fetched];
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(favoriteCoinsProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => showAppErrorSnackBar(context, error),
      );
    });

    final favoriteIds =
        ref.watch(favoritesControllerProvider).valueOrNull ?? const <String>{};
    final favoriteCoins = ref.watch(favoriteCoinsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pageHorizontalPadding,
            AppTokens.space3,
            AppTokens.pageHorizontalPadding,
            0,
          ),
          child: Column(
            children: [
              AppTopBar(
                title: 'Favorites',
                trailing: IconButton(
                  tooltip: 'Log out',
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout_rounded),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(44, 44),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space3),
              Expanded(
                child: favoriteIds.isEmpty
                    ? EmptyState(
                        title: 'No favorites yet',
                        description:
                            'Tap the star icon on a coin to add it here.',
                        illustrationName: 'woman-analyzes-different-currencies',
                        primaryAction: EmptyStateAction(
                          label: 'Browse coins',
                          iconName: 'card-payment',
                          onPressed: () => context.go('/app/home'),
                        ),
                      )
                    : favoriteCoins.when(
                        data: (coins) {
                          if (coins.isEmpty) {
                            return EmptyState(
                              title: 'No favorites found',
                              description:
                                  'Some saved coins are unavailable. Refresh or update your selection.',
                              illustrationName:
                                  'woman-analyzes-different-currencies',
                              primaryAction: EmptyStateAction(
                                label: 'Browse coins',
                                iconName: 'card-payment',
                                onPressed: () => context.go('/app/home'),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(favoriteCoinsProvider);
                              await ref
                                  .read(homeControllerProvider.notifier)
                                  .refresh();
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.only(
                                bottom: AppTokens.space6,
                              ),
                              itemCount: coins.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppTokens.space3),
                              itemBuilder: (context, index) {
                                final coin = coins[index];
                                return CoinRow(
                                  name: coin.name,
                                  symbol: coin.symbol,
                                  iconUrl: coin.iconUrl,
                                  priceText: _formatCurrency(coin.price),
                                  changePercent: coin.change,
                                  sparkline: _buildSparkline(coin),
                                  onTap: () =>
                                      showCoinDetailSheet(context, coin),
                                  trailing: IconButton(
                                    tooltip: 'Remove from favorites',
                                    onPressed: () => _toggleFavorite(
                                        context, ref, coin.uuid),
                                    icon: const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFB545),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: PrimaryButton(
                            label: 'Retry loading favorites',
                            onPressed: () =>
                                ref.invalidate(favoriteCoinsProvider),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(
      BuildContext context, WidgetRef ref, String uuid) async {
    try {
      await ref.read(favoritesControllerProvider.notifier).toggle(uuid);
    } catch (error) {
      if (!context.mounted) return;
      showAppErrorSnackBar(context, error);
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } catch (error) {
      if (!context.mounted) return;
      showAppErrorSnackBar(context, error);
    }
  }
}

List<double> _buildSparkline(Coin coin, {int points = 12}) {
  final base = coin.price <= 0 ? 1.0 : coin.price;
  final vol = (coin.change.abs() / 100).clamp(0.02, 0.18);
  final trend = coin.change / 100;
  final phase = (coin.rank % 7) * 0.55;

  return List<double>.generate(points, (index) {
    final t = index / (points - 1);
    final wave = math.sin((t * 2 * math.pi) + phase) * vol;
    final slope = (t - 0.5) * trend * 0.8;
    final factor = (1 + wave + slope).clamp(0.2, 2.5);
    return base * factor;
  });
}

String _formatCurrency(double value) {
  final abs = value.abs();
  final decimals = abs >= 1000 ? 0 : 2;
  return '\$${value.toStringAsFixed(decimals)}';
}
