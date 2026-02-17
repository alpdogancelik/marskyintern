import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marsky/features/favorites/data/favorites_local_datasource.dart';

void main() {
  late Directory tempDir;
  late FavoritesLocalDataSource dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('marsky_favorites_test_');
    Hive.init(tempDir.path);
    dataSource = HiveFavoritesLocalDataSource();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('stores and reads favorites for profile', () async {
    await dataSource.addFavorite(profileId: 'user_a', coinId: 'btc');
    await dataSource.addFavorite(profileId: 'user_a', coinId: 'eth');

    final result = await dataSource.getFavorites('user_a');

    expect(result, equals({'btc', 'eth'}));
  });

  test('namespaces favorites per profile', () async {
    await dataSource.addFavorite(profileId: 'user_a', coinId: 'btc');
    await dataSource.addFavorite(profileId: 'user_b', coinId: 'sol');

    final userA = await dataSource.getFavorites('user_a');
    final userB = await dataSource.getFavorites('user_b');

    expect(userA, equals({'btc'}));
    expect(userB, equals({'sol'}));
  });

  test('persists values across datasource instances', () async {
    await dataSource.addFavorite(profileId: 'user_a', coinId: 'btc');

    final secondInstance = HiveFavoritesLocalDataSource();
    final result = await secondInstance.getFavorites('user_a');

    expect(result, equals({'btc'}));
  });
}
