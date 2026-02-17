import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/env.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/exception_mapper.dart';
import 'coinranking_api.dart';
import 'coins_remote_data_source.dart';
import 'models/price_point_dto.dart';

final coinHistoryApiProvider = Provider<CoinHistoryApi>((ref) {
  if (Env.useMockCoins) {
    return CoinHistoryApi();
  }
  return CoinHistoryApi(ref.watch(coinsRemoteDataSourceProvider));
});

class CoinHistoryApi {
  CoinHistoryApi([this._remoteDataSource]);

  final CoinsRemoteDataSource? _remoteDataSource;

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
          timestamp:
              DateTime.now().toUtc().subtract(Duration(hours: 29 - index)),
        );
      });
    }

    final remoteDataSource = _remoteDataSource;
    if (remoteDataSource == null) {
      throw const ConfigurationException(
        'Coin history client is not initialized.',
      );
    }

    try {
      return remoteDataSource.getCoinHistory(
        uuid: uuid,
        timePeriod: CoinHistoryTimePeriod.fromValue(timePeriod),
      );
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}
