import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/exception_mapper.dart';
import '../../../core/network/dio_provider.dart';
import 'models/coin_dto.dart';
import 'models/price_point_dto.dart';

final coinRankingApiClientProvider = Provider<CoinRankingApiClient>((ref) {
  return CoinRankingApiClient(ref.watch(dioProvider));
});

enum CoinOrderBy {
  price('price'),
  marketCap('marketCap'),
  volume24h('24hVolume'),
  change('change'),
  listedAt('listedAt');

  const CoinOrderBy(this.apiValue);

  final String apiValue;

  static CoinOrderBy fromValue(String? raw) {
    return switch (raw) {
      'price' => CoinOrderBy.price,
      'marketCap' => CoinOrderBy.marketCap,
      '24hVolume' => CoinOrderBy.volume24h,
      'change' => CoinOrderBy.change,
      'listedAt' => CoinOrderBy.listedAt,
      _ => CoinOrderBy.marketCap,
    };
  }
}

enum CoinOrderDirection {
  asc('asc'),
  desc('desc');

  const CoinOrderDirection(this.apiValue);

  final String apiValue;

  static CoinOrderDirection fromValue(String? raw) {
    return (raw ?? '').toLowerCase() == 'asc'
        ? CoinOrderDirection.asc
        : CoinOrderDirection.desc;
  }
}

enum CoinHistoryTimePeriod {
  hour24('24h'),
  day7('7d'),
  day30('30d'),
  year1('1y'),
  year5('5y');

  const CoinHistoryTimePeriod(this.apiValue);

  final String apiValue;

  static CoinHistoryTimePeriod fromValue(String? raw) {
    return switch (raw) {
      '24h' => CoinHistoryTimePeriod.hour24,
      '7d' => CoinHistoryTimePeriod.day7,
      '30d' => CoinHistoryTimePeriod.day30,
      '1y' => CoinHistoryTimePeriod.year1,
      '5y' => CoinHistoryTimePeriod.year5,
      _ => CoinHistoryTimePeriod.day7,
    };
  }
}

class CoinRankingApiClient {
  CoinRankingApiClient(this._dio);

  final Dio _dio;
  static const int _maxListLimit = 100;
  static const int _defaultListLimit = 20;

  Future<List<CoinDto>> listCoins({
    required int limit,
    required int offset,
    required CoinOrderBy orderBy,
    required CoinOrderDirection orderDirection,
  }) async {
    final safeLimit = _normalizeLimit(limit);
    final safeOffset = offset < 0 ? 0 : offset;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/coins',
        queryParameters: <String, dynamic>{
          // CoinRanking paging is offset+limit and sorting is server-side.
          'limit': safeLimit,
          'offset': safeOffset,
          'orderBy': orderBy.apiValue,
          'orderDirection': orderDirection.apiValue,
        },
      );
      final data = _readDataPayload(response.data);
      final coins = _readList(data, 'coins');
      return coins.map(CoinDto.fromJson).toList(growable: false);
    } catch (error) {
      throw _mapError(error);
    }
  }

  Future<CoinDto> getCoinByUuid(String uuid) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/coin/$uuid');
      final data = _readDataPayload(response.data);
      final coinJson = data['coin'];
      if (coinJson is! Map<String, dynamic>) {
        throw NotFoundException('Coin with uuid "$uuid" was not found.');
      }
      return CoinDto.fromJson(coinJson);
    } catch (error) {
      throw _mapError(error);
    }
  }

  Future<List<PricePointDto>> getCoinHistory({
    required String uuid,
    required CoinHistoryTimePeriod timePeriod,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/coin/$uuid/history',
        queryParameters: <String, dynamic>{
          'timePeriod': timePeriod.apiValue,
        },
      );
      final data = _readDataPayload(response.data);
      final history = _readList(data, 'history');
      return history.map(PricePointDto.fromJson).toList(growable: false);
    } catch (error) {
      throw _mapError(error);
    }
  }

  Map<String, dynamic> _readDataPayload(Map<String, dynamic>? payload) {
    if (payload == null) {
      throw const ParsingException('CoinRanking returned an empty response.');
    }

    final status = payload['status']?.toString();
    if (status != 'success') {
      final message = payload['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        throw ApiException(message);
      }
      throw const ApiException('CoinRanking request failed.');
    }

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ParsingException('CoinRanking response is missing "data".');
  }

  List<Map<String, dynamic>> _readList(
      Map<String, dynamic> parent, String key) {
    final raw = parent[key];
    if (raw is! List) {
      throw ParsingException('CoinRanking response is missing "$key".');
    }

    final result = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        result.add(item);
      } else if (item is Map) {
        result.add(Map<String, dynamic>.from(item));
      } else {
        throw ParsingException(
          'CoinRanking response contains an invalid "$key" entry.',
        );
      }
    }

    return result;
  }

  AppException _mapError(Object error) {
    if (error is AppException) {
      return error;
    }
    if (error is DioException) {
      return ExceptionMapper.map(error);
    }
    if (error is TypeError || error is FormatException) {
      return const ParsingException(
        'Unable to parse CoinRanking response. Please try again later.',
      );
    }
    return ExceptionMapper.map(error);
  }

  int _normalizeLimit(int rawLimit) {
    if (rawLimit <= 0) {
      return _defaultListLimit;
    }
    if (rawLimit > _maxListLimit) {
      return _maxListLimit;
    }
    return rawLimit;
  }
}
