import 'package:flutter_test/flutter_test.dart';
import 'package:marsky/features/coins/data/models/coin_dto.dart';

void main() {
  test('CoinDto maps json to entity correctly', () {
    final dto = CoinDto.fromJson({
      'uuid': 'btc-uuid',
      'name': 'Bitcoin',
      'symbol': 'BTC',
      'iconUrl': 'https://example.com/btc.png',
      'price': '50000.12',
      'change': '-1.25',
      'rank': 1,
      'marketCap': '999999999',
      '24hVolume': '123456789',
      'listedAt': 1367107200,
    });

    final entity = dto.toEntity();

    expect(entity.uuid, 'btc-uuid');
    expect(entity.name, 'Bitcoin');
    expect(entity.symbol, 'BTC');
    expect(entity.iconUrl, 'https://example.com/btc.png');
    expect(entity.price, 50000.12);
    expect(entity.change, -1.25);
    expect(entity.rank, 1);
    expect(entity.marketCap, 999999999);
    expect(entity.volume24h, 123456789);
    expect(entity.listedAt, DateTime.fromMillisecondsSinceEpoch(1367107200 * 1000, isUtc: true));
  });
}
