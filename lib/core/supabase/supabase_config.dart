import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/env.dart';
import '../errors/app_exception.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initSupabase() async {
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
}

Future<void> initSupabase() => SupabaseConfig.initSupabase();

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) {
    if (!SupabaseConfig.isInitialized) {
      throw const ConfigurationException(
        'Supabase is not initialized. '
        'Call initSupabase() first or override supabaseClientProvider.',
      );
    }
    return Supabase.instance.client;
  },
);
