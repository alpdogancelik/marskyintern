import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../errors/app_exception.dart';

class Env {
  static const bool _useMockAuthFromDartDefine = bool.fromEnvironment(
    'USE_MOCK_AUTH',
    defaultValue: false,
  );

  static bool get useMockAuth => _readBool(
        'USE_MOCK_AUTH',
        fallback: _useMockAuthFromDartDefine,
      );

  static const bool bypassAuth = bool.fromEnvironment(
    'BYPASS_AUTH',
    defaultValue: false,
  );

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
      throw const ConfigurationException(
          'SUPABASE_ANON_KEY is missing in .env');
    }
    return value;
  }

  static String? trySupabaseUrl() => _readOptional('SUPABASE_URL');
  static String? trySupabaseAnonKey() => _readOptional('SUPABASE_ANON_KEY');
  static String? get authRedirectUrl => _readOptional('AUTH_REDIRECT_URL');
  static bool get hasSupabaseConfig {
    final url = trySupabaseUrl();
    final anonKey = trySupabaseAnonKey();
    if (url == null || anonKey == null) {
      return false;
    }
    return !_looksLikePlaceholder(url) && !_looksLikePlaceholder(anonKey);
  }

  static String coinrankingApiKey() {
    final value = _readOptional('COINRANKING_API_KEY');
    if (value == null) {
      throw const ConfigurationException(
        'CoinRanking API key is missing. Add COINRANKING_API_KEY to .env and restart.',
      );
    }
    return value;
  }

  static Uri coinrankingBaseUrl() =>
      Uri.parse('https://api.coinranking.com/v2');

  static const bool useMockCoins = bool.fromEnvironment(
    'USE_MOCK_COINS',
    defaultValue: false,
  );

  static const bool _useSupabaseCoinsCacheFromDartDefine = bool.fromEnvironment(
    'USE_SUPABASE_COINS_CACHE',
    defaultValue: false,
  );

  static bool get useSupabaseCoinsCache => _readBool(
        'USE_SUPABASE_COINS_CACHE',
        fallback: _useSupabaseCoinsCacheFromDartDefine,
      );

  static const bool enableDevStubFlows = bool.fromEnvironment(
    'ENABLE_DEV_STUB_FLOWS',
    defaultValue: false,
  );

  static bool _readBool(
    String key, {
    required bool fallback,
  }) {
    final value = _readOptional(key);
    if (value == null) {
      return fallback;
    }
    switch (value.toLowerCase()) {
      case '1':
      case 'true':
      case 'yes':
      case 'on':
        return true;
      case '0':
      case 'false':
      case 'no':
      case 'off':
        return false;
      default:
        return fallback;
    }
  }

  static bool _looksLikePlaceholder(String value) {
    final lower = value.toLowerCase();
    return lower == 'dummy' ||
        lower.contains('example') ||
        lower.contains('your_') ||
        lower.contains('placeholder') ||
        lower.contains('replace_me');
  }
}
