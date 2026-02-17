import '../../../core/errors/app_exception.dart';
import '../domain/favorites_repository.dart';
import 'favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._localDataSource);

  final FavoritesLocalDataSource _localDataSource;

  @override
  Future<Set<String>> getFavorites({
    required String profileId,
  }) {
    return _localDataSource.getFavorites(profileId);
  }

  @override
  Stream<Set<String>> observeFavorites({
    required String profileId,
  }) {
    return _localDataSource.watchFavorites(profileId);
  }

  @override
  Future<Set<String>> toggleFavorite({
    required String profileId,
    required String coinId,
  }) async {
    final normalizedCoinId = coinId.trim();
    if (normalizedCoinId.isEmpty) {
      throw const ConfigurationException('Coin id is required.');
    }

    final current = await _localDataSource.getFavorites(profileId);
    if (current.contains(normalizedCoinId)) {
      await _localDataSource.removeFavorite(
        profileId: profileId,
        coinId: normalizedCoinId,
      );
      return <String>{...current}..remove(normalizedCoinId);
    }

    await _localDataSource.addFavorite(
      profileId: profileId,
      coinId: normalizedCoinId,
    );
    return <String>{...current, normalizedCoinId};
  }

  @override
  Future<bool> isFavorite({
    required String profileId,
    required String coinId,
  }) {
    return _localDataSource.isFavorite(
      profileId: profileId,
      coinId: coinId,
    );
  }
}
