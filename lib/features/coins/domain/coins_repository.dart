import 'entities/coin.dart';

abstract class CoinsRepository {
  Future<List<Coin>> getCoins({
    required int limit,
    required int offset,
    String? orderBy,
    String? orderDirection,
  });

  Future<Coin> getCoinByUuid(String uuid);
}
