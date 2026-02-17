import 'package:flutter_test/flutter_test.dart';
import 'package:marsky/core/errors/app_exception.dart';
import 'package:marsky/features/coins/data/coinranking_api.dart';
import 'package:marsky/features/coins/data/coins_remote_data_source.dart';
import 'package:marsky/features/coins/data/coins_repository_impl.dart';
import 'package:marsky/features/coins/data/models/coin_dto.dart';
import 'package:marsky/features/coins/data/models/price_point_dto.dart';

void main() {
  test('propagates not found when coin uuid does not exist', () async {
    final repository = CoinsRepositoryImpl(_FakeCoinsRemoteDataSource());

    await expectLater(
      () => repository.getCoinByUuid('missing-uuid'),
      throwsA(isA<NotFoundException>()),
    );
  });
}

class _FakeCoinsRemoteDataSource implements CoinsRemoteDataSource {
  @override
  Future<CoinDto> getCoinByUuid(String uuid) async {
    throw NotFoundException('Coin with uuid "$uuid" was not found.');
  }

  @override
  Future<List<CoinDto>> listCoins({
    required int limit,
    required int offset,
    required CoinOrderBy orderBy,
    required CoinOrderDirection orderDirection,
  }) async {
    return const <CoinDto>[];
  }

  @override
  Future<List<PricePointDto>> getCoinHistory({
    required String uuid,
    required CoinHistoryTimePeriod timePeriod,
  }) async {
    return const <PricePointDto>[];
  }
}
