import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/env.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../data/repositories.dart';
import '../data/supabase_coins_repository.dart';
import '../domain/coins_repository.dart';
import '../domain/entities/coin.dart';

const _pageSize = 20;
const sortOrderByOptions = <String>[
  'price',
  'marketCap',
  '24hVolume',
  'change',
  'listedAt',
];

class HomePagingState {
  const HomePagingState({
    required this.items,
    required this.offset,
    required this.limit,
    required this.hasMore,
    required this.isLoadingMore,
    required this.currentSort,
    required this.orderBy,
    required this.isAscending,
    required this.marketFilter,
    required this.favoriteIds,
    this.loadMoreError,
  });

  final List<Coin> items;
  final int offset;
  final int limit;
  final bool hasMore;
  final bool isLoadingMore;
  final String currentSort;
  final String orderBy;
  final bool isAscending;
  final MarketFilter marketFilter;
  final Set<String> favoriteIds;
  final Object? loadMoreError;

  HomePagingState copyWith({
    List<Coin>? items,
    int? offset,
    int? limit,
    bool? hasMore,
    bool? isLoadingMore,
    String? currentSort,
    String? orderBy,
    bool? isAscending,
    MarketFilter? marketFilter,
    Set<String>? favoriteIds,
    Object? loadMoreError = _sentinel,
  }) {
    return HomePagingState(
      items: items ?? this.items,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentSort: currentSort ?? this.currentSort,
      orderBy: orderBy ?? this.orderBy,
      isAscending: isAscending ?? this.isAscending,
      marketFilter: marketFilter ?? this.marketFilter,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      loadMoreError: identical(loadMoreError, _sentinel)
          ? this.loadMoreError
          : loadMoreError,
    );
  }
}

const Object _sentinel = Object();

final homeControllerProvider =
    StateNotifierProvider<HomeController, AsyncValue<HomePagingState>>((ref) {
  final repository = ref.watch(coinsRepositoryProvider);
  final useRealtimeCache =
      Env.useSupabaseCoinsCache && SupabaseConfig.isInitialized;
  final realtimeRepository =
      useRealtimeCache ? ref.watch(supabaseCoinsRepositoryProvider) : null;
  final controller = HomeController(
    repository,
    realtimeRepository: realtimeRepository,
  )..loadFirstPage();
  ref.listen<AsyncValue<Set<String>>>(favoritesControllerProvider,
      (previous, next) {
    controller.setFavorites(next.valueOrNull ?? const <String>{});
  });
  return controller;
});

class HomeController extends StateNotifier<AsyncValue<HomePagingState>> {
  HomeController(
    this._repository, {
    SupabaseCoinsRepository? realtimeRepository,
  })  : _realtimeRepository = realtimeRepository,
        super(const AsyncLoading());

  final CoinsRepository _repository;
  final SupabaseCoinsRepository? _realtimeRepository;
  StreamSubscription<List<Coin>>? _realtimeSubscription;
  Set<String> _pendingFavoriteIds = const <String>{};
  static const _defaultOrderBy = 'marketCap';
  static const _defaultIsAscending = false;
  static const _defaultMarketFilter = MarketFilter.all;
  bool get _isRealtimeEnabled => _realtimeRepository != null;

