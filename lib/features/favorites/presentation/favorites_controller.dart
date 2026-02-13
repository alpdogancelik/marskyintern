import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/data/auth_repository.dart';
import '../data/favorites_local_datasource.dart';

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, Set<String>>(
  FavoritesController.new,
);

class FavoritesController extends AsyncNotifier<Set<String>> {
  StreamSubscription<AuthState>? _subscription;

  @override
  Future<Set<String>> build() async {
    final localDataSource = ref.read(favoritesLocalDataSourceProvider);
    final repository = ref.read(authRepositoryProvider);

    _subscription = repository.sessionStream.listen((event) {
      final userId = event.session?.user.id;
      if (userId == null) {
        state = const AsyncData(<String>{});
        return;
      }
      unawaited(_loadForUser(userId));
    });
    ref.onDispose(() => _subscription?.cancel());

    final userId = repository.currentUserId;
    if (userId == null) {
      return const <String>{};
    }
    return localDataSource.getFavorites(userId);
  }

  Future<void> toggle(String uuid) async {
    final userId = ref.read(authRepositoryProvider).currentUserId;
    if (userId == null) {
      throw const ConfigurationException('Please log in to manage favorites.');
    }

    final current = state.valueOrNull ?? const <String>{};
    final next = <String>{...current};
    if (next.contains(uuid)) {
      next.remove(uuid);
    } else {
      next.add(uuid);
    }

    state = AsyncData(next);
    await ref
        .read(favoritesLocalDataSourceProvider)
        .saveFavorites(userId, next);
  }

  Future<void> _loadForUser(String userId) async {
    final favorites =
        await ref.read(favoritesLocalDataSourceProvider).getFavorites(userId);
    state = AsyncData(favorites);
  }

  void clearMemory() {
    state = const AsyncData(<String>{});
  }
}
