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
import 'widgets/coin_market_row.dart';
import 'widgets/quick_actions.dart';
import 'widgets/summary_card.dart';
import 'widgets/watchlist_strip.dart';

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
          error: (error, _) => showAppErrorSnackBar(context, error));
    });

    final homeState = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: homeState.when(
          loading: () => _HomeLoadingSkeleton(
            onTapLogout: _confirmLogout,
            onTapQuickAction: _handleQuickAction,
            onTapStocks: _openStocks,
            onTapMessages: _openMessages,
            onTapNotifications: _openNotifications,
            onTapAccount: _openAccount,
          ),
          error: (error, _) => _HomeErrorState(
            error: error,
            onRetry: () =>
                ref.read(homeControllerProvider.notifier).loadFirstPage(),
            onTapLogout: _confirmLogout,
            onTapStocks: _openStocks,
            onTapMessages: _openMessages,
            onTapNotifications: _openNotifications,
            onTapAccount: _openAccount,
          ),
          data: (value) => _HomeContent(
            data: value,
            onTapLogout: _confirmLogout,
            onTapStocks: _openStocks,
            onTapMessages: _openMessages,
            onTapNotifications: _openNotifications,
            onTapAccount: _openAccount,
            onOpenSort: _openSortSheet,
            onOpenFilter: _openFilterSheet,
            onToggleDirection: _toggleSortDirection,
            onTapQuickAction: _handleQuickAction,
            onOpenCoin: _openCoin,
            onToggleFavorite: _toggleFavorite,
            onLoadMore: _loadMoreIfNeeded,
            onForceLoadMore: _forceLoadMore,
          ),
        ),
      ),
    );
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

  Future<void> _openSortSheet(HomePagingState data) async {
    final result = await showModalBottomSheet<_SortSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SortSheet(
        initialOrderBy: data.orderBy,
        initialAscending: data.isAscending,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    await ref.read(homeControllerProvider.notifier).updateSort(
          orderBy: result.orderBy,
          isAscending: result.isAscending,
        );
  }

  Future<void> _openFilterSheet(HomePagingState data) async {
    final selected = await showModalBottomSheet<MarketFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(initialFilter: data.marketFilter),
    );

    if (!mounted || selected == null) {
      return;
    }

    ref.read(homeControllerProvider.notifier).setMarketFilter(selected);
  }

  Future<void> _toggleSortDirection(HomePagingState data) async {
    await ref
        .read(homeControllerProvider.notifier)
        .setSortDirection(!data.isAscending);
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

  void _handleQuickAction(String action) {
    final normalized = action.toLowerCase();
    if (normalized == 'buy') {
      context.push('/order/crypto?symbol=BTC');
      return;
    }
    if (normalized == 'wallet') {
      context.push('/wallet');
      return;
    }
    if (normalized == 'portfolio') {
      context.push('/portfolio');
      return;
    }
    if (normalized == 'history') {
      context.push('/activity');
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$action coming soon')));
  }

  void _openStocks() {
    context.push('/stocks');
  }

  void _openMessages() {
    context.push('/messages');
  }

  void _openNotifications() {
    context.push('/notifications');
  }

  void _openAccount() {
    context.push('/account');
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.onTapLogout,
    required this.onTapStocks,
    required this.onTapMessages,
    required this.onTapNotifications,
    required this.onTapAccount,
    required this.onOpenSort,
    required this.onOpenFilter,
    required this.onToggleDirection,
    required this.onTapQuickAction,
    required this.onOpenCoin,
    required this.onToggleFavorite,
    required this.onLoadMore,
    required this.onForceLoadMore,
  });

  final HomePagingState data;
  final Future<void> Function() onTapLogout;
  final VoidCallback onTapStocks;
  final VoidCallback onTapMessages;
  final VoidCallback onTapNotifications;
  final VoidCallback onTapAccount;
  final Future<void> Function(HomePagingState data) onOpenSort;
  final Future<void> Function(HomePagingState data) onOpenFilter;
  final Future<void> Function(HomePagingState data) onToggleDirection;
  final ValueChanged<String> onTapQuickAction;
  final ValueChanged<Coin> onOpenCoin;
  final ValueChanged<String> onToggleFavorite;
  final Future<void> Function({
    required HomePagingState data,
    required int index,
    required int listLength,
  }) onLoadMore;
  final Future<void> Function(HomePagingState data) onForceLoadMore;

  @override
  Widget build(BuildContext context) {
    final visibleCoins = _applyFilter(data.items, data.marketFilter);
    final watchlistCoins = data.items
        .where((coin) => data.favoriteIds.contains(coin.uuid))
        .toList(growable: false);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
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
                  title: 'Home',
                  trailing: _HomeActions(
                    onTapLogout: onTapLogout,
                    onTapStocks: onTapStocks,
                    onTapMessages: onTapMessages,
                    onTapNotifications: onTapNotifications,
                    onTapAccount: onTapAccount,
                  ),
                ),
                const SizedBox(height: AppTokens.space5),
                SummaryCard(
                  totalValueText: '\$56,890.00',
                  todayChange: 2.30,
                  onActionTap: () => onTapQuickAction('Scan QR'),
                  onCardTap: () => context.push('/wallet'),
                ),
                const SizedBox(height: AppTokens.space5),
                QuickActions(onActionTap: onTapQuickAction),
                const SizedBox(height: AppTokens.space6),
                WatchlistStrip(
                  coins: watchlistCoins,
                  onTapCoin: onOpenCoin,
                  onSeeAll: () => context.go('/app/favorites'),
                ),
                const SizedBox(height: AppTokens.space6),
                Row(
                  children: [
                    Text(
                      'Market',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/app/favorites'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space2),
                Wrap(
                  spacing: AppTokens.space2,
                  runSpacing: AppTokens.space2,
                  children: [
                    AppChip(
                      label: _sortLabel(data.orderBy),
                      leading: const Icon(Icons.sort_rounded, size: 18),
                      onTap: () => onOpenSort(data),
                    ),
                    AppChip(
                      label: _filterLabel(data.marketFilter),
                      leading: const Icon(Icons.filter_alt_outlined, size: 18),
                      onTap: () => onOpenFilter(data),
                      isActive: data.marketFilter != MarketFilter.all,
                    ),
                    AppChip(
                      label: data.isAscending ? 'Asc' : 'Desc',
                      leading: Icon(
                        data.isAscending
                            ? Icons.south_rounded
                            : Icons.north_rounded,
                        size: 18,
                      ),
                      onTap: () => onToggleDirection(data),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space3),
              ],
            ),
          ),
        ),
        if (visibleCoins.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.space6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No coins found for this filter.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (data.hasMore) ...[
                      const SizedBox(height: AppTokens.space3),
                      PrimaryButton(
                        label: data.isLoadingMore ? 'Loading...' : 'Load more',
                        onPressed: data.isLoadingMore
                            ? null
                            : () => onForceLoadMore(data),
                        isLoading: data.isLoadingMore,
                      ),
                    ],
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
              itemCount: visibleCoins.length + (data.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppTokens.space3),
              itemBuilder: (context, index) {
                if (index >= visibleCoins.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                onLoadMore(
                    data: data, index: index, listLength: visibleCoins.length);

                final coin = visibleCoins[index];
                return CoinMarketRow(
                  coin: coin,
                  isFavorite: data.favoriteIds.contains(coin.uuid),
                  onTap: () => onOpenCoin(coin),
                  onToggleFavorite: () => onToggleFavorite(coin.uuid),
                );
              },
            ),
          ),
      ],
    );
  }

  List<Coin> _applyFilter(List<Coin> coins, MarketFilter filter) {
    return switch (filter) {
      MarketFilter.all => coins,
      MarketFilter.gainers => coins.where((coin) => coin.change > 0).toList(),
      MarketFilter.losers => coins.where((coin) => coin.change < 0).toList(),
    };
  }

  static String _sortLabel(String orderBy) {
    return switch (orderBy) {
      'marketCap' => 'Market Cap',
      'price' => 'Price',
      '24hVolume' => '24h Volume',
      'change' => 'Change',
      'listedAt' => 'Listed At',
      _ => 'Sort',
    };
  }

  static String _filterLabel(MarketFilter filter) {
    return switch (filter) {
      MarketFilter.all => 'All',
      MarketFilter.gainers => 'Gainers',
      MarketFilter.losers => 'Losers',
    };
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
    required this.onTapLogout,
    required this.onTapStocks,
    required this.onTapMessages,
    required this.onTapNotifications,
    required this.onTapAccount,
  });

  final Future<void> Function() onTapLogout;
  final VoidCallback onTapStocks;
  final VoidCallback onTapMessages;
  final VoidCallback onTapNotifications;
  final VoidCallback onTapAccount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTapMessages,
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          tooltip: 'Messages',
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
          onPressed: onTapStocks,
          icon: const Icon(Icons.candlestick_chart_rounded),
          tooltip: 'Stocks (Beta)',
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            minimumSize: const Size(44, 44),
            side: BorderSide(color: colors.outlineVariant),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onTapAccount,
          icon: const Icon(Icons.person_outline_rounded),
          tooltip: 'Account & Setting',
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
    required this.onTapLogout,
    required this.onTapQuickAction,
    required this.onTapStocks,
    required this.onTapMessages,
    required this.onTapNotifications,
    required this.onTapAccount,
  });

  final Future<void> Function() onTapLogout;
  final ValueChanged<String> onTapQuickAction;
  final VoidCallback onTapStocks;
  final VoidCallback onTapMessages;
  final VoidCallback onTapNotifications;
  final VoidCallback onTapAccount;

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
                  title: 'Home',
                  trailing: _HomeActions(
                    onTapLogout: onTapLogout,
                    onTapStocks: onTapStocks,
                    onTapMessages: onTapMessages,
                    onTapNotifications: onTapNotifications,
                    onTapAccount: onTapAccount,
                  ),
                ),
                const SizedBox(height: AppTokens.space5),
                Container(
                  height: 188,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                    color: skeletonColor,
                  ),
                ),
                const SizedBox(height: AppTokens.space5),
                QuickActions(onActionTap: onTapQuickAction),
                const SizedBox(height: AppTokens.space6),
                Container(
                  height: 18,
                  width: 120,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                Container(
                  height: 120,
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
    required this.onTapLogout,
    required this.onTapStocks,
    required this.onTapMessages,
    required this.onTapNotifications,
    required this.onTapAccount,
  });

  final Object error;
  final VoidCallback onRetry;
  final Future<void> Function() onTapLogout;
  final VoidCallback onTapStocks;
  final VoidCallback onTapMessages;
  final VoidCallback onTapNotifications;
  final VoidCallback onTapAccount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.pageHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            leading: const _HomeBrandMark(),
            title: 'Home',
            trailing: _HomeActions(
              onTapLogout: onTapLogout,
              onTapStocks: onTapStocks,
              onTapMessages: onTapMessages,
              onTapNotifications: onTapNotifications,
              onTapAccount: onTapAccount,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppTokens.space5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
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

class _SortSheetResult {
  const _SortSheetResult({
    required this.orderBy,
    required this.isAscending,
  });

  final String orderBy;
  final bool isAscending;
}

class _SortSheet extends StatefulWidget {
  const _SortSheet({
    required this.initialOrderBy,
    required this.initialAscending,
  });

  final String initialOrderBy;
  final bool initialAscending;

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late String _orderBy = widget.initialOrderBy;
  late bool _isAscending = widget.initialAscending;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.42,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: AppTokens.space4),
              Text(
                'Sort Market',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppTokens.space2),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTokens.space4),
                  children: [
                    RadioGroup<String>(
                      groupValue: _orderBy,
                      onChanged: (value) =>
                          setState(() => _orderBy = value ?? _orderBy),
                      child: Column(
                        children: sortOrderByOptions
                            .map(
                              (option) => RadioListTile<String>(
                                value: option,
                                title: Text(_labelForSort(option)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space3),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Desc'),
                          icon: Icon(Icons.north_rounded, size: 18),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Asc'),
                          icon: Icon(Icons.south_rounded, size: 18),
                        ),
                      ],
                      selected: {_isAscending},
                      onSelectionChanged: (value) =>
                          setState(() => _isAscending = value.first),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTokens.space4,
                  AppTokens.space3,
                  AppTokens.space4,
                  AppTokens.space3 + bottomInset,
                ),
                child: PrimaryButton(
                  label: 'Apply',
                  onPressed: () => Navigator.of(context).pop(
                    _SortSheetResult(
                        orderBy: _orderBy, isAscending: _isAscending),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _labelForSort(String orderBy) {
    return switch (orderBy) {
      'price' => 'Price',
      'marketCap' => 'Market Cap',
      '24hVolume' => '24h Volume',
      'change' => 'Change',
      'listedAt' => 'Listed At',
      _ => orderBy,
    };
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initialFilter,
  });

  final MarketFilter initialFilter;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late MarketFilter _filter = widget.initialFilter;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.44,
      minChildSize: 0.34,
      maxChildSize: 0.7,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: AppTokens.space4),
              Text(
                'Filter Market',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppTokens.space2),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTokens.space4),
                  children: [
                    RadioGroup<MarketFilter>(
                      groupValue: _filter,
                      onChanged: (value) =>
                          setState(() => _filter = value ?? _filter),
                      child: const Column(
                        children: [
                          RadioListTile<MarketFilter>(
                            value: MarketFilter.all,
                            title: Text('All'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<MarketFilter>(
                            value: MarketFilter.gainers,
                            title: Text('Gainers'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<MarketFilter>(
                            value: MarketFilter.losers,
                            title: Text('Losers'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTokens.space4,
                  AppTokens.space3,
                  AppTokens.space4,
                  AppTokens.space3 + bottomInset,
                ),
                child: PrimaryButton(
                  label: 'Apply',
                  onPressed: () => Navigator.of(context).pop(_filter),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
