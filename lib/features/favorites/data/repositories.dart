import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/favorites_repository.dart';
import 'favorites_local_datasource.dart';
import 'favorites_repository_impl.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final localDataSource = ref.watch(favoritesLocalDataSourceProvider);
  return FavoritesRepositoryImpl(localDataSource);
});
