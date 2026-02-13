import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../coins/data/coins_repository_impl.dart';
import '../../coins/domain/coins_repository.dart';
import '../../coins/domain/entities/coin.dart';
import '../domain/entities/allocation_slice.dart';
import '../domain/entities/holding.dart';
import '../domain/entities/portfolio_snapshot.dart';
import '../domain/entities/portfolio_summary.dart';
import '../domain/portfolio_repository.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  final coinsRepository = ref.watch(coinsRepositoryProvider);
  return MockPortfolioRepository(coinsRepository);
});

class MockPortfolioRepository implements PortfolioRepository {
  MockPortfolioRepository(this._coinsRepository);

  final CoinsRepository _coinsRepository;

  static const _fallbackCoins =
      <String, ({String name, double price, double change})>{
    'BTC': (name: 'Bitcoin', price: 61245, change: 2.6),
    'ETH': (name: 'Ethereum', price: 3250, change: 1.9),
    'USDT': (name: 'Tether', price: 1, change: 0.0),
    'BNB': (name: 'BNB', price: 560, change: -0.8),
    'SOL': (name: 'Solana', price: 142, change: 3.2),
  };

  static const _targetSymbols = ['BTC', 'ETH', 'USDT', 'BNB', 'SOL'];
  static const _quantities = <String, double>{
    'BTC': 0.38,
    'ETH': 2.2,
    'USDT': 4300,
    'BNB': 5.5,
    'SOL': 18,
  };
  static const _avgBuyMultipliers = <String, double>{
    'BTC': 0.88,
    'ETH': 0.84,
    'USDT': 1,
    'BNB': 1.05,
    'SOL': 0.92,
  };

  @override
  Future<PortfolioSnapshot> getPortfolioSnapshot() async {
    final map = await _loadCoinMap();
    final holdings = <Holding>[];

    for (final symbol in _targetSymbols) {
      final coin = map[symbol];
      final fallback = _fallbackCoins[symbol]!;
      final currentPrice = coin?.price ?? fallback.price;
      final change = coin?.change ?? fallback.change;
      final quantity = _quantities[symbol] ?? 0;
      final avgMultiplier = _avgBuyMultipliers[symbol] ?? 1;
      final avgBuy = currentPrice * avgMultiplier;
      holdings.add(
        Holding(
          symbol: symbol,
          name: coin?.name ?? fallback.name,
          quantity: quantity,
          avgBuyPrice: avgBuy,
          currentPrice: currentPrice,
          change24h: change,
          value: quantity * currentPrice,
        ),
      );
    }

    holdings.sort((a, b) => b.value.compareTo(a.value));

    final totalValue = holdings.fold<double>(0, (sum, h) => sum + h.value);
    final totalCost = holdings.fold<double>(0, (sum, h) => sum + h.totalCost);
    final totalPnL = totalValue - totalCost;
    final totalPnLPercent = totalCost <= 0 ? 0.0 : (totalPnL / totalCost) * 100;

    final summary = PortfolioSummary(
      totalValue: totalValue,
      totalCost: totalCost,
      totalPnL: totalPnL,
      totalPnLPercent: totalPnLPercent,
    );

    final allocations = _buildAllocations(holdings, totalValue);

    return PortfolioSnapshot(
      summary: summary,
      holdings: holdings,
      allocations: allocations,
    );
  }

  Future<Map<String, Coin>> _loadCoinMap() async {
    try {
      final coins = await _coinsRepository.getCoins(
        limit: 100,
        offset: 0,
        orderBy: 'marketCap',
        orderDirection: 'desc',
      );
      final result = <String, Coin>{};
      for (final coin in coins) {
        result[coin.symbol.toUpperCase()] = coin;
      }
      return result;
    } catch (_) {
      return <String, Coin>{};
    }
  }

  List<AllocationSlice> _buildAllocations(
    List<Holding> holdings,
    double totalValue,
  ) {
    if (holdings.isEmpty || totalValue <= 0) {
      return const [];
    }

    final primary = holdings.take(4).toList(growable: false);
    final slices = <AllocationSlice>[];

    for (final holding in primary) {
      final percent = (holding.value / totalValue) * 100;
      slices.add(
        AllocationSlice(
          label: holding.symbol,
          value: holding.value,
          percent: percent,
        ),
      );
    }

    final remainder =
        holdings.skip(4).fold<double>(0, (sum, h) => sum + h.value);
    if (remainder > 0) {
      slices.add(
        AllocationSlice(
          label: 'Others',
          value: remainder,
          percent: (remainder / totalValue) * 100,
        ),
      );
    }

    return slices;
  }
}
