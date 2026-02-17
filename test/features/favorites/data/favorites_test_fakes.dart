import 'dart:async';

import 'package:marsky/features/favorites/data/favorites_local_datasource.dart';

class InMemoryFavoritesLocalDataSource implements FavoritesLocalDataSource {
  final Map<String, Set<String>> _store = <String, Set<String>>{};
  final Map<String, StreamController<Set<String>>> _controllers =
      <String, StreamController<Set<String>>>{};

  @override
  Future<Set<String>> getFavorites(String profileId) async {
    return <String>{...(_store[profileId] ?? const <String>{})};
  }

  @override
  Stream<Set<String>> watchFavorites(String profileId) {
    final controller = _controllerFor(profileId);
    controller.add(<String>{...(_store[profileId] ?? const <String>{})});
    return controller.stream;
  }

  @override
  Future<void> addFavorite({
    required String profileId,
    required String coinId,
  }) async {
    final next = <String>{...(_store[profileId] ?? const <String>{}), coinId};
    _store[profileId] = next;
    _controllerFor(profileId).add(<String>{...next});
  }

  @override
  Future<void> removeFavorite({
    required String profileId,
    required String coinId,
  }) async {
    final next = <String>{...(_store[profileId] ?? const <String>{})}
      ..remove(coinId);
    _store[profileId] = next;
    _controllerFor(profileId).add(<String>{...next});
  }

  @override
  Future<bool> isFavorite({
    required String profileId,
    required String coinId,
  }) async {
    return (_store[profileId] ?? const <String>{}).contains(coinId);
  }

  StreamController<Set<String>> _controllerFor(String profileId) {
    return _controllers.putIfAbsent(
      profileId,
      () => StreamController<Set<String>>.broadcast(),
    );
  }
}
