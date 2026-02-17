import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories.dart';
import '../favorites_repository.dart';

final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(ref.watch(favoritesRepositoryProvider));
});

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<Set<String>> call({
    required String profileId,
    required String coinId,
  }) {
    return _repository.toggleFavorite(
      profileId: profileId,
      coinId: coinId,
    );
  }
}
