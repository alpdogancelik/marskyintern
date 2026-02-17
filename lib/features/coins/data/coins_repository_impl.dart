import '../domain/coins_repository.dart';
import '../domain/entities/coin.dart';
import 'coinranking_api.dart';
import 'coins_remote_data_source.dart';

class CoinsRepositoryImpl implements CoinsRepository {
  CoinsRepositoryImpl(this._remoteDataSource);

  final CoinsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Coin>> getCoins({
    required int limit,
    required int offset,
    String? orderBy,
    String? orderDirection,
  }) async {
    final resolvedOrderBy = CoinOrderBy.fromValue(orderBy);
    final resolvedOrderDirection = CoinOrderDirection.fromValue(orderDirection);

    final dtos = await _remoteDataSource.listCoins(
      limit: limit,
      offset: offset,
      orderBy: resolvedOrderBy,
      orderDirection: resolvedOrderDirection,
    );
    return dtos.map((dto) => dto.toEntity()).toList(growable: false);
  }

  @override
  Future<Coin> getCoinByUuid(String uuid) async {
    final dto = await _remoteDataSource.getCoinByUuid(uuid);
    return dto.toEntity();
  }
}
