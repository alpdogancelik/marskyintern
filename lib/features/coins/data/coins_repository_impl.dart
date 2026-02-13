import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/env.dart';
import '../domain/coins_repository.dart';
import '../domain/entities/coin.dart';
import 'coinranking_api.dart';

final coinsRepositoryProvider = Provider<CoinsRepository>((ref) {
  final api = ref.watch(coinRankingApiProvider);
  return CoinsRepositoryImpl(api);
});

class CoinsRepositoryImpl implements CoinsRepository {
  CoinsRepositoryImpl(this._api);

  final CoinRankingApi _api;

  @override
  Future<List<Coin>> getCoins({
    required int limit,
    required int offset,
    String? orderBy,
    String? orderDirection,
  }) async {
    if (Env.useMockCoins) {
      final all = _mockCoins();
      final sorted = [...all]..sort((a, b) {
        final direction = (orderDirection ?? 'desc').toLowerCase() == 'asc' ? 1 : -1;
        int cmp;
        switch (orderBy) {
          case 'price':
            cmp = a.price.compareTo(b.price);
            break;
          case '24hVolume':
            cmp = a.volume24h.compareTo(b.volume24h);
            break;
          case 'change':
            cmp = a.change.compareTo(b.change);
            break;
          case 'listedAt':
            cmp = (a.listedAt ?? DateTime(1970)).compareTo(b.listedAt ?? DateTime(1970));
            break;
          case 'marketCap':
          default:
            cmp = a.marketCap.compareTo(b.marketCap);
            break;
        }
        return cmp * direction;
      });

      if (offset >= sorted.length) return const [];
      final end = (offset + limit) > sorted.length ? sorted.length : (offset + limit);
      return sorted.sublist(offset, end);
    }

    return _api.getCoins(
      limit: limit,
      offset: offset,
      orderBy: orderBy ?? 'marketCap',
      orderDirection: orderDirection ?? 'desc',
    );
  }

  @override
  Future<Coin> getCoinByUuid(String uuid) async {
    if (Env.useMockCoins) {
      return _mockCoins().firstWhere(
        (coin) => coin.uuid == uuid,
        orElse: () => _mockCoins().first,
      );
    }

    return _api.getCoinByUuid(uuid);
  }

  List<Coin> _mockCoins() {
    return List.generate(120, (index) {
      final i = index + 1;
      return Coin(
        uuid: 'mock-$i',
        name: 'Mock Coin $i',
        symbol: 'M$i',
        iconUrl: '',
        price: 10 + (i * 1.7),
        change: (i % 2 == 0 ? 1 : -1) * ((i % 9) + 0.35),
        rank: i,
        marketCap: 5000000 - (i * 3200),
        volume24h: 100000 + (i * 1400),
        listedAt: DateTime(2020, 1, 1).add(Duration(days: i)),
      );
    });
  }
}
