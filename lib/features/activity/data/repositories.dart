import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/env.dart';
import '../../coins/data/repositories.dart';
import '../domain/activity_repository.dart';
import 'activity_repository_impl.dart';
import 'mock_activity_repository.dart' show MockActivityRepository;

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final coinsRepository = ref.watch(coinsRepositoryProvider);
  if (Env.useMockCoins) {
    return MockActivityRepository(coinsRepository);
  }
  return ActivityRepositoryImpl(coinsRepository);
});
