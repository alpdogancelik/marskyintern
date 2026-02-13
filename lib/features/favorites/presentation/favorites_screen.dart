import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/coin_logo.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/ui/error_presenter.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../coins/data/coins_repository_impl.dart';
import '../../coins/domain/entities/coin.dart';
import '../../coins/presentation/coin_details_sheet.dart';
import '../../coins/presentation/home_controller.dart';
import 'favorites_controller.dart';

final favoriteCoinsProvider = FutureProvider<List<Coin>>((ref) async {
  final favoriteIds = ref.watch(favoritesControllerProvider).valueOrNull ?? const <String>{};
  if (favoriteIds.isEmpty) {
    return const <Coin>[];
  }

  final cachedCoins = ref.watch(homeControllerProvider).valueOrNull?.items ?? const <Coin>[];
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
      next.whenOrNull(error: (error, _) => showAppErrorSnackBar(context, error));
    });

    final favoriteIds = ref.watch(favoritesControllerProvider).valueOrNull ?? const <String>{};
    final favoriteCoins = ref.watch(favoriteCoinsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () => _confirmLogout(context, ref),
            icon: const AppIcon(
              name: 'lock',
              semanticLabel: 'Log out',
              size: 20,
              tone: AppIconTone.danger,
            ),
          ),
        ],
      ),
      body: favoriteIds.isEmpty
          ? EmptyState(
              title: 'Portfolio is empty',
              description:
                  'Add funds and buy your first asset to start tracking holdings.',
              illustrationName: 'woman-is-looking-at-her-bank-account-statistics',
              primaryAction: EmptyStateAction(
                label: 'Buy first asset',
                iconName: 'card-payment',
                onPressed: () => context.go('/app/home'),
              ),
            )
          : favoriteCoins.when(
              data: (coins) {
                if (coins.isEmpty) {
                  return EmptyState(
                    title: 'Portfolio is empty',
                    description:
                        'Add funds and buy your first asset to start tracking holdings.',
                    illustrationName: 'woman-is-looking-at-her-bank-account-statistics',
                    primaryAction: EmptyStateAction(
                      label: 'Buy first asset',
                      iconName: 'card-payment',
                      onPressed: () => context.go('/app/home'),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: coins.length,
                  itemBuilder: (context, index) {
                    final coin = coins[index];
                    return ListTile(
                      onTap: () => showCoinDetailSheet(context, coin),
                      leading: CoinLogo(
                        symbol: coin.symbol,
                        size: 32,
                        semanticLabel: '${coin.symbol} logo',
                      ),
                      title: Text(coin.name),
                      subtitle: Text('${coin.symbol} - #${coin.rank}'),
                      trailing: IconButton(
                        tooltip: 'Remove from portfolio',
                        onPressed: () => _toggleFavorite(context, ref, coin.uuid),
                        icon: const Icon(Icons.star),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: ElevatedButton(
                  onPressed: () => ref.invalidate(favoriteCoinsProvider),
                  child: const Text('Retry loading favorites'),
                ),
              ),
            ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref, String uuid) async {
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
          ElevatedButton(
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
