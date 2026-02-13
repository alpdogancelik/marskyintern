import '../../domain/entities/price_point.dart';

class PricePointDto {
  const PricePointDto({
    required this.price,
    required this.timestamp,
  });

  final double price;
  final DateTime timestamp;

  factory PricePointDto.fromJson(Map<String, dynamic> json) {
    return PricePointDto(
      price: _toDouble(json['price']),
      timestamp: _toDateTime(json['timestamp']),
    );
  }

  PricePoint toEntity() {
    return PricePoint(
      price: price,
      timestamp: timestamp,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    final seconds = int.tryParse(value?.toString() ?? '') ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }
}
