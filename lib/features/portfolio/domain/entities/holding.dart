class Holding {
  const Holding({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgBuyPrice,
    required this.currentPrice,
    required this.change24h,
    required this.value,
  });

  final String symbol;
  final String name;
  final double quantity;
  final double avgBuyPrice;
  final double currentPrice;
  final double change24h;
  final double value;

  double get totalCost => quantity * avgBuyPrice;

  double get pnl => value - totalCost;

  double get pnlPercent {
    final cost = totalCost;
    if (cost <= 0) {
      return 0;
    }
    return (pnl / cost) * 100;
  }
}
