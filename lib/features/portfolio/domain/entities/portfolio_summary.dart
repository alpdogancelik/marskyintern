class PortfolioSummary {
  const PortfolioSummary({
    required this.totalValue,
    required this.totalCost,
    required this.totalPnL,
    required this.totalPnLPercent,
  });

  final double totalValue;
  final double totalCost;
  final double totalPnL;
  final double totalPnLPercent;
}
