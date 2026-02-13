class Stock {
  const Stock({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.marketCap,
    required this.volume24h,
    required this.listedAt,
    required this.sector,
    required this.sparklinePoints,
  });

  final String id;
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final double marketCap;
  final double volume24h;
  final DateTime listedAt;
  final String sector;
  final List<double> sparklinePoints;
}
