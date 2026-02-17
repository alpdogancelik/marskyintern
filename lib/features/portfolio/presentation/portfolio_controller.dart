import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/entities/portfolio_snapshot.dart';

enum PortfolioSegment { crypto, stocks }

final portfolioSnapshotProvider =
    FutureProvider.autoDispose<PortfolioSnapshot>((ref) async {
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.getPortfolioSnapshot();
});

final portfolioSegmentProvider =
    StateProvider.autoDispose<PortfolioSegment>((ref) {
  return PortfolioSegment.crypto;
});
