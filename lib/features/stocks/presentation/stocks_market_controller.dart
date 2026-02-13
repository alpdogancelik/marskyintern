import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_stocks_repository.dart';
import '../domain/entities/stock.dart';
import '../domain/stocks_repository.dart';

const stocksPageSize = 20;

class StocksMarketState {
  const StocksMarketState({
    required this.items,
    required this.offset,
    required this.hasMore,
    required this.isLoadingMore,
    required this.sortBy,
    required this.ascending,
    this.sector,
    this.loadMoreError,
  });

  final List<Stock> items;
  final int offset;
  final bool hasMore;
  final bool isLoadingMore;
  final StockSortBy sortBy;
  final bool ascending;
  final String? sector;
  final Object? loadMoreError;

  StocksMarketState copyWith({
    List<Stock>? items,
    int? offset,
    bool? hasMore,
    bool? isLoadingMore,
    StockSortBy? sortBy,
    bool? ascending,
    String? sector,
    Object? loadMoreError = _sentinel,
  }) {
    return StocksMarketState(
      items: items ?? this.items,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      sector: sector ?? this.sector,
      loadMoreError: identical(loadMoreError, _sentinel)
          ? this.loadMoreError
          : loadMoreError,
    );
  }
}

const Object _sentinel = Object();

final stocksMarketControllerProvider = StateNotifierProvider.autoDispose<
    StocksMarketController, AsyncValue<StocksMarketState>>((ref) {
  final repository = ref.watch(stocksRepositoryProvider);
  return StocksMarketController(repository)..loadFirstPage();
});

class StocksMarketController
    extends StateNotifier<AsyncValue<StocksMarketState>> {
  StocksMarketController(this._repository) : super(const AsyncLoading());

  final StocksRepository _repository;

  Future<void> loadFirstPage({
    StockSortBy? sortBy,
    bool? ascending,
    String? sector,
  }) async {
    final current = state.valueOrNull;
    final selectedSort = sortBy ?? current?.sortBy ?? StockSortBy.marketCap;
    final selectedAscending = ascending ?? current?.ascending ?? false;
    final selectedSector = sector ?? current?.sector;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final items = await _repository.getStocks(
        limit: stocksPageSize,
        offset: 0,
        sortBy: selectedSort,
        ascending: selectedAscending,
        sector: selectedSector,
      );
      return StocksMarketState(
        items: items,
        offset: items.length,
        hasMore: items.length == stocksPageSize,
        isLoadingMore: false,
        sortBy: selectedSort,
        ascending: selectedAscending,
        sector: selectedSector,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }
    state =
        AsyncData(current.copyWith(isLoadingMore: true, loadMoreError: null));
    try {
      final next = await _repository.getStocks(
        limit: stocksPageSize,
        offset: current.offset,
        sortBy: current.sortBy,
        ascending: current.ascending,
        sector: current.sector,
      );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next],
          offset: current.offset + next.length,
          hasMore: next.length == stocksPageSize,
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

  Future<void> updateSort(StockSortBy sortBy, bool ascending) async {
    await loadFirstPage(sortBy: sortBy, ascending: ascending);
  }

  Future<void> updateSector(String? sector) async {
    await loadFirstPage(sector: sector);
  }
}

final stocksSectorsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final repository = ref.watch(stocksRepositoryProvider);
  return repository.getSectors();
});

final stocksHoldingsProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(stocksRepositoryProvider);
  return repository.getHoldings();
});

final stocksTransactionsProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(stocksRepositoryProvider);
  return repository.getTransactions();
});

final stockDetailProvider = FutureProvider.autoDispose.family<Stock, String>(
  (ref, symbol) async {
    final repository = ref.watch(stocksRepositoryProvider);
    return repository.getStockBySymbol(symbol);
  },
);

class StockChartRequest {
  const StockChartRequest({
    required this.symbol,
    required this.timeframe,
  });

  final String symbol;
  final StockTimeframe timeframe;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockChartRequest &&
        other.symbol == symbol &&
        other.timeframe == timeframe;
  }

  @override
  int get hashCode => Object.hash(symbol, timeframe);
}

final stockChartProvider =
    FutureProvider.autoDispose.family<List<double>, StockChartRequest>(
  (ref, request) async {
    final repository = ref.watch(stocksRepositoryProvider);
    return repository.getHistoricalSeries(
      request.symbol,
      timeframe: request.timeframe,
    );
  },
);
