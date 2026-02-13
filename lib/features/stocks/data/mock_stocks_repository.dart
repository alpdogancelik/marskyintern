import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/stock.dart';
import '../domain/entities/stock_holding.dart';
import '../domain/entities/stock_transaction.dart';
import '../domain/stocks_repository.dart';

final stocksRepositoryProvider = Provider<StocksRepository>(
  (ref) => MockStocksRepository(),
);

class MockStocksRepository implements StocksRepository {
  static final List<Stock> _stocks = _mockStocks();

  @override
  Future<List<Stock>> getStocks({
    required int limit,
    required int offset,
    String? query,
    String? sector,
    StockSortBy sortBy = StockSortBy.marketCap,
    bool ascending = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final normalizedQuery = query?.trim().toLowerCase() ?? '';
    final normalizedSector = sector?.trim().toLowerCase();

    var items = _stocks.where((item) {
      final matchesQuery = normalizedQuery.isEmpty ||
          item.symbol.toLowerCase().contains(normalizedQuery) ||
          item.name.toLowerCase().contains(normalizedQuery);
      final matchesSector = normalizedSector == null ||
          normalizedSector.isEmpty ||
          item.sector.toLowerCase() == normalizedSector;
      return matchesQuery && matchesSector;
    }).toList(growable: false);

    items = [...items]..sort((a, b) {
        final direction = ascending ? 1 : -1;
        final result = switch (sortBy) {
          StockSortBy.price => a.price.compareTo(b.price),
          StockSortBy.marketCap => a.marketCap.compareTo(b.marketCap),
          StockSortBy.volume24h => a.volume24h.compareTo(b.volume24h),
          StockSortBy.change => a.changePercent.compareTo(b.changePercent),
          StockSortBy.listedAt => a.listedAt.compareTo(b.listedAt),
        };
        return result * direction;
      });

    if (offset >= items.length) {
      return const <Stock>[];
    }
    final end = math.min(offset + limit, items.length);
    return items.sublist(offset, end);
  }

  @override
  Future<List<String>> getSectors() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final sectors = _stocks.map((item) => item.sector).toSet().toList()..sort();
    return sectors;
  }

  @override
  Future<Stock> getStockBySymbol(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final normalized = symbol.trim().toUpperCase();
    return _stocks.firstWhere(
      (item) => item.symbol == normalized,
      orElse: () => _stocks.first,
    );
  }

  @override
  Future<List<double>> getHistoricalSeries(
    String symbol, {
    StockTimeframe timeframe = StockTimeframe.week1,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final stock = await getStockBySymbol(symbol);
    final count = switch (timeframe) {
      StockTimeframe.day1 => 18,
      StockTimeframe.week1 => 28,
      StockTimeframe.month1 => 45,
    };

    final random =
        math.Random(stock.symbol.codeUnits.fold<int>(0, (a, b) => a + b));
    final base = stock.price * 0.92;
    final amplitude = stock.price * 0.09;
    final values = <double>[];
    for (var i = 0; i < count; i++) {
      final progress = i / count;
      final wobble = math.sin(progress * math.pi * 3.4) * amplitude;
      final drift = progress * stock.price * 0.05;
      final noise = (random.nextDouble() - 0.5) * stock.price * 0.02;
      values.add(base + wobble + drift + noise);
    }
    return values;
  }

  @override
  Future<List<StockHolding>> getHoldings() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final map = {for (final stock in _stocks) stock.symbol: stock};
    return [
      StockHolding(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        quantity: 18,
        avgBuyPrice: 171.20,
        currentPrice: map['AAPL']!.price,
        allocationPercent: 38,
      ),
      StockHolding(
        symbol: 'MSFT',
        name: 'Microsoft Corp',
        quantity: 10,
        avgBuyPrice: 394.40,
        currentPrice: map['MSFT']!.price,
        allocationPercent: 28,
      ),
      StockHolding(
        symbol: 'AMZN',
        name: 'Amazon Inc.',
        quantity: 16,
        avgBuyPrice: 108.10,
        currentPrice: map['AMZN']!.price,
        allocationPercent: 19,
      ),
      StockHolding(
        symbol: 'NVDA',
        name: 'NVIDIA Corp',
        quantity: 5,
        avgBuyPrice: 960.00,
        currentPrice: map['NVDA']!.price,
        allocationPercent: 15,
      ),
    ];
  }

