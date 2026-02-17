import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>(
  (ref) {
    return HiveFavoritesLocalDataSource();
  },
);

abstract class FavoritesLocalDataSource {
  Future<Set<String>> getFavorites(String profileId);
  Stream<Set<String>> watchFavorites(String profileId);
  Future<void> addFavorite({
    required String profileId,
    required String coinId,
  });
  Future<void> removeFavorite({
    required String profileId,
    required String coinId,
  });
  Future<bool> isFavorite({
    required String profileId,
    required String coinId,
  });
}

class HiveFavoritesLocalDataSource implements FavoritesLocalDataSource {
  static const _boxName = 'favorites_store';

  @override
  Future<Set<String>> getFavorites(String profileId) async {
    final box = await _openBox();
    return _readFavorites(box, profileId);
  }

  @override
  Stream<Set<String>> watchFavorites(String profileId) async* {
    final box = await _openBox();
    yield _readFavorites(box, profileId);
    yield* box.watch(key: _storageKey(profileId)).map((_) {
      return _readFavorites(box, profileId);
    });
  }

  @override
  Future<void> addFavorite({
    required String profileId,
    required String coinId,
  }) async {
    final box = await _openBox();
    final current = _readFavorites(box, profileId);
    current.add(coinId);
    await box.put(_storageKey(profileId), current.toList(growable: false));
  }

  @override
  Future<void> removeFavorite({
    required String profileId,
    required String coinId,
  }) async {
    final box = await _openBox();
    final current = _readFavorites(box, profileId);
    current.remove(coinId);
    await box.put(_storageKey(profileId), current.toList(growable: false));
  }

  @override
  Future<bool> isFavorite({
    required String profileId,
    required String coinId,
  }) async {
    final favorites = await getFavorites(profileId);
    return favorites.contains(coinId);
  }

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return Hive.openBox<dynamic>(_boxName);
  }

  Set<String> _readFavorites(Box<dynamic> box, String profileId) {
    final raw = box.get(_storageKey(profileId), defaultValue: <String>[]);
    final values = raw is List ? raw : <dynamic>[];
    return values.map((item) => item.toString()).toSet();
  }

  String _storageKey(String profileId) => 'favorites_$profileId';
}
