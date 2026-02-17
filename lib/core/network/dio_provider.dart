import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/env.dart';
import '../errors/exception_mapper.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.coinrankingBaseUrl().toString(),
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        // Keep auth header internal; do not print or log this token.
        'x-access-token': Env.coinrankingApiKey(),
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        final mapped = ExceptionMapper.map(error);
        handler.reject(error.copyWith(error: mapped));
      },
    ),
  );

  return dio;
});
