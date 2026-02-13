import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../errors/app_exception.dart';

class Env {
  static String? _readOptional(String key) {
    final value = dotenv.env[key];
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static bool _readBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  static String get supabaseUrl {
    final value = _readOptional('SUPABASE_URL');
    if (value == null) {
      throw const ConfigurationException('SUPABASE_URL is missing in .env');
    }
    return value;
  }

  static String get supabaseAnonKey {
    final value = _readOptional('SUPABASE_ANON_KEY');
    if (value == null) {
      throw const ConfigurationException('SUPABASE_ANON_KEY is missing in .env');
    }
    return value;
  }

  static String? trySupabaseUrl() => _readOptional('SUPABASE_URL');
  static String? trySupabaseAnonKey() => _readOptional('SUPABASE_ANON_KEY');

  static String coinrankingApiKey() {
    final value = _readOptional('COINRANKING_API_KEY');
    if (value == null) {
      throw const ConfigurationException(
        'CoinRanking API key is missing. Add COINRANKING_API_KEY to .env and restart.',
      );
    }
    return value;
  }

  static Uri coinrankingBaseUrl() => Uri.parse('https://api.coinranking.com/v2');

  static bool get useMockAuth => _readBool('USE_MOCK_AUTH');
  static bool get useMockCoins => _readBool('USE_MOCK_COINS');
}
