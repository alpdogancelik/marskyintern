import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/env.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/exception_mapper.dart';
import '../../../core/network/dio_provider.dart';
import 'models/price_point_dto.dart';

final coinHistoryApiProvider = Provider<CoinHistoryApi>((ref) {
  return CoinHistoryApi(ref.watch(dioProvider));
});

class CoinHistoryApi {
  CoinHistoryApi(this._dio);

  final Dio _dio;

  Future<List<PricePointDto>> getPriceHistory({
    required String uuid,
    String timePeriod = '7d',
  }) async {
    if (Env.useMockCoins) {
      return List.generate(30, (index) {
        final base = 100 + (uuid.hashCode % 50);
        final value = base + (index * 0.9) - (index % 5) * 1.3;
        return PricePointDto(
          price: value.toDouble(),
          timestamp: DateTime.now().toUtc().subtract(Duration(hours: 29 - index)),
        );
      });
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/coin/$uuid/price-history',
        queryParameters: {'timePeriod': timePeriod},
      );

      final status = response.data?['status']?.toString();
      if (status != 'success') {
        throw const ApiException('Coin history request failed.');
      }

      final data = response.data?['data'] as Map<String, dynamic>?;
      final history = (data?['history'] as List<dynamic>? ?? const []);

      return history
          .map((json) => PricePointDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}
