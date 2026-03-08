import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/error_presenter.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/coin.dart';
import '../../favorites/presentation/favorites_controller.dart';
import 'coin_details_sheet.dart';
import 'home_controller.dart';

class MarketListScreen extends ConsumerStatefulWidget {
  const MarketListScreen({super.key});

  @override
  ConsumerState<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends ConsumerState<MarketListScreen> {
  static const _prefetchThreshold = 6;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

    final state = ref.watch(homeControllerProvider);

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
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: PrimaryButton(
                label: 'Retry',
                onPressed: () =>
                    ref.read(homeControllerProvider.notifier).refresh(),
              ),
            ),
            data: (data) {
              final filtered = data.items.where((coin) {
                if (_query.isEmpty) {
                  return true;
                }
                final q = _query.toLowerCase();
                return coin.name.toLowerCase().contains(q) ||
                    coin.symbol.toLowerCase().contains(q);
              }).toList(growable: false);

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(homeControllerProvider.notifier).refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                              const SizedBox(width: AppTokens.space2),
                              Text(
                                'Market',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTokens.space2),
                          SearchField(
                            controller: _searchController,
                            hintText: 'Search company, stocks...',
                            onChanged: (value) =>
                                setState(() => _query = value),
                          ),
                          const SizedBox(height: AppTokens.space3),
                          Wrap(
                            spacing: AppTokens.space2,
                            runSpacing: AppTokens.space2,
                            children: [
                              _SortChip(
                                label: 'Market Cap',
                                selected: data.orderBy == 'marketCap',
                                onTap: () =>
                                    _setSort(orderBy: 'marketCap', data: data),
                              ),
                              _SortChip(
                                label: 'Price',
                                selected: data.orderBy == 'price',
                                onTap: () =>
                                    _setSort(orderBy: 'price', data: data),
                              ),
                              _SortChip(
                                label: '24h',
                                selected: data.orderBy == '24hVolume',
                                onTap: () =>
                                    _setSort(orderBy: '24hVolume', data: data),
                              ),
                              AppChip(
                                label: data.isAscending ? 'Asc' : 'Desc',
                                leading: Icon(
                                  data.isAscending
                                      ? Icons.south_rounded
                                      : Icons.north_rounded,
                                  size: 18,
                                ),
                                onTap: () => _setSort(
                                  orderBy: data.orderBy,
                                  data: data,
                                  ascending: !data.isAscending,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTokens.space3),
                        ],
                      ),
                    ),
                    if (filtered.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            _query.isEmpty
                                ? 'No coins available.'
                                : 'No results for "$_query".',
                          ),
                        ),
                      )
                    else
                      SliverList.separated(
                        itemCount:
                            filtered.length + (data.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppTokens.space3),
                        itemBuilder: (context, index) {
                          if (index >= filtered.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: AppTokens.space4),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (index >= filtered.length - 1 &&
                              _query.isEmpty &&
                              data.hasMore) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _loadMoreIfNeeded(
                                data: data,
                                index: index,
                                listLength: filtered.length,
                              );
                            });
                          }

                          final coin = filtered[index];
                          final favoriteIds = data.favoriteIds;
                          return CoinRow(
                            name: coin.name,
                            symbol: coin.symbol,
                            iconUrl: coin.iconUrl,
                            priceText: _formatCurrency(coin.price),
                            changePercent: coin.change,
                            sparkline: _buildSparkline(coin),
                            onTap: () => showCoinDetailSheet(context, coin),
                            trailing: IconButton(
                              tooltip: favoriteIds.contains(coin.uuid)
                                  ? 'Remove from favorites'
                                  : 'Add to favorites',
                              onPressed: () => _toggleFavorite(coin.uuid),
                              icon: Icon(
                                favoriteIds.contains(coin.uuid)
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: favoriteIds.contains(coin.uuid)
                                    ? const Color(0xFFFFB545)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTokens.space6),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
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

  Future<void> _setSort({
    required String orderBy,
    required HomePagingState data,
    bool? ascending,
  }) async {
    await ref.read(homeControllerProvider.notifier).updateSort(
          orderBy: orderBy,
          isAscending: ascending ?? data.isAscending,
        );
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
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: label,
      isActive: selected,
      onTap: onTap,
    );
  }
}

List<double> _buildSparkline(Coin coin, {int points = 12}) {
  final price = coin.price <= 0 ? 1.0 : coin.price;
  final change = coin.change;
  final rank = coin.rank;
  final vol = (change.abs() / 100).clamp(0.02, 0.18);

  return List<double>.generate(points, (index) {
    final t = index / (points - 1);
    final wave = math.sin((t * 2 * math.pi) + (rank % 7)) * vol;
    final slope = (t - 0.5) * (change / 100) * 0.8;
    final factor = (1 + wave + slope).clamp(0.2, 2.5);
    return price * factor;
  });
}

String _formatCurrency(double value) {
  final abs = value.abs();
  final decimals = abs >= 1000 ? 0 : 2;
  return '\$${value.toStringAsFixed(decimals)}';
}
