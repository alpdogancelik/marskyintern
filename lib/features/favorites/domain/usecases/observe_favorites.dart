import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories.dart';
import '../favorites_repository.dart';

final observeFavoritesUseCaseProvider =
    Provider<ObserveFavoritesUseCase>((ref) {
  return ObserveFavoritesUseCase(ref.watch(favoritesRepositoryProvider));
});

class ObserveFavoritesUseCase {
  const ObserveFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  Stream<Set<String>> call({
    required String profileId,
  }) {
    return _repository.observeFavorites(profileId: profileId);
  }
}
