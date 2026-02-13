class StockHolding {
  const StockHolding({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgBuyPrice,
    required this.currentPrice,
    required this.allocationPercent,
  });

  final String symbol;
  final String name;
  final double quantity;
  final double avgBuyPrice;
  final double currentPrice;
  final double allocationPercent;

  double get marketValue => quantity * currentPrice;
  double get pnlValue => quantity * (currentPrice - avgBuyPrice);
}
