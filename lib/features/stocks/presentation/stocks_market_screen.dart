import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/error_presenter.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/stocks_repository.dart';
import '../widgets/sector_widgets.dart';
import '../widgets/stock_row.dart';
import 'stocks_market_controller.dart';

class StocksMarketScreen extends ConsumerStatefulWidget {
  const StocksMarketScreen({
    super.key,
    this.initialSector,
  });

  final String? initialSector;

  @override
  ConsumerState<StocksMarketScreen> createState() => _StocksMarketScreenState();
}

class _StocksMarketScreenState extends ConsumerState<StocksMarketScreen> {
  static const _prefetchThreshold = 5;

  @override
  void initState() {
    super.initState();
    if (widget.initialSector != null &&
        widget.initialSector!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(stocksMarketControllerProvider.notifier)
            .updateSector(widget.initialSector);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(stocksMarketControllerProvider, (previous, next) {
      final oldError = previous?.valueOrNull?.loadMoreError;
      final nextError = next.valueOrNull?.loadMoreError;
      if (nextError != null && nextError != oldError) {
        showAppErrorSnackBar(context, nextError);
      }
      next.whenOrNull(
          error: (error, _) => showAppErrorSnackBar(context, error));
    });

    final state = ref.watch(stocksMarketControllerProvider);
    final sectorsState = ref.watch(stocksSectorsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: state.when(
          loading: () => const _StocksLoadingView(),
          error: (error, _) => _StocksErrorView(
            errorMessage: appErrorMessage(error),
            onRetry: () => ref
                .read(stocksMarketControllerProvider.notifier)
                .loadFirstPage(),
          ),
          data: (data) {
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
                          leading: const _StocksMark(),
                          title: 'Stocks',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => context.push('/stocks/search'),
                                tooltip: 'Search stocks',
                                icon: const Icon(Icons.search_rounded),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTokens.space4),
                        InkWell(
                          onTap: () => context.push('/stocks/search'),
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusLg),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.space4,
                              vertical: AppTokens.space3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusLg),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, size: 20),
                                const SizedBox(width: AppTokens.space2),
                                Text(
                                  'Search stocks',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                const Icon(Icons.chevron_right_rounded,
                                    size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTokens.space5),
                        const _FeatureCardsRow(),
                        const SizedBox(height: AppTokens.space5),
                        Row(
                          children: [
                            Text(
                              'Sectors',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.push('/stocks/sectors'),
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.space2),
                        sectorsState.when(
                          data: (sectors) => SizedBox(
                            height: 48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: sectors.length + 1,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: AppTokens.space2),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return SectorChip(
                                    label: 'All',
                                    selected: data.sector == null,
                                    onTap: () => ref
                                        .read(stocksMarketControllerProvider
                                            .notifier)
                                        .updateSector(null),
                                  );
                                }
                                final sector = sectors[index - 1];
                                return SectorChip(
                                  label: sector,
                                  selected: data.sector == sector,
                                  onTap: () => ref
                                      .read(stocksMarketControllerProvider
                                          .notifier)
                                      .updateSector(sector),
                                );
                              },
                            ),
                          ),
                          loading: () => const SizedBox(
                            height: 48,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, __) => const SizedBox(height: 48),
                        ),
                        const SizedBox(height: AppTokens.space5),
                        Row(
                          children: [
                            Text(
                              'All Stocks',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const Spacer(),
                            AppChip(
                              label: _sortLabel(data.sortBy, data.ascending),
                              leading: const Icon(Icons.sort_rounded, size: 18),
                              onTap: () => _openSortSheet(context, data),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.space3),
                      ],
                    ),
                  ),
                ),
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
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (index >= data.items.length - _prefetchThreshold) {
                        ref
                            .read(stocksMarketControllerProvider.notifier)
                            .loadMore();
                      }

                      final stock = data.items[index];
                      return StockRow(
                        stock: stock,
                        onTap: () => context.push('/stocks/${stock.symbol}'),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openSortSheet(
      BuildContext context, StocksMarketState data) async {
    final result = await showModalBottomSheet<_StocksSortResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StocksSortSheet(
        initialSortBy: data.sortBy,
        initialAscending: data.ascending,
      ),
    );

    if (!mounted || result == null) {
      return;
    }
    await ref
        .read(stocksMarketControllerProvider.notifier)
        .updateSort(result.sortBy, result.ascending);
  }

