import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/env.dart';
import '../../coins/data/coin_history_api.dart';
import '../../coins/data/repositories.dart';
import '../domain/stocks_repository.dart';
import 'mock_stocks_repository.dart' show MockStocksRepository;
import 'stocks_repository_impl.dart';

final stocksRepositoryProvider = Provider<StocksRepository>((ref) {
  if (Env.useMockCoins) {
    return MockStocksRepository();
  }

  return StocksRepositoryImpl(
    coinsRepository: ref.watch(coinsRepositoryProvider),
    coinHistoryApi: ref.watch(coinHistoryApiProvider),
  );
});
