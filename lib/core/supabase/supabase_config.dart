import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/env.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
    );
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => SupabaseConfig.client,
);
