import 'allocation_slice.dart';
import 'holding.dart';
import 'portfolio_summary.dart';

class PortfolioSnapshot {
  const PortfolioSnapshot({
    required this.summary,
    required this.holdings,
    required this.allocations,
  });

  final PortfolioSummary summary;
  final List<Holding> holdings;
  final List<AllocationSlice> allocations;
}
