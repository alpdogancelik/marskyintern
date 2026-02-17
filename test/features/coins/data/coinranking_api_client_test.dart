import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marsky/core/errors/app_exception.dart';
import 'package:marsky/features/coins/data/coinranking_api.dart';

void main() {
  test('listCoins parses response with paging and sort params', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.path, '/coins');
          expect(options.queryParameters['limit'], 20);
          expect(options.queryParameters['offset'], 40);
          expect(options.queryParameters['orderBy'], 'marketCap');
          expect(options.queryParameters['orderDirection'], 'desc');

          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'status': 'success',
                'data': <String, dynamic>{
                  'coins': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'uuid': 'btc-uuid',
                      'name': 'Bitcoin',
                      'symbol': 'BTC',
                      'iconUrl': 'https://cdn.example/btc.png',
                      'price': '12345.67',
                      'change': '2.5',
                      'rank': 1,
                      'marketCap': '1000000',
                      '24hVolume': '75000',
                      'listedAt': 1367107200,
                    },
                  ],
                },
              },
            ),
          );
        },
      ),
    );

    final client = CoinRankingApiClient(dio);
    final result = await client.listCoins(
      limit: 20,
      offset: 40,
      orderBy: CoinOrderBy.marketCap,
      orderDirection: CoinOrderDirection.desc,
    );

    expect(result, hasLength(1));
    expect(result.first.uuid, 'btc-uuid');
    expect(result.first.symbol, 'BTC');
    expect(result.first.marketCap, 1000000);
  });

  test('getCoinByUuid maps 404 to NotFoundException', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 404,
                data: <String, dynamic>{'message': 'Coin not found'},
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );

    final client = CoinRankingApiClient(dio);

    await expectLater(
      () => client.getCoinByUuid('missing-uuid'),
      throwsA(
        isA<NotFoundException>()
            .having((error) => error.message, 'message', 'Coin not found'),
      ),
    );
  });
}
