import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marsky/features/coins/domain/entities/coin.dart';
import 'package:marsky/features/favorites/presentation/favorites_controller.dart';
import 'package:marsky/features/favorites/presentation/favorites_screen.dart';

void main() {
  testWidgets('FavoritesScreen shows empty state when no favorites exist',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesControllerProvider.overrideWith(
            _FakeEmptyFavoritesController.new,
          ),
        ],
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('No favorites yet'), findsOneWidget);
    expect(find.text('Browse coins'), findsOneWidget);
  });

  testWidgets('FavoritesScreen renders favorited coins list', (tester) async {
    const coin = Coin(
      uuid: 'btc-uuid',
      name: 'Bitcoin',
      symbol: 'BTC',
      iconUrl: '',
      price: 50000,
      change: 1.2,
      rank: 1,
      marketCap: 1000000000,
      volume24h: 50000000,
      listedAt: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesControllerProvider.overrideWith(
            _FakeSingleFavoriteController.new,
          ),
          favoriteCoinsProvider.overrideWith((ref) async => const <Coin>[coin]),
        ],
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('BTC'), findsOneWidget);
  });
}

class _FakeEmptyFavoritesController extends FavoritesController {
  @override
  Future<Set<String>> build() async => const <String>{};

  @override
  Future<void> toggle(String uuid) async {}
}

class _FakeSingleFavoriteController extends FavoritesController {
  @override
  Future<Set<String>> build() async => const <String>{'btc-uuid'};

  @override
  Future<void> toggle(String uuid) async {}
}
