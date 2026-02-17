import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coinranking_api.dart';
import 'models/coin_dto.dart';
import 'models/price_point_dto.dart';

final coinsRemoteDataSourceProvider = Provider<CoinsRemoteDataSource>((ref) {
  return CoinRankingRemoteDataSource(ref.watch(coinRankingApiClientProvider));
});

abstract class CoinsRemoteDataSource {
  Future<List<CoinDto>> listCoins({
    required int limit,
    required int offset,
    required CoinOrderBy orderBy,
    required CoinOrderDirection orderDirection,
  });

  Future<CoinDto> getCoinByUuid(String uuid);

  Future<List<PricePointDto>> getCoinHistory({
    required String uuid,
    required CoinHistoryTimePeriod timePeriod,
  });
}

class CoinRankingRemoteDataSource implements CoinsRemoteDataSource {
  CoinRankingRemoteDataSource(this._apiClient);

  final CoinRankingApiClient _apiClient;

  @override
  Future<List<CoinDto>> listCoins({
    required int limit,
    required int offset,
    required CoinOrderBy orderBy,
    required CoinOrderDirection orderDirection,
  }) async {
    return _apiClient.listCoins(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      orderDirection: orderDirection,
    );
  }

  @override
  Future<CoinDto> getCoinByUuid(String uuid) async {
    return _apiClient.getCoinByUuid(uuid);
  }

  @override
  Future<List<PricePointDto>> getCoinHistory({
    required String uuid,
    required CoinHistoryTimePeriod timePeriod,
  }) {
    return _apiClient.getCoinHistory(uuid: uuid, timePeriod: timePeriod);
  }
}
