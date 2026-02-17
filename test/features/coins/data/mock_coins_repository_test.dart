import 'package:flutter_test/flutter_test.dart';
import 'package:marsky/core/errors/app_exception.dart';
import 'package:marsky/features/coins/data/mock_coins_repository.dart';

void main() {
  final repository = MockCoinsRepository();

  test('returns sorted paginated list', () async {
    final result = await repository.getCoins(
      limit: 10,
      offset: 0,
      orderBy: 'marketCap',
      orderDirection: 'desc',
    );

    expect(result, hasLength(10));
    expect(result.first.marketCap >= result.last.marketCap, isTrue);
  });

  test('throws NotFoundException for unknown uuid', () async {
    await expectLater(
      () => repository.getCoinByUuid('missing-uuid'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
