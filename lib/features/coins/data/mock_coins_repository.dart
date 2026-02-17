import '../../../core/errors/app_exception.dart';
import '../domain/coins_repository.dart';
import '../domain/entities/coin.dart';

class MockCoinsRepository implements CoinsRepository {
  @override
  Future<List<Coin>> getCoins({
    required int limit,
    required int offset,
    String? orderBy,
    String? orderDirection,
  }) async {
    final all = _mockCoins();
    final sorted = [...all]..sort((a, b) {
        final direction =
            (orderDirection ?? 'desc').toLowerCase() == 'asc' ? 1 : -1;
        final comparison = switch (orderBy) {
          'price' => a.price.compareTo(b.price),
          '24hVolume' => a.volume24h.compareTo(b.volume24h),
          'change' => a.change.compareTo(b.change),
          'listedAt' => (a.listedAt ?? DateTime(1970))
              .compareTo(b.listedAt ?? DateTime(1970)),
          _ => a.marketCap.compareTo(b.marketCap),
        };
        return comparison * direction;
      });

    if (offset >= sorted.length) {
      return const <Coin>[];
    }
    final end =
        (offset + limit) > sorted.length ? sorted.length : offset + limit;
    return sorted.sublist(offset, end);
  }

  @override
  Future<Coin> getCoinByUuid(String uuid) async {
    try {
      return _mockCoins().firstWhere((coin) => coin.uuid == uuid);
    } catch (_) {
      throw NotFoundException('Coin with uuid "$uuid" was not found.');
    }
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
