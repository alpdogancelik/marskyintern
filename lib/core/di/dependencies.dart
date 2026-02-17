import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/mock_auth_repository.dart';
import '../supabase/supabase_config.dart';

const String _mockSupabaseUrl = 'https://mock.supabase.local';
const String _mockSupabaseAnonKey = 'mock-anon-key';

List<Override> buildDependencies({required bool useMockAuth}) {
  if (!useMockAuth) {
    return const <Override>[];
  }

  return <Override>[
    authRepositoryProvider.overrideWith((ref) {
      final repository = MockAuthRepository(
        autoAuthenticate: true,
      );
      ref.onDispose(repository.dispose);
      return repository;
    }),
    supabaseClientProvider.overrideWithValue(
      SupabaseClient(_mockSupabaseUrl, _mockSupabaseAnonKey),
    ),
  ];
}
