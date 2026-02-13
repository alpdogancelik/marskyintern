import '../../domain/entities/coin.dart';

class CoinDto {
  const CoinDto({
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

  factory CoinDto.fromJson(Map<String, dynamic> json) {
    return CoinDto(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      price: _toDouble(json['price']),
      change: _toDouble(json['change']),
      rank: _toInt(json['rank']),
      marketCap: _toDouble(json['marketCap']),
      volume24h: _toDouble(json['24hVolume']),
      listedAt: _toDateTime(json['listedAt']),
    );
  }

  Coin toEntity() {
    return Coin(
      uuid: uuid,
      name: name,
      symbol: symbol,
      iconUrl: iconUrl,
      price: price,
      change: change,
      rank: rank,
      marketCap: marketCap,
      volume24h: volume24h,
      listedAt: listedAt,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final normalized = value.toString().replaceAll(',', '').trim();
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final normalized = value.toString().replaceAll(',', '').trim();
    if (normalized.isEmpty) return 0;
    return int.tryParse(normalized) ?? (double.tryParse(normalized)?.toInt() ?? 0);
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    final seconds = int.tryParse(value.toString());
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }
}
