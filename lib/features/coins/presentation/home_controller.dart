import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/coins_repository_impl.dart';
import '../domain/coins_repository.dart';
import '../domain/entities/coin.dart';
import '../../favorites/presentation/favorites_controller.dart';

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
  final controller = HomeController(repository)..loadFirstPage();
  ref.listen<AsyncValue<Set<String>>>(favoritesControllerProvider,
      (previous, next) {
    controller.setFavorites(next.valueOrNull ?? const <String>{});
  });
  return controller;
});

class HomeController extends StateNotifier<AsyncValue<HomePagingState>> {
  HomeController(this._repository) : super(const AsyncLoading());

  final CoinsRepository _repository;
  Set<String> _pendingFavoriteIds = const <String>{};
  static const _defaultOrderBy = 'marketCap';
  static const _defaultIsAscending = false;
  static const _defaultMarketFilter = MarketFilter.all;

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
      final items = await _repository.getCoins(
        limit: _pageSize,
        offset: 0,
        orderBy: selectedOrderBy,
        orderDirection: selectedIsAscending ? 'asc' : 'desc',
      );
      final direction = selectedIsAscending ? 'asc' : 'desc';
      return HomePagingState(
        items: items,
        offset: items.length,
        limit: _pageSize,
        hasMore: items.length == _pageSize,
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
    if (current == null || !current.hasMore || current.isLoadingMore) {
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

  Future<void> loadMore() => loadNextPageIfNeeded();
}

enum MarketFilter { all, gainers, losers }
