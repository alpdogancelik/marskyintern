import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/env.dart';
import '../../../core/supabase/supabase_config.dart';
import '../domain/coins_repository.dart';
import 'coins_remote_data_source.dart';
import 'coins_repository_impl.dart';
import 'mock_coins_repository.dart';
import 'supabase_coins_repository.dart';

final coinsRepositoryProvider = Provider<CoinsRepository>((ref) {
  if (Env.useMockCoins) {
    return MockCoinsRepository();
  }
  if (Env.useSupabaseCoinsCache && SupabaseConfig.isInitialized) {
    return ref.watch(supabaseCoinsRepositoryProvider);
  }
  final remoteDataSource = ref.watch(coinsRemoteDataSourceProvider);
  return CoinsRepositoryImpl(remoteDataSource);
});
