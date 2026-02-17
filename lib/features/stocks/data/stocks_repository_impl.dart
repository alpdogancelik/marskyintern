import '../../../core/errors/app_exception.dart';
import '../../coins/data/coin_history_api.dart';
import '../../coins/domain/coins_repository.dart';
import '../../coins/domain/entities/coin.dart';
import '../domain/entities/stock.dart';
import '../domain/entities/stock_holding.dart';
import '../domain/entities/stock_transaction.dart';
import '../domain/stocks_repository.dart';

class StocksRepositoryImpl implements StocksRepository {
  StocksRepositoryImpl({
    required CoinsRepository coinsRepository,
    required CoinHistoryApi coinHistoryApi,
  })  : _coinsRepository = coinsRepository,
        _coinHistoryApi = coinHistoryApi;

  final CoinsRepository _coinsRepository;
  final CoinHistoryApi _coinHistoryApi;

  @override
  Future<List<Stock>> getStocks({
    required int limit,
    required int offset,
    String? query,
    String? sector,
    StockSortBy sortBy = StockSortBy.marketCap,
    bool ascending = false,
  }) async {
    if (sector != null &&
        sector.trim().isNotEmpty &&
        sector.trim().toLowerCase() != 'crypto') {
      return const <Stock>[];
    }

    final normalizedQuery = query?.trim().toLowerCase() ?? '';
    final requiresLocalSearch = normalizedQuery.isNotEmpty;
    final fetchLimit = requiresLocalSearch ? 200 : limit;
    final fetchOffset = requiresLocalSearch ? 0 : offset;

    final coins = await _coinsRepository.getCoins(
      limit: fetchLimit,
      offset: fetchOffset,
      orderBy: _coinOrderBy(sortBy),
      orderDirection: ascending ? 'asc' : 'desc',
    );

    var stocks = coins.map(_toStock).toList(growable: false);
    if (requiresLocalSearch) {
      stocks = stocks
          .where((item) =>
              item.symbol.toLowerCase().contains(normalizedQuery) ||
              item.name.toLowerCase().contains(normalizedQuery))
          .toList(growable: false);
      if (offset >= stocks.length) {
        return const <Stock>[];
      }
      final end =
          (offset + limit) > stocks.length ? stocks.length : offset + limit;
      return stocks.sublist(offset, end);
    }
    return stocks;
  }

  @override
  Future<List<String>> getSectors() async {
    return const <String>['Crypto'];
  }

  @override
  Future<Stock> getStockBySymbol(String symbol) async {
    final normalized = symbol.trim().toUpperCase();
    final coins = await _coinsRepository.getCoins(
      limit: 200,
      offset: 0,
      orderBy: 'marketCap',
      orderDirection: 'desc',
    );
    for (final coin in coins) {
      if (coin.symbol.toUpperCase() == normalized) {
        return _toStock(coin);
      }
    }
    throw NotFoundException('Asset "$normalized" was not found.');
  }

  @override
  Future<List<double>> getHistoricalSeries(
    String symbol, {
    StockTimeframe timeframe = StockTimeframe.week1,
  }) async {
    final stock = await getStockBySymbol(symbol);
    final period = switch (timeframe) {
      StockTimeframe.day1 => '24h',
      StockTimeframe.week1 => '7d',
      StockTimeframe.month1 => '30d',
    };
    final history = await _coinHistoryApi.getPriceHistory(
      uuid: stock.id,
      timePeriod: period,
    );
    if (history.isEmpty) {
      return <double>[stock.price];
    }
    return history.map((point) => point.price).toList(growable: false);
  }

