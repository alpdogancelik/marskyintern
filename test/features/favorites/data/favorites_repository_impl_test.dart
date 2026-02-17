import 'package:flutter_test/flutter_test.dart';
import 'package:marsky/features/favorites/data/favorites_repository_impl.dart';
import 'package:marsky/features/favorites/domain/favorites_repository.dart';

import 'favorites_test_fakes.dart';

void main() {
  late InMemoryFavoritesLocalDataSource localDataSource;
  late FavoritesRepository repository;

  setUp(() {
    localDataSource = InMemoryFavoritesLocalDataSource();
    repository = FavoritesRepositoryImpl(localDataSource);
  });

  test('toggle adds and removes favorite', () async {
    final added = await repository.toggleFavorite(
      profileId: 'local_profile',
      coinId: 'btc',
    );
    final removed = await repository.toggleFavorite(
      profileId: 'local_profile',
      coinId: 'btc',
    );

    expect(added, equals({'btc'}));
    expect(removed, isEmpty);
  });

  test('isFavorite reflects stored state', () async {
    await repository.toggleFavorite(
      profileId: 'local_profile',
      coinId: 'eth',
    );

    final isFavorite = await repository.isFavorite(
      profileId: 'local_profile',
      coinId: 'eth',
    );
    final isNotFavorite = await repository.isFavorite(
      profileId: 'local_profile',
      coinId: 'btc',
    );

    expect(isFavorite, isTrue);
    expect(isNotFavorite, isFalse);
  });

  test('restores favorites from local datasource on new repository instance',
      () async {
    await repository.toggleFavorite(
      profileId: 'local_profile',
      coinId: 'sol',
    );

    final restoredRepository = FavoritesRepositoryImpl(localDataSource);
    final restored = await restoredRepository.getFavorites(
      profileId: 'local_profile',
    );

    expect(restored, equals({'sol'}));
  });
}
