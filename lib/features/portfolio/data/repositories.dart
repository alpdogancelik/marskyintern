import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/env.dart';
import '../../coins/data/repositories.dart';
import '../domain/portfolio_repository.dart';
import 'mock_portfolio_repository.dart' show MockPortfolioRepository;
import 'portfolio_repository_impl.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  final coinsRepository = ref.watch(coinsRepositoryProvider);
  if (Env.useMockCoins) {
    return MockPortfolioRepository(coinsRepository);
  }
  return PortfolioRepositoryImpl(coinsRepository);
});
