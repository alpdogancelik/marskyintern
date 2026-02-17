import '../../../core/errors/app_exception.dart';
import '../../coins/domain/coins_repository.dart';
import '../../coins/domain/entities/coin.dart';
import '../domain/entities/allocation_slice.dart';
import '../domain/entities/holding.dart';
import '../domain/entities/portfolio_snapshot.dart';
import '../domain/entities/portfolio_summary.dart';
import '../domain/portfolio_repository.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl(this._coinsRepository);

  final CoinsRepository _coinsRepository;

  static const _preferredSymbols = <String>['BTC', 'ETH', 'USDT', 'BNB', 'SOL'];
  static const _baseQuantities = <String, double>{
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
    final universe = await _coinsRepository.getCoins(
      limit: 80,
      offset: 0,
      orderBy: 'marketCap',
      orderDirection: 'desc',
    );

    if (universe.isEmpty) {
      throw const ApiException(
        'Unable to load market prices for portfolio.',
      );
    }

    final selectedCoins = _selectCoins(universe);
    final holdings = selectedCoins.map(_buildHolding).toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalValue = holdings.fold<double>(0, (sum, h) => sum + h.value);
    final totalCost = holdings.fold<double>(0, (sum, h) => sum + h.totalCost);
    final totalPnL = totalValue - totalCost;
    final totalPnLPercent = totalCost <= 0 ? 0.0 : (totalPnL / totalCost) * 100;

    return PortfolioSnapshot(
      summary: PortfolioSummary(
        totalValue: totalValue,
        totalCost: totalCost,
        totalPnL: totalPnL,
        totalPnLPercent: totalPnLPercent,
      ),
      holdings: holdings,
      allocations: _buildAllocations(holdings, totalValue),
    );
  }

  List<Coin> _selectCoins(List<Coin> coins) {
    final bySymbol = <String, Coin>{
      for (final coin in coins) coin.symbol.toUpperCase(): coin,
    };
    final selected = <Coin>[];
    final usedSymbols = <String>{};

    for (final symbol in _preferredSymbols) {
      final coin = bySymbol[symbol];
      if (coin == null) {
        continue;
      }
      selected.add(coin);
      usedSymbols.add(symbol);
    }

    if (selected.length >= 5) {
      return selected.take(5).toList(growable: false);
    }

    for (final coin in coins) {
      final symbol = coin.symbol.toUpperCase();
      if (usedSymbols.contains(symbol)) {
        continue;
      }
      selected.add(coin);
      usedSymbols.add(symbol);
      if (selected.length >= 5) {
        break;
      }
    }

    return selected;
  }

  Holding _buildHolding(Coin coin) {
    final symbol = coin.symbol.toUpperCase();
    final quantity = _baseQuantities[symbol] ?? _derivedQuantity(coin);
    final avgMultiplier = _avgBuyMultipliers[symbol] ?? 0.93;
    final avgBuy = coin.price * avgMultiplier;

    return Holding(
      symbol: symbol,
      name: coin.name,
      quantity: quantity,
      avgBuyPrice: avgBuy,
      currentPrice: coin.price,
      change24h: coin.change,
      value: quantity * coin.price,
    );
  }

  double _derivedQuantity(Coin coin) {
    if (coin.price <= 0) {
      return 0;
    }
    final seed = (coin.rank <= 0 ? 1 : coin.rank).toDouble();
    final targetValue = 900 + (seed * 120);
    return targetValue / coin.price;
  }

  List<AllocationSlice> _buildAllocations(
    List<Holding> holdings,
    double totalValue,
  ) {
    if (holdings.isEmpty || totalValue <= 0) {
      return const <AllocationSlice>[];
    }

    final top = holdings.take(4).toList(growable: false);
    final slices = <AllocationSlice>[
      for (final holding in top)
        AllocationSlice(
          label: holding.symbol,
          value: holding.value,
          percent: (holding.value / totalValue) * 100,
        ),
    ];

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
