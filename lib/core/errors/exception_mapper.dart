import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

class ExceptionMapper {
  static const missingCoinRankingApiKeyMessage =
      'CoinRanking API key is missing. Add COINRANKING_API_KEY to .env and restart.';

  static AppException map(Object error) {
    if (error is AppException) {
      return error;
    }
    if (error is DioException) {
      return _mapDio(error);
    }
    if (error is AuthException) {
      return _mapAuth(error);
    }
    if (_looksLikeCors(error.toString())) {
      return const CorsException(
        'This may be blocked by browser CORS. Try running on an emulator/device.',
      );
    }
    return const UnknownException('Something went wrong. Please try again.');
  }

  static AppException _mapDio(DioException error) {
    final nested = error.error;
    if (nested is AppException) {
      return nested;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 404) {
      final message = _extractApiMessage(error.response?.data);
      return NotFoundException(message ?? 'Requested resource was not found.');
    }
    if (statusCode == 401 || statusCode == 403) {
      return const UnauthorizedException(
        'CoinRanking rejected the API key. Verify your key/subscription.',
      );
    }

    final details = '${error.message ?? ''} ${nested?.toString() ?? ''}';
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        _looksLikeSocketIssue(details)) {
      if (kIsWeb || _looksLikeCors(details)) {
        return const CorsException(
          'This may be blocked by browser CORS. Try running on an emulator/device.',
        );
      }
      return const NetworkException(
        'Network error. Check your connection and try again.',
      );
    }

    final apiMessage = _extractApiMessage(error.response?.data);
    if (apiMessage != null) {
      return ApiException(apiMessage);
    }

    if (kIsWeb || _looksLikeCors(details)) {
      return const CorsException(
        'This may be blocked by browser CORS. Try running on an emulator/device.',
      );
    }

    return const UnknownException('Something went wrong. Please try again.');
  }

  static AppException _mapAuth(AuthException error) {
    final message = error.message.trim();
    final lower = message.toLowerCase();

    if (lower.contains('error sending recovery email')) {
      return const ApiException(
        'Password reset email could not be sent. Check Supabase Auth email settings (SMTP/template and redirect URLs).',
      );
    }

    if (message.isNotEmpty) {
      return ApiException(message);
    }

    return const UnknownException('Something went wrong. Please try again.');
  }

  static bool _looksLikeCors(String text) {
    final lower = text.toLowerCase();
    return lower.contains('cors') ||
        lower.contains('xmlhttprequest error') ||
        lower.contains('blocked by') ||
        lower.contains('same-origin policy');
  }

  static bool _looksLikeSocketIssue(String text) {
    final lower = text.toLowerCase();
    return lower.contains('socketexception') ||
        lower.contains('failed host lookup');
  }

  static String? _extractApiMessage(Object? payload) {
    if (payload is! Map<String, dynamic>) {
      return null;
    }
    final bodyMessage = payload['message']?.toString();
    if (bodyMessage == null) {
      return null;
    }
    final trimmed = bodyMessage.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

AppException mapDioException(
  DioException error, {
  String fallbackMessage = 'Request failed. Please try again.',
}) {
  return ExceptionMapper.map(error);
}
