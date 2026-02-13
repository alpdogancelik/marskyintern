import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((ref) {
  return HiveFavoritesLocalDataSource();
});

abstract class FavoritesLocalDataSource {
  Future<Set<String>> getFavorites(String userId);
  Future<void> saveFavorites(String userId, Set<String> values);
}

class HiveFavoritesLocalDataSource implements FavoritesLocalDataSource {
  static const _boxName = 'favorites_store';

  @override
  Future<Set<String>> getFavorites(String userId) async {
    final box = await _openBox();
    final raw = box.get(_storageKey(userId), defaultValue: <String>[]);
    final values = raw is List ? raw : <dynamic>[];
    return values.map((item) => item.toString()).toSet();
  }

  @override
  Future<void> saveFavorites(String userId, Set<String> values) async {
    final box = await _openBox();
    await box.put(_storageKey(userId), values.toList());
  }

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return Hive.openBox<dynamic>(_boxName);
  }

  String _storageKey(String userId) => 'favorites_$userId';
}