  @override
  Future<List<StockTransaction>> getTransactions() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return [
      StockTransaction(
        id: 'txn-1',
        symbol: 'AMZN',
        title: 'Buy AMZN',
        type: StockTransactionType.buy,
        status: StockTransactionStatus.completed,
        value: 524.30,
        shares: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      StockTransaction(
        id: 'txn-2',
        symbol: 'USDT',
        title: 'Deposit (USD)',
        type: StockTransactionType.deposit,
        status: StockTransactionStatus.completed,
        value: 634.00,
        shares: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      StockTransaction(
        id: 'txn-3',
        symbol: 'AMD',
        title: 'Buy AMD',
        type: StockTransactionType.buy,
        status: StockTransactionStatus.pending,
        value: 112.80,
        shares: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      StockTransaction(
        id: 'txn-4',
        symbol: 'AAPL',
        title: 'Sell AAPL',
        type: StockTransactionType.sell,
        status: StockTransactionStatus.completed,
        value: 710.35,
        shares: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 7)),
      ),
      StockTransaction(
        id: 'txn-5',
        symbol: 'TSLA',
        title: 'Exchange TSLA -> NVDA',
        type: StockTransactionType.exchange,
        status: StockTransactionStatus.completed,
        value: 1090.00,
        shares: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  static List<Stock> _mockStocks() {
    final rows = <({
      String symbol,
      String name,
      double price,
      double change,
      double marketCap,
      double volume,
      String sector,
      int year,
    })>[
      (
        symbol: 'AAPL',
        name: 'Apple Inc.',
        price: 195.20,
        change: 0.98,
        marketCap: 3020000000000,
        volume: 54800000000,
        sector: 'Technology',
        year: 1980
      ),
      (
        symbol: 'MSFT',
        name: 'Microsoft Corp',
        price: 421.60,
        change: 1.12,
        marketCap: 2890000000000,
        volume: 55700000000,
        sector: 'Technology',
        year: 1986
      ),
      (
        symbol: 'NVDA',
        name: 'NVIDIA Corp',
        price: 1175.50,
        change: 2.81,
        marketCap: 2930000000000,
        volume: 87200000000,
        sector: 'Semiconductors',
        year: 1999
      ),
      (
        symbol: 'AMZN',
        name: 'Amazon Inc.',
        price: 176.32,
        change: 0.53,
        marketCap: 1850000000000,
        volume: 54300000000,
        sector: 'Consumer',
        year: 1997
      ),
      (
        symbol: 'GOOGL',
        name: 'Alphabet Inc.',
        price: 188.14,
        change: 0.67,
        marketCap: 2350000000000,
        volume: 36200000000,
        sector: 'Communication',
        year: 2004
      ),
      (
        symbol: 'META',
        name: 'Meta Platforms',
        price: 542.10,
        change: -0.61,
        marketCap: 1380000000000,
        volume: 42700000000,
        sector: 'Communication',
        year: 2012
      ),
      (
        symbol: 'TSLA',
        name: 'Tesla Inc.',
        price: 238.33,
        change: -1.94,
        marketCap: 758000000000,
        volume: 61900000000,
        sector: 'Automotive',
        year: 2010
      ),
      (
        symbol: 'AMD',
        name: 'AMD',
        price: 187.45,
        change: 1.77,
        marketCap: 302000000000,
        volume: 29600000000,
        sector: 'Semiconductors',
        year: 1972
      ),
      (
        symbol: 'NFLX',
        name: 'Netflix',
        price: 645.18,
        change: 0.46,
        marketCap: 276000000000,
        volume: 12900000000,
        sector: 'Communication',
        year: 2002
      ),
      (
        symbol: 'JPM',
        name: 'JPMorgan Chase',
        price: 211.05,
        change: 0.29,
        marketCap: 603000000000,
        volume: 10100000000,
        sector: 'Finance',
        year: 1969
      ),
      (
        symbol: 'V',
        name: 'Visa Inc.',
        price: 289.70,
        change: 0.70,
        marketCap: 601000000000,
        volume: 8900000000,
        sector: 'Finance',
        year: 2008
      ),
      (
        symbol: 'MA',
        name: 'Mastercard',
        price: 470.40,
        change: 0.44,
        marketCap: 436000000000,
        volume: 5900000000,
        sector: 'Finance',
        year: 2006
      ),
      (
        symbol: 'BAC',
        name: 'Bank of America',
        price: 40.11,
        change: -0.27,
        marketCap: 312000000000,
        volume: 8400000000,
        sector: 'Finance',
        year: 1978
      ),
      (
        symbol: 'XOM',
        name: 'Exxon Mobil',
        price: 114.63,
        change: -0.82,
        marketCap: 470000000000,
        volume: 15100000000,
        sector: 'Energy',
        year: 1978
      ),
      (
        symbol: 'CVX',
        name: 'Chevron',
        price: 164.92,
        change: -0.35,
        marketCap: 304000000000,
        volume: 10200000000,
        sector: 'Energy',
        year: 1926
      ),
      (
        symbol: 'PFE',
        name: 'Pfizer',
        price: 29.83,
        change: 0.15,
        marketCap: 169000000000,
        volume: 6200000000,
        sector: 'Healthcare',
        year: 1942
      ),
      (
        symbol: 'JNJ',
        name: 'Johnson & Johnson',
        price: 154.42,
        change: 0.11,
        marketCap: 373000000000,
        volume: 6600000000,
        sector: 'Healthcare',
        year: 1944
      ),
      (
        symbol: 'UNH',
        name: 'UnitedHealth',
        price: 497.36,
        change: -0.33,
        marketCap: 458000000000,
        volume: 5400000000,
        sector: 'Healthcare',
        year: 1984
      ),
      (
        symbol: 'WMT',
        name: 'Walmart',
        price: 69.14,
        change: 0.59,
        marketCap: 556000000000,
        volume: 7400000000,
        sector: 'Retail',
        year: 1970
      ),
      (
        symbol: 'COST',
        name: 'Costco',
        price: 887.93,
        change: 0.71,
        marketCap: 401000000000,
        volume: 6100000000,
        sector: 'Retail',
        year: 1985
      ),
      (
        symbol: 'KO',
        name: 'Coca-Cola',
        price: 64.01,
        change: 0.21,
        marketCap: 275000000000,
        volume: 4200000000,
        sector: 'Consumer',
        year: 1919
      ),
      (
        symbol: 'PEP',
        name: 'PepsiCo',
        price: 174.20,
        change: -0.11,
        marketCap: 238000000000,
        volume: 4700000000,
        sector: 'Consumer',
        year: 1972
      ),
      (
        symbol: 'ORCL',
        name: 'Oracle',
        price: 139.63,
        change: 1.02,
        marketCap: 384000000000,
        volume: 6000000000,
        sector: 'Technology',
        year: 1986
      ),
      (
        symbol: 'INTC',
        name: 'Intel',
        price: 35.74,
        change: -0.92,
        marketCap: 151000000000,
        volume: 6700000000,
        sector: 'Semiconductors',
        year: 1971
      ),
      (
        symbol: 'ADBE',
        name: 'Adobe',
        price: 588.92,
        change: 0.74,
        marketCap: 266000000000,
        volume: 5100000000,
        sector: 'Technology',
        year: 1986
      ),
      (
        symbol: 'DIS',
        name: 'Disney',
        price: 113.27,
        change: -0.22,
        marketCap: 208000000000,
        volume: 5900000000,
        sector: 'Entertainment',
        year: 1957
      ),
      (
        symbol: 'NKE',
        name: 'Nike',
        price: 101.42,
        change: 0.16,
        marketCap: 150000000000,
        volume: 3900000000,
        sector: 'Retail',
        year: 1980
      ),
      (
        symbol: 'BA',
        name: 'Boeing',
        price: 184.90,
        change: -1.17,
        marketCap: 116000000000,
        volume: 4700000000,
        sector: 'Industrial',
        year: 1962
      ),
      (
        symbol: 'GE',
        name: 'General Electric',
        price: 167.60,
        change: 0.89,
        marketCap: 184000000000,
        volume: 4300000000,
        sector: 'Industrial',
        year: 1892
      ),
      (
        symbol: 'PLTR',
        name: 'Palantir',
        price: 29.18,
        change: 2.23,
        marketCap: 65000000000,
        volume: 4100000000,
        sector: 'Technology',
        year: 2020
      ),
    ];

    return rows.map((row) {
      final seed = row.symbol.codeUnits.fold<int>(0, (sum, c) => sum + c);
      return Stock(
        id: row.symbol,
        symbol: row.symbol,
        name: row.name,
        price: row.price,
        changePercent: row.change,
        marketCap: row.marketCap,
        volume24h: row.volume,
        listedAt: DateTime(row.year, 1, 1),
        sector: row.sector,
        sparklinePoints: _buildSpark(seed: seed, start: row.price * 0.84),
      );
    }).toList(growable: false);
  }

  static List<double> _buildSpark({
    required int seed,
    required double start,
  }) {
    final random = math.Random(seed);
    final points = <double>[];
    var current = start;
    for (var i = 0; i < 22; i++) {
      final drift = (random.nextDouble() - 0.45) * 4;
      current = math.max(3, current + drift);
      points.add(current);
    }
    return points;
  }
}
