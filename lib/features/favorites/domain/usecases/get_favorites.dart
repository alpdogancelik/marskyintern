import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories.dart';
import '../favorites_repository.dart';

final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>((ref) {
  return GetFavoritesUseCase(ref.watch(favoritesRepositoryProvider));
});

class GetFavoritesUseCase {
  const GetFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<Set<String>> call({
    required String profileId,
  }) {
    return _repository.getFavorites(profileId: profileId);
  }
}
