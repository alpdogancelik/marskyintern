import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marsky/core/errors/app_exception.dart';
import 'package:marsky/core/errors/exception_mapper.dart';

void main() {
  final requestOptions = RequestOptions(path: '/test');

  test('maps connection timeout to NetworkException', () {
    final error = DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.connectionTimeout,
    );

    final mapped = mapDioException(error);

    expect(mapped, isA<NetworkException>());
    expect(
        mapped.message, 'Network error. Check your connection and try again.');
  });

  test('maps 401 response to UnauthorizedException', () {
    final error = DioException(
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );

    final mapped = mapDioException(error);

    expect(mapped, isA<UnauthorizedException>());
    expect(
      mapped.message,
      'CoinRanking rejected the API key. Verify your key/subscription.',
    );
  });

  test('maps API message from response body to ApiException', () {
    final error = DioException(
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 400,
        data: {'message': 'Invalid query'},
      ),
      type: DioExceptionType.badResponse,
    );

    final mapped = mapDioException(error);

    expect(mapped, isA<ApiException>());
    expect(mapped.message, 'Invalid query');
  });

  test('maps 404 response to NotFoundException', () {
    final error = DioException(
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 404,
        data: {'message': 'Coin not found'},
      ),
      type: DioExceptionType.badResponse,
    );

    final mapped = mapDioException(error);

    expect(mapped, isA<NotFoundException>());
    expect(mapped.message, 'Coin not found');
  });

  test('maps unknown non-status error to UnknownException', () {
    final error = DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.unknown,
      error: Exception('boom'),
    );

    final mapped = mapDioException(error);

    expect(mapped, isA<UnknownException>());
    expect(mapped.message, 'Something went wrong. Please try again.');
  });

  test('maps missing key message through AppException as-is', () {
    const error = ConfigurationException(
      'CoinRanking API key is missing. Add COINRANKING_API_KEY to .env and restart.',
    );

    final mapped = ExceptionMapper.map(error);

    expect(mapped, isA<ConfigurationException>());
    expect(
      mapped.message,
      'CoinRanking API key is missing. Add COINRANKING_API_KEY to .env and restart.',
    );
  });
}
