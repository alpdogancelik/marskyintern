import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../auth/domain/auth_state.dart';
import '../domain/usecases/get_favorites.dart';
import '../domain/usecases/observe_favorites.dart';
import '../domain/usecases/toggle_favorite.dart';

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, Set<String>>(
  FavoritesController.new,
);

class FavoritesController extends AsyncNotifier<Set<String>> {
  static const _defaultProfileId = 'local_profile';

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<Set<String>>? _favoritesSubscription;
  String _activeProfileId = _defaultProfileId;

  @override
  Future<Set<String>> build() async {
    final authRepository = ref.read(authRepositoryProvider);
    final getFavorites = ref.read(getFavoritesUseCaseProvider);
    final observeFavorites = ref.read(observeFavoritesUseCaseProvider);

    _authSubscription = authRepository.authStateChanges().listen((event) {
      final profileId = _resolveProfileId(event.userId);
      if (_activeProfileId == profileId) {
        return;
      }
      _bindFavoritesStream(
        profileId: profileId,
        observeFavorites: observeFavorites,
      );
    });
    ref.onDispose(() {
      _authSubscription?.cancel();
      _favoritesSubscription?.cancel();
    });

    final initialProfileId =
        _resolveProfileId(authRepository.currentAuthState.userId);
    _bindFavoritesStream(
      profileId: initialProfileId,
      observeFavorites: observeFavorites,
    );
    return getFavorites(profileId: initialProfileId);
  }

  Future<void> toggle(String uuid) async {
    final current = state.valueOrNull ?? const <String>{};
    final next = <String>{...current};
    if (next.contains(uuid)) {
      next.remove(uuid);
    } else {
      next.add(uuid);
    }

    state = AsyncData(next);
    try {
      final updated = await ref.read(toggleFavoriteUseCaseProvider)(
        profileId: _activeProfileId,
        coinId: uuid,
      );
      state = AsyncData(updated);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(current);
      rethrow;
    }
  }

  void _bindFavoritesStream({
    required String profileId,
    required ObserveFavoritesUseCase observeFavorites,
  }) {
    _activeProfileId = profileId;
    _favoritesSubscription?.cancel();
    _favoritesSubscription = observeFavorites(profileId: profileId).listen(
      (favorites) => state = AsyncData(favorites),
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
  }

  String _resolveProfileId(String? userId) {
    final id = userId?.trim();
    if (id == null || id.isEmpty) {
      return _defaultProfileId;
    }
    return id;
  }

  void clearMemory() {
    state = const AsyncData(<String>{});
  }
}