  Future<void> loadFirstPage({
    String? orderBy,
    bool? isAscending,
  }) async {
    final current = state.valueOrNull;
    final selectedOrderBy = orderBy ?? current?.orderBy ?? _defaultOrderBy;
    final selectedIsAscending =
        isAscending ?? current?.isAscending ?? _defaultIsAscending;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final items = await (_isRealtimeEnabled
          ? _realtimeRepository!.fetchCoinsOnce()
          : _repository.getCoins(
              limit: _pageSize,
              offset: 0,
              orderBy: selectedOrderBy,
              orderDirection: selectedIsAscending ? 'asc' : 'desc',
            ));
      final sortedItems = _sortItems(
        items,
        orderBy: selectedOrderBy,
        isAscending: selectedIsAscending,
      );
      final direction = selectedIsAscending ? 'asc' : 'desc';
      _subscribeRealtimeIfNeeded();
      return HomePagingState(
        items: sortedItems,
        offset: sortedItems.length,
        limit: _pageSize,
        hasMore: !_isRealtimeEnabled && sortedItems.length == _pageSize,
        isLoadingMore: false,
        currentSort: '$selectedOrderBy:$direction',
        orderBy: selectedOrderBy,
        isAscending: selectedIsAscending,
        marketFilter: current?.marketFilter ?? _defaultMarketFilter,
        favoriteIds: current?.favoriteIds ?? _pendingFavoriteIds,
      );
    });
  }

  Future<void> loadInitial({
    String? orderBy,
    bool? isAscending,
  }) =>
      loadFirstPage(orderBy: orderBy, isAscending: isAscending);

  Future<void> refresh() => loadFirstPage();

  Future<void> updateSort({
    required String orderBy,
    required bool isAscending,
  }) async {
    if (_isRealtimeEnabled) {
      final current = state.valueOrNull;
      if (current != null) {
        final direction = isAscending ? 'asc' : 'desc';
        state = AsyncData(
          current.copyWith(
            items: _sortItems(
              current.items,
              orderBy: orderBy,
              isAscending: isAscending,
            ),
            orderBy: orderBy,
            isAscending: isAscending,
            currentSort: '$orderBy:$direction',
            hasMore: false,
            offset: current.items.length,
          ),
        );
        return;
      }
    }
    await loadFirstPage(orderBy: orderBy, isAscending: isAscending);
  }

  Future<void> setSortDirection(bool isAscending) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await loadFirstPage(orderBy: current.orderBy, isAscending: isAscending);
  }

  void setMarketFilter(MarketFilter filter) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(marketFilter: filter));
  }

  void setFavorites(Set<String> favoriteIds) {
    final current = state.valueOrNull;
    if (current == null) {
      _pendingFavoriteIds = favoriteIds;
      return;
    }
    _pendingFavoriteIds = favoriteIds;
    state = AsyncData(current.copyWith(favoriteIds: favoriteIds));
  }

  Future<void> loadNextPageIfNeeded() async {
    final current = state.valueOrNull;
    if (_isRealtimeEnabled ||
        current == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreError: null),
    );

    try {
      final nextPage = await _repository.getCoins(
        limit: current.limit,
        offset: current.offset,
        orderBy: current.orderBy,
        orderDirection: current.isAscending ? 'asc' : 'desc',
      );

      final knownIds = current.items.map((coin) => coin.uuid).toSet();
      final uniqueNewItems =
          nextPage.where((coin) => !knownIds.contains(coin.uuid)).toList();

      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...uniqueNewItems],
          offset: current.offset + nextPage.length,
          hasMore: nextPage.length == current.limit,
          isLoadingMore: false,
          loadMoreError: null,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          isLoadingMore: false,
          loadMoreError: error,
        ),
      );
    }
  }

  void _subscribeRealtimeIfNeeded() {
    if (!_isRealtimeEnabled || _realtimeSubscription != null) {
      return;
    }
    _realtimeSubscription = _realtimeRepository!.watchCoins().listen(
      (items) {
        final current = state.valueOrNull;
        final orderBy = current?.orderBy ?? _defaultOrderBy;
        final isAscending = current?.isAscending ?? _defaultIsAscending;
        final direction = isAscending ? 'asc' : 'desc';
        state = AsyncData(
          HomePagingState(
            items: _sortItems(
              items,
              orderBy: orderBy,
              isAscending: isAscending,
            ),
            offset: items.length,
            limit: _pageSize,
            hasMore: false,
            isLoadingMore: false,
            currentSort: '$orderBy:$direction',
            orderBy: orderBy,
            isAscending: isAscending,
            marketFilter: current?.marketFilter ?? _defaultMarketFilter,
            favoriteIds: current?.favoriteIds ?? _pendingFavoriteIds,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
  }

  List<Coin> _sortItems(
    List<Coin> input, {
    required String orderBy,
    required bool isAscending,
  }) {
    final items = [...input];
    final direction = isAscending ? 1 : -1;
    items.sort((a, b) {
      final comparison = switch (orderBy) {
        'price' => a.price.compareTo(b.price),
        '24hVolume' => a.volume24h.compareTo(b.volume24h),
        'change' => a.change.compareTo(b.change),
        'listedAt' => (a.listedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(b.listedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        _ => a.marketCap.compareTo(b.marketCap),
      };
      return comparison * direction;
    });
    return items;
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadMore() => loadNextPageIfNeeded();
}

enum MarketFilter { all, gainers, losers }