  @override
  Future<List<StockHolding>> getHoldings() async {
    final coins = await _coinsRepository.getCoins(
      limit: 12,
      offset: 0,
      orderBy: 'marketCap',
      orderDirection: 'desc',
    );
    if (coins.isEmpty) {
      throw const ApiException('Unable to build holdings from market data.');
    }

    final selected = coins.take(4).toList(growable: false);
    final holdings = selected.map((coin) {
      final quantity = _holdingQuantity(coin);
      return StockHolding(
        symbol: coin.symbol.toUpperCase(),
        name: coin.name,
        quantity: quantity,
        avgBuyPrice: coin.price * 0.9,
        currentPrice: coin.price,
        allocationPercent: 0,
      );
    }).toList(growable: false);

    final total =
        holdings.fold<double>(0, (sum, item) => sum + item.marketValue);
    if (total <= 0) {
      return holdings;
    }

    return holdings.map((item) {
      final percent = (item.marketValue / total) * 100;
      return StockHolding(
        symbol: item.symbol,
        name: item.name,
        quantity: item.quantity,
        avgBuyPrice: item.avgBuyPrice,
        currentPrice: item.currentPrice,
        allocationPercent: percent,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<StockTransaction>> getTransactions() async {
    final holdings = await getHoldings();
    final now = DateTime.now();
    final transactions = <StockTransaction>[
      for (var index = 0; index < holdings.length; index++)
        StockTransaction(
          id: 'txn-${index + 1}',
          symbol: holdings[index].symbol,
          title: 'Buy ${holdings[index].symbol}',
          type: StockTransactionType.buy,
          status: StockTransactionStatus.completed,
          value: holdings[index].currentPrice * 1.2,
          shares: 1.2,
          createdAt: now.subtract(Duration(hours: 4 + (index * 3))),
        ),
      if (holdings.isNotEmpty)
        StockTransaction(
          id: 'txn-${holdings.length + 1}',
          symbol: holdings.first.symbol,
          title: 'Sell ${holdings.first.symbol}',
          type: StockTransactionType.sell,
          status: StockTransactionStatus.pending,
          value: holdings.first.currentPrice * 0.4,
          shares: 0.4,
          createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        ),
      if (holdings.length > 1)
        StockTransaction(
          id: 'txn-${holdings.length + 2}',
          symbol: holdings[1].symbol,
          title: 'Exchange ${holdings[1].symbol}',
          type: StockTransactionType.exchange,
          status: StockTransactionStatus.completed,
          value: holdings[1].currentPrice * 0.8,
          shares: 0.8,
          createdAt: now.subtract(const Duration(days: 2, hours: 6)),
        ),
    ];

    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return transactions;
  }

  Stock _toStock(Coin coin) {
    final listedAt =
        coin.listedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return Stock(
      id: coin.uuid,
      symbol: coin.symbol.toUpperCase(),
      name: coin.name,
      price: coin.price,
      changePercent: coin.change,
      marketCap: coin.marketCap,
      volume24h: coin.volume24h,
      listedAt: listedAt,
      sector: 'Crypto',
      sparklinePoints: _sparklineForCoin(coin),
    );
  }

  List<double> _sparklineForCoin(Coin coin) {
    final current = coin.price;
    if (current <= 0) {
      return const <double>[0];
    }
    final changeRatio = coin.change / 100;
    final start = current / (1 + changeRatio);
    final points = <double>[];
    for (var i = 0; i < 22; i++) {
      final progress = i / 21;
      final wobble = (progress * (1 - progress)) * current * 0.04;
      final value = (start + ((current - start) * progress)) + wobble;
      points.add(value);
    }
    return points;
  }

  double _holdingQuantity(Coin coin) {
    if (coin.price <= 0) {
      return 0;
    }
    final targetValue = 1200 + (coin.rank * 140);
    return targetValue / coin.price;
  }

  String _coinOrderBy(StockSortBy sortBy) {
    return switch (sortBy) {
      StockSortBy.price => 'price',
      StockSortBy.marketCap => 'marketCap',
      StockSortBy.volume24h => '24hVolume',
      StockSortBy.change => 'change',
      StockSortBy.listedAt => 'listedAt',
    };
  }
}
