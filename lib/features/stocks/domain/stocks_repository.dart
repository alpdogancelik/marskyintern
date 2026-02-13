import 'entities/stock.dart';
import 'entities/stock_holding.dart';
import 'entities/stock_transaction.dart';

enum StockSortBy { price, marketCap, volume24h, change, listedAt }

enum StockTimeframe { day1, week1, month1 }

abstract class StocksRepository {
  Future<List<Stock>> getStocks({
    required int limit,
    required int offset,
    String? query,
    String? sector,
    StockSortBy sortBy = StockSortBy.marketCap,
    bool ascending = false,
  });

  Future<List<String>> getSectors();

  Future<Stock> getStockBySymbol(String symbol);

  Future<List<double>> getHistoricalSeries(
    String symbol, {
    StockTimeframe timeframe = StockTimeframe.week1,
  });

  Future<List<StockHolding>> getHoldings();

  Future<List<StockTransaction>> getTransactions();
}
