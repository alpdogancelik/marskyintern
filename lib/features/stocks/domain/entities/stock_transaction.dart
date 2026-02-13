enum StockTransactionType { buy, sell, deposit, exchange }

enum StockTransactionStatus { completed, pending }

class StockTransaction {
  const StockTransaction({
    required this.id,
    required this.symbol,
    required this.title,
    required this.type,
    required this.status,
    required this.value,
    required this.shares,
    required this.createdAt,
  });

  final String id;
  final String symbol;
  final String title;
  final StockTransactionType type;
  final StockTransactionStatus status;
  final double value;
  final double shares;
  final DateTime createdAt;
}
