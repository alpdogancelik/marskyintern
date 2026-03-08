import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui/error_presenter.dart';
import '../../core/widgets/app_icon.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/coins/domain/entities/coin.dart';
import '../../features/coins/presentation/coin_details_sheet.dart';
import '../../features/coins/presentation/home_controller.dart';
import '../../features/favorites/presentation/favorites_controller.dart';
import '../kit/ui_kit.dart';
import '../theme/app_tokens.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _prefetchThreshold = 6;

  @override
  Widget build(BuildContext context) {
    ref.listen(homeControllerProvider, (previous, next) {
      final previousLoadMoreError = previous?.valueOrNull?.loadMoreError;
      final nextLoadMoreError = next.valueOrNull?.loadMoreError;
      if (nextLoadMoreError != null &&
          nextLoadMoreError != previousLoadMoreError) {
        showAppErrorSnackBar(context, nextLoadMoreError);
      }

      next.whenOrNull(
        error: (error, _) => showAppErrorSnackBar(context, error),
      );
    });

    ref.listen(favoritesControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => showAppErrorSnackBar(context, error),
      );
    });

    final homeState = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: homeState.when(
          loading: () => _HomeLoadingSkeleton(
            onTapSearch: _openMarket,
            onTapNotifications: _openNotifications,
            onTapLogout: _confirmLogout,
          ),
          error: (error, _) => _HomeErrorState(
            error: error,
            onRetry: _refresh,
            onTapSearch: _openMarket,
            onTapNotifications: _openNotifications,
            onTapLogout: _confirmLogout,
          ),
          data: (value) => _HomeContent(
            data: value,
            onRefresh: _refresh,
            onTapSearch: _openMarket,
            onTapNotifications: _openNotifications,
            onTapLogout: _confirmLogout,
            onOpenCoin: _openCoin,
            onToggleFavorite: _toggleFavorite,
            onDeposit: () => context.push('/wallet/topup'),
            onWithdraw: () => context.push('/wallet/withdraw'),
            onLoadMore: _loadMoreIfNeeded,
            onForceLoadMore: _forceLoadMore,
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() {
    return ref.read(homeControllerProvider.notifier).refresh();
  }

  Future<void> _confirmLogout() async {
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

    if (shouldLogout != true) {
      return;
    }
    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppErrorSnackBar(context, error);
    }
  }

  Future<void> _toggleFavorite(String uuid) async {
    try {
      await ref.read(favoritesControllerProvider.notifier).toggle(uuid);
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppErrorSnackBar(context, error);
    }
  }

  void _openCoin(Coin coin) {
    showCoinDetailSheet(context, coin);
  }

  Future<void> _loadMoreIfNeeded({
    required HomePagingState data,
    required int index,
    required int listLength,
  }) async {
    if (data.isLoadingMore || !data.hasMore) {
      return;
    }
    if (index < listLength - _prefetchThreshold) {
      return;
    }
    await ref.read(homeControllerProvider.notifier).loadNextPageIfNeeded();
  }

  Future<void> _forceLoadMore(HomePagingState data) async {
    if (data.isLoadingMore || !data.hasMore) {
      return;
    }
    await ref.read(homeControllerProvider.notifier).loadNextPageIfNeeded();
  }

  void _openMarket() {
    context.push('/market');
  }

  void _openNotifications() {
    context.push('/notifications');
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.onRefresh,
    required this.onTapSearch,
    required this.onTapNotifications,
    required this.onTapLogout,
    required this.onOpenCoin,
    required this.onToggleFavorite,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onLoadMore,
    required this.onForceLoadMore,
  });

  final HomePagingState data;
  final Future<void> Function() onRefresh;
  final VoidCallback onTapSearch;
  final VoidCallback onTapNotifications;
  final Future<void> Function() onTapLogout;
  final ValueChanged<Coin> onOpenCoin;
  final ValueChanged<String> onToggleFavorite;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final Future<void> Function({
    required HomePagingState data,
    required int index,
    required int listLength,
  }) onLoadMore;
  final Future<void> Function(HomePagingState data) onForceLoadMore;

  @override
  Widget build(BuildContext context) {
    final favoriteCoins = data.items
        .where((coin) => data.favoriteIds.contains(coin.uuid))
        .take(4)
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.pageHorizontalPadding,
              AppTokens.space3,
              AppTokens.pageHorizontalPadding,
              AppTokens.space4,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    leading: const _HomeBrandMark(),
                    title: 'Kora',
                    trailing: _HomeActions(
                      onTapSearch: onTapSearch,
                      onTapNotifications: onTapNotifications,
                      onTapLogout: onTapLogout,
                    ),
                  ),
                  const SizedBox(height: AppTokens.sectionGapMd),
                  _PortfolioCard(
                    total: _estimatedPortfolioValue(data.items),
                    onDeposit: onDeposit,
                    onWithdraw: onWithdraw,
                  ),
                  const SizedBox(height: AppTokens.sectionGapLg),
                  SectionHeader(
                    title: 'Favorites',
                    actionLabel: 'See all',
                    onActionTap: () => context.go('/app/favorites'),
                  ),
                  const SizedBox(height: AppTokens.space2),
                  _FavoritesMiniRow(
                    coins: favoriteCoins,
                    onTapCoin: onOpenCoin,
                  ),
                  const SizedBox(height: AppTokens.sectionGapLg),
                  SectionHeader(
                    title: 'Live Prices',
                    actionLabel: 'Market',
                    onActionTap: onTapSearch,
                  ),
                  const SizedBox(height: AppTokens.space2),
                ],
              ),
            ),
          ),
          if (data.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No coins available right now.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppTokens.space3),
                      PrimaryButton(
                        label: 'Retry',
                        onPressed: onRefresh,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pageHorizontalPadding,
                0,
                AppTokens.pageHorizontalPadding,
                AppTokens.space6,
              ),
              sliver: SliverList.separated(
                itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppTokens.space3),
                itemBuilder: (context, index) {
                  if (index >= data.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (index >= data.items.length - 1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onLoadMore(
                        data: data,
                        index: index,
                        listLength: data.items.length,
                      );
                    });
                  }

                  final coin = data.items[index];
                  return CoinRow(
                    name: coin.name,
                    symbol: coin.symbol,
                    iconUrl: coin.iconUrl,
                    priceText: _formatCurrency(coin.price),
                    changePercent: coin.change,
                    sparkline: _buildSparkline(coin),
                    onTap: () => onOpenCoin(coin),
                    trailing: IconButton(
                      tooltip: data.favoriteIds.contains(coin.uuid)
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      onPressed: () => onToggleFavorite(coin.uuid),
                      icon: Icon(
                        data.favoriteIds.contains(coin.uuid)
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: data.favoriteIds.contains(coin.uuid)
                            ? const Color(0xFFFFB545)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (!data.isLoadingMore && data.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.pageHorizontalPadding,
                  0,
                  AppTokens.pageHorizontalPadding,
                  AppTokens.space6,
                ),
                child: SecondaryButton(
                  label: 'Load More',
                  onPressed: () => onForceLoadMore(data),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _estimatedPortfolioValue(List<Coin> coins) {
    if (coins.isEmpty) {
      return 0;
    }
    return coins.take(4).fold<double>(0, (sum, coin) => sum + coin.price);
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({
    required this.total,
    required this.onDeposit,
    required this.onWithdraw,
  });

  final double total;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'My Portfolio',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            _formatCurrency(total),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space4),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Deposit',
                  leading: const Icon(Icons.south_west_rounded, size: 18),
                  onPressed: onDeposit,
                ),
              ),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: SecondaryButton(
                  label: 'Withdraw',
                  leading: const Icon(Icons.north_east_rounded, size: 18),
                  onPressed: onWithdraw,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavoritesMiniRow extends StatelessWidget {
  const _FavoritesMiniRow({
    required this.coins,
    required this.onTapCoin,
  });

  final List<Coin> coins;
  final ValueChanged<Coin> onTapCoin;

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTokens.space4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          'No favorites yet. Tap the star on a coin to add it.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: coins.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTokens.space3),
        itemBuilder: (context, index) {
          final coin = coins[index];
          final isPositive = coin.change >= 0;
          return InkWell(
            onTap: () => onTapCoin(coin),
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            child: SizedBox(
              width: 156,
              child: AppCard(
                padding: const EdgeInsets.all(AppTokens.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CoinAvatar(
                          symbol: coin.symbol,
                          iconUrl: coin.iconUrl,
                          size: 24,
                          semanticLabel: '${coin.symbol} icon',
                        ),
                        const SizedBox(width: AppTokens.space2),
                        Expanded(
                          child: Text(
                            coin.symbol,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space2),
                    SizedBox(
                      height: 28,
                      child: CustomPaint(
                        painter: _MiniSparklinePainter(
                          points: _buildSparkline(coin, points: 16),
                          color:
                              isPositive ? AppTokens.success : AppTokens.danger,
                        ),
                        size: const Size(double.infinity, 28),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatCurrency(coin.price),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeBrandMark extends StatelessWidget {
  const _HomeBrandMark();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: AppTokens.minTapTarget,
      height: AppTokens.minTapTarget,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: const Center(
        child: AppIcon(
          name: 'digital-token',
          semanticLabel: 'App mark',
          size: 24,
        ),
      ),
    );
  }
}

class _HomeActions extends StatelessWidget {
  const _HomeActions({
    required this.onTapSearch,
    required this.onTapNotifications,
    required this.onTapLogout,
  });

  final VoidCallback onTapSearch;
  final VoidCallback onTapNotifications;
  final Future<void> Function() onTapLogout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTapSearch,
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search market',
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            minimumSize: const Size(44, 44),
            side: BorderSide(color: colors.outlineVariant),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onTapNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            minimumSize: const Size(44, 44),
            side: BorderSide(color: colors.outlineVariant),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => onTapLogout(),
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Log out',
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            minimumSize: const Size(44, 44),
            side: BorderSide(color: colors.outlineVariant),
          ),
        ),
      ],
    );
  }
}

class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton({
    required this.onTapSearch,
    required this.onTapNotifications,
    required this.onTapLogout,
  });

  final VoidCallback onTapSearch;
  final VoidCallback onTapNotifications;
  final Future<void> Function() onTapLogout;

  @override
  Widget build(BuildContext context) {
    final skeletonColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pageHorizontalPadding,
            AppTokens.space3,
            AppTokens.pageHorizontalPadding,
            AppTokens.space4,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTopBar(
                  leading: const _HomeBrandMark(),
                  title: 'Kora',
                  trailing: _HomeActions(
                    onTapSearch: onTapSearch,
                    onTapNotifications: onTapNotifications,
                    onTapLogout: onTapLogout,
                  ),
                ),
                const SizedBox(height: AppTokens.space5),
                Container(
                  height: 146,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                    color: skeletonColor,
                  ),
                ),
                const SizedBox(height: AppTokens.space5),
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  ),
                ),
                const SizedBox(height: AppTokens.space6),
                ...List.generate(
                  4,
                  (_) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space3),
                    child: Container(
                      height: 82,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({
    required this.error,
    required this.onRetry,
    required this.onTapSearch,
    required this.onTapNotifications,
    required this.onTapLogout,
  });

  final Object error;
  final Future<void> Function() onRetry;
  final VoidCallback onTapSearch;
  final VoidCallback onTapNotifications;
  final Future<void> Function() onTapLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.pageHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            leading: const _HomeBrandMark(),
            title: 'Kora',
            trailing: _HomeActions(
              onTapSearch: onTapSearch,
              onTapNotifications: onTapNotifications,
              onTapLogout: onTapLogout,
            ),
          ),
          const Spacer(),
          AppCard(
            child: Column(
              children: [
                Text(
                  appErrorMessage(error),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTokens.space4),
                PrimaryButton(
                  label: 'Retry',
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  _MiniSparklinePainter({
    required this.points,
    required this.color,
  });

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final min = points.reduce(math.min);
    final max = points.reduce(math.max);
    final range = (max - min).abs() < 0.0001 ? 1.0 : (max - min);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final normalized = (points[i] - min) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.points != points;
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