  static String _sortLabel(StockSortBy sortBy, bool ascending) {
    final label = switch (sortBy) {
      StockSortBy.price => 'Price',
      StockSortBy.marketCap => 'Market Cap',
      StockSortBy.volume24h => '24h Volume',
      StockSortBy.change => 'Change',
      StockSortBy.listedAt => 'Listed',
    };
    return '$label ${ascending ? 'Asc' : 'Desc'}';
  }
}

class _StocksMark extends StatelessWidget {
  const _StocksMark();

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
          name: 'chart-candle',
          semanticLabel: 'Stocks mark',
          size: 24,
        ),
      ),
    );
  }
}

class _FeatureCardsRow extends StatelessWidget {
  const _FeatureCardsRow();

  @override
  Widget build(BuildContext context) {
    final cards =
        <({String title, String subtitle, String icon, String color})>[
      (
        title: 'Top Gainers',
        subtitle: 'Best today',
        icon: 'statistics-up',
        color: 'green',
      ),
      (
        title: 'Watchlist',
        subtitle: 'Your picks',
        icon: 'wallet',
        color: 'blue',
      ),
      (
        title: 'High Volume',
        subtitle: 'Most active',
        icon: 'chart-candle',
        color: 'purple',
      ),
    ];
    return SizedBox(
      height: 102,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTokens.space3),
        itemBuilder: (context, index) {
          final card = cards[index];
          final colors = Theme.of(context).colorScheme;
          final accent = switch (card.color) {
            'green' => const Color(0xFF12B56D),
            'blue' => const Color(0xFF4D8DFF),
            _ => colors.primary,
          };
          return Container(
            width: 160,
            padding: const EdgeInsets.all(AppTokens.space3),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: accent.withValues(alpha: 0.14),
                  child: AppIcon(
                    name: card.icon,
                    semanticLabel: card.title,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  card.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  card.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StocksLoadingView extends StatelessWidget {
  const _StocksLoadingView();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.all(AppTokens.pageHorizontalPadding),
      child: Column(
        children: [
          AppTopBar(
            leading: const _StocksMark(),
            title: 'Stocks',
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          Expanded(
            child: ListView.separated(
              itemCount: 8,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppTokens.space3),
              itemBuilder: (_, __) => Container(
                height: 76,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StocksErrorView extends StatelessWidget {
  const _StocksErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.pageHorizontalPadding),
      child: Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
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
      ),
    );
  }
}

class _StocksSortResult {
  const _StocksSortResult({
    required this.sortBy,
    required this.ascending,
  });

  final StockSortBy sortBy;
  final bool ascending;
}

class _StocksSortSheet extends StatefulWidget {
  const _StocksSortSheet({
    required this.initialSortBy,
    required this.initialAscending,
  });

  final StockSortBy initialSortBy;
  final bool initialAscending;

  @override
  State<_StocksSortSheet> createState() => _StocksSortSheetState();
}

class _StocksSortSheetState extends State<_StocksSortSheet> {
  late StockSortBy _sortBy = widget.initialSortBy;
  late bool _ascending = widget.initialAscending;

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
                'Sort Stocks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTokens.space4),
                  children: [
                    RadioGroup<StockSortBy>(
                      groupValue: _sortBy,
                      onChanged: (value) =>
                          setState(() => _sortBy = value ?? _sortBy),
                      child: const Column(
                        children: [
                          RadioListTile(
                            value: StockSortBy.price,
                            title: Text('Price'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile(
                            value: StockSortBy.marketCap,
                            title: Text('Market Cap'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile(
                            value: StockSortBy.volume24h,
                            title: Text('24h Volume'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile(
                            value: StockSortBy.change,
                            title: Text('Change'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile(
                            value: StockSortBy.listedAt,
                            title: Text('Listed At'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space2),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Desc'),
                          icon: Icon(Icons.north_rounded),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Asc'),
                          icon: Icon(Icons.south_rounded),
                        ),
                      ],
                      selected: {_ascending},
                      onSelectionChanged: (value) =>
                          setState(() => _ascending = value.first),
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
                    _StocksSortResult(sortBy: _sortBy, ascending: _ascending),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
