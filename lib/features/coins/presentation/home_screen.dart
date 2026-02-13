import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/error_presenter.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/coin_logo.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/coins_repository_impl.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../domain/entities/coin.dart';
import 'coin_details_sheet.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _prefetchRemainingItems = 8;
  Coin? _smokeCoin;
  String _searchQuery = '';
  _MarketFilter _marketFilter = _MarketFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runCoinRankingSmokeTest();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeControllerProvider, (previous, next) {
      final previousLoadMoreError = previous?.valueOrNull?.loadMoreError;
      final nextLoadMoreError = next.valueOrNull?.loadMoreError;
      if (nextLoadMoreError != null &&
          nextLoadMoreError != previousLoadMoreError) {
        _showRetrySnackBar(nextLoadMoreError);
      }

      next.whenOrNull(
        error: (error, _) => _showRetrySnackBar(error),
      );
    });

    ref.listen(favoritesControllerProvider, (previous, next) {
      next.whenOrNull(
          error: (error, _) => showAppErrorSnackBar(context, error));
    });

    final homeState = ref.watch(homeControllerProvider);
    final favoriteIds =
        ref.watch(favoritesControllerProvider).valueOrNull ?? const <String>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Search coins',
            onPressed: _openSearchSheet,
            icon: const AppIcon(
              name: 'searching',
              semanticLabel: 'Search coins',
              size: 20,
              tone: AppIconTone.secondary,
            ),
          ),
          IconButton(
            tooltip: 'Filter list',
            onPressed: _openFilterSheet,
            icon: const AppIcon(
              name: 'scales',
              semanticLabel: 'Filter list',
              size: 20,
              tone: AppIconTone.secondary,
            ),
          ),
          IconButton(
            tooltip: 'Sort coins',
            onPressed: () => _openSortSheet(homeState.valueOrNull),
            icon: const AppIcon(
              name: 'chart-candle',
              semanticLabel: 'Sort coins',
              size: 20,
              tone: AppIconTone.secondary,
            ),
          ),
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
      body: homeState.when(
        data: (data) {
          final visibleItems = _applyMarketFilters(data.items);
          final isFiltering =
              _searchQuery.isNotEmpty || _marketFilter != _MarketFilter.all;

          if (data.items.isEmpty) {
            return Column(
              children: [
                if (_smokeCoin != null) _ApiSmokeTile(coin: _smokeCoin!),
                _SortChip(
                  orderBy: data.orderBy,
                  isAscending: data.isAscending,
                ),
                Expanded(
                  child: EmptyState(
                    title: 'No coins found',
                    description:
                        'Try refreshing to fetch the latest market data.',
                    illustrationName: 'managing-money',
                    primaryAction: EmptyStateAction(
                      label: 'Refresh',
                      onPressed: () =>
                          ref.read(homeControllerProvider.notifier).refresh(),
                    ),
                  ),
                ),
              ],
            );
          }

          if (visibleItems.isEmpty) {
            return EmptyState(
              title: 'No matching coins',
              description: 'Adjust search/filter options to broaden results.',
              illustrationName: 'woman-analyzes-different-currencies',
              primaryAction: EmptyStateAction(
                label: 'Clear filters',
                onPressed: () => setState(() {
                  _searchQuery = '';
                  _marketFilter = _MarketFilter.all;
                }),
              ),
            );
          }

          return Column(
            children: [
              if (_smokeCoin != null) _ApiSmokeTile(coin: _smokeCoin!),
              _SortChip(
                orderBy: data.orderBy,
                isAscending: data.isAscending,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(homeControllerProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount:
                        visibleItems.length + (data.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= visibleItems.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (!isFiltering &&
                          index >=
                              visibleItems.length - _prefetchRemainingItems) {
                        ref
                            .read(homeControllerProvider.notifier)
                            .loadNextPageIfNeeded();
                      }

                      final coin = visibleItems[index];
                      return _CoinRow(
                        coin: coin,
                        isFavorite: favoriteIds.contains(coin.uuid),
                        onFavoriteTap: () => _toggleFavorite(coin.uuid),
                        onTap: () => showCoinDetailSheet(context, coin),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Column(
          children: [
            if (_smokeCoin != null) _ApiSmokeTile(coin: _smokeCoin!),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
        error: (error, _) => Column(
          children: [
            if (_smokeCoin != null) _ApiSmokeTile(coin: _smokeCoin!),
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(homeControllerProvider.notifier).loadFirstPage(),
                  child: const Text('Retry loading coins'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Coin> _applyMarketFilters(List<Coin> items) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    return items.where((coin) {
      final queryMatches = normalizedQuery.isEmpty ||
          coin.name.toLowerCase().contains(normalizedQuery) ||
          coin.symbol.toLowerCase().contains(normalizedQuery);
      if (!queryMatches) {
        return false;
      }

      return switch (_marketFilter) {
        _MarketFilter.all => true,
        _MarketFilter.gainers => coin.change >= 0,
        _MarketFilter.losers => coin.change < 0,
      };
    }).toList();
  }

  Future<void> _runCoinRankingSmokeTest() async {
    try {
      final coins = await ref.read(coinsRepositoryProvider).getCoins(
            limit: 1,
            offset: 0,
            orderBy: 'marketCap',
            orderDirection: 'desc',
          );
      if (!mounted || coins.isEmpty) {
        return;
      }
      setState(() => _smokeCoin = coins.first);
    } catch (error) {
      if (!mounted) return;
      final message = appErrorMessage(error);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _runCoinRankingSmokeTest,
            ),
          ),
        );
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

  void _showRetrySnackBar(Object error) {
    final message = appErrorMessage(error);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              final state = ref.read(homeControllerProvider);
              if (state.hasValue && state.value!.items.isNotEmpty) {
                ref
                    .read(homeControllerProvider.notifier)
                    .loadNextPageIfNeeded();
              } else {
                ref.read(homeControllerProvider.notifier).loadFirstPage();
              }
            },
          ),
        ),
      );
  }

  Future<void> _openSortSheet(HomePagingState? state) async {
    final initialOrderBy = state?.orderBy ?? 'marketCap';
    final initialDirection = state?.isAscending ?? false;
    final result = await showModalBottomSheet<_SortSelection>(
      context: context,
      builder: (context) => _SortBottomSheet(
        initialOrderBy: initialOrderBy,
        initialAscending: initialDirection,
      ),
    );

    if (result == null || !mounted) return;
    await ref.read(homeControllerProvider.notifier).updateSort(
          orderBy: result.orderBy,
          isAscending: result.isAscending,
        );
  }

  Future<void> _openSearchSheet() async {
    final controller = TextEditingController(text: _searchQuery);
    final query = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search coins',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Type name or symbol',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) => Navigator.of(context).pop(value),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(controller.text),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || query == null) {
      return;
    }

    setState(() => _searchQuery = query.trim());
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<_MarketFilter>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioGroup<_MarketFilter>(
                groupValue: _marketFilter,
                onChanged: (value) => Navigator.of(context).pop(value),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<_MarketFilter>(
                      value: _MarketFilter.all,
                      title: Text('All coins'),
                    ),
                    RadioListTile<_MarketFilter>(
                      value: _MarketFilter.gainers,
                      title: Text('Only gainers'),
                    ),
                    RadioListTile<_MarketFilter>(
                      value: _MarketFilter.losers,
                      title: Text('Only losers'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() => _marketFilter = selected);
  }

  Future<void> _toggleFavorite(String uuid) async {
    final currentUser = ref.read(authControllerProvider).user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please log in to manage favorites.')),
        );
      return;
    }

    try {
      await ref.read(favoritesControllerProvider.notifier).toggle(uuid);
    } catch (error) {
      if (!mounted) return;
      showAppErrorSnackBar(context, error);
    }
  }
}

class _ApiSmokeTile extends StatelessWidget {
  const _ApiSmokeTile({required this.coin});

  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'API OK: ${coin.name} (${coin.symbol})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinRow extends StatelessWidget {
  const _CoinRow({
    required this.coin,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  final Coin coin;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final changeColor = coin.change >= 0 ? Colors.green : Colors.red;
    final changePrefix = coin.change >= 0 ? '+' : '';
    final trendIcon =
        coin.change >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    return ListTile(
      onTap: onTap,
      leading: CoinLogo(
        symbol: coin.symbol,
        size: 32,
        semanticLabel: '${coin.symbol} logo',
      ),
      title: Text(coin.name),
      subtitle: Text('${coin.symbol} - #${coin.rank}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${coin.price.toStringAsFixed(2)}'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      trendIcon,
                      size: 12,
                      color: changeColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$changePrefix${coin.change.toStringAsFixed(2)}%',
                    style: TextStyle(color: changeColor),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: onFavoriteTap,
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          ),
        ],
      ),
    );
  }
}

enum _MarketFilter { all, gainers, losers }

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.orderBy,
    required this.isAscending,
  });

  final String orderBy;
  final bool isAscending;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          label: Text(
            'Sort: $orderBy - ${isAscending ? 'asc' : 'desc'}',
          ),
        ),
      ),
    );
  }
}

class _SortSelection {
  const _SortSelection({
    required this.orderBy,
    required this.isAscending,
  });

  final String orderBy;
  final bool isAscending;
}

class _SortBottomSheet extends StatefulWidget {
  const _SortBottomSheet({
    required this.initialOrderBy,
    required this.initialAscending,
  });

  final String initialOrderBy;
  final bool initialAscending;

  @override
  State<_SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<_SortBottomSheet> {
  late String _orderBy = widget.initialOrderBy;
  late bool _isAscending = widget.initialAscending;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order By',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _orderBy,
              onChanged: (value) =>
                  setState(() => _orderBy = value ?? _orderBy),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sortOrderByOptions
                    .map(
                      (option) => RadioListTile<String>(
                        value: option,
                        dense: true,
                        title: Text(option),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isAscending,
              title: const Text('Ascending'),
              subtitle: Text(_isAscending ? 'asc' : 'desc'),
              onChanged: (value) => setState(() => _isAscending = value),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(
                  _SortSelection(orderBy: _orderBy, isAscending: _isAscending),
                ),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
