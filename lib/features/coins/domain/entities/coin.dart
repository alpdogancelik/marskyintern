class Coin {
  const Coin({
    required this.uuid,
    required this.name,
    required this.symbol,
    required this.iconUrl,
    required this.price,
    required this.change,
    required this.rank,
    required this.marketCap,
    required this.volume24h,
    required this.listedAt,
  });

  final String uuid;
  final String name;
  final String symbol;
  final String iconUrl;
  final double price;
  final double change;
  final int rank;
  final double marketCap;
  final double volume24h;
  final DateTime? listedAt;
}
