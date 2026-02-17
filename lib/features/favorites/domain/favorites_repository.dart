abstract class FavoritesRepository {
  Future<Set<String>> getFavorites({
    required String profileId,
  });

  Stream<Set<String>> observeFavorites({
    required String profileId,
  });

  Future<Set<String>> toggleFavorite({
    required String profileId,
    required String coinId,
  });

  Future<bool> isFavorite({
    required String profileId,
    required String coinId,
  });
}
