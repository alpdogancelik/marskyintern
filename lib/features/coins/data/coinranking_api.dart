import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/exception_mapper.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/entities/coin.dart';
import 'models/coin_dto.dart';

final coinRankingApiProvider = Provider<CoinRankingApi>((ref) {
  return CoinRankingApi(ref.watch(dioProvider));
});

class CoinRankingApi {
  CoinRankingApi(this._dio);

  final Dio _dio;

  Future<List<Coin>> getCoins({
    required int limit,
    required int offset,
    required String orderBy,
    required String orderDirection,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/coins',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'orderBy': orderBy,
          'orderDirection': orderDirection,
        },
      );

      final status = response.data?['status']?.toString();
      if (status != 'success') {
        throw const ApiException('CoinRanking request failed.');
      }

      final data = response.data?['data'] as Map<String, dynamic>?;
      final items = (data?['coins'] as List<dynamic>? ?? const []);

      return items
          .map((json) => CoinDto.fromJson(json as Map<String, dynamic>))
          .map((dto) => dto.toEntity())
          .toList();
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  Future<Coin> getCoinByUuid(String uuid) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/coin/$uuid',
      );

      final status = response.data?['status']?.toString();
      if (status != 'success') {
        throw const ApiException('CoinRanking request failed.');
      }

      final data = response.data?['data'] as Map<String, dynamic>?;
      final coinJson = data?['coin'] as Map<String, dynamic>?;
      if (coinJson == null) {
        throw const ApiException('Coin not found.');
      }
      return CoinDto.fromJson(coinJson).toEntity();
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}
