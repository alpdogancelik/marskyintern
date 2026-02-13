import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../coins/data/coins_repository_impl.dart';
import '../../coins/domain/coins_repository.dart';
import '../domain/activity_repository.dart';
import '../domain/entities/activity_transaction.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final coinsRepository = ref.watch(coinsRepositoryProvider);
  return MockActivityRepository(coinsRepository);
});

class MockActivityRepository implements ActivityRepository {
  MockActivityRepository(this._coinsRepository);

  final CoinsRepository _coinsRepository;
  List<ActivityTransaction>? _cache;

  static const _fallbackPrices = <String, double>{
    'BTC': 61245,
    'ETH': 3250,
    'ADA': 0.52,
    'SOL': 142,
    'USDT': 1,
    'BNB': 560,
  };

  @override
  Future<List<ActivityTransaction>> getTransactions() async {
    if (_cache != null) {
      return _cache!;
    }

    final priceMap = await _loadPriceMap();
    final now = DateTime.now();
    final specs = <({
      String symbol,
      ActivityType type,
      double crypto,
      double fee,
      ActivityStatus status,
      int daysAgo,
      int hoursOffset,
    })>[
      (
        symbol: 'ADA',
        type: ActivityType.sell,
        crypto: 250,
        fee: 1.2,
        status: ActivityStatus.completed,
        daysAgo: 0,
        hoursOffset: 2,
      ),
      (
        symbol: 'BTC',
        type: ActivityType.buy,
        crypto: 0.021,
        fee: 3.1,
        status: ActivityStatus.completed,
        daysAgo: 0,
        hoursOffset: 5,
      ),
      (
        symbol: 'USDT',
        type: ActivityType.deposit,
        crypto: 1200,
        fee: 0,
        status: ActivityStatus.completed,
        daysAgo: 0,
        hoursOffset: 8,
      ),
      (
        symbol: 'ETH',
        type: ActivityType.withdraw,
        crypto: 0.45,
        fee: 2.4,
        status: ActivityStatus.pending,
        daysAgo: 1,
        hoursOffset: 3,
      ),
      (
        symbol: 'SOL',
        type: ActivityType.buy,
        crypto: 7.8,
        fee: 1.8,
        status: ActivityStatus.completed,
        daysAgo: 1,
        hoursOffset: 7,
      ),
      (
        symbol: 'BNB',
        type: ActivityType.sell,
        crypto: 2.4,
        fee: 1.6,
        status: ActivityStatus.completed,
        daysAgo: 2,
        hoursOffset: 4,
      ),
      (
        symbol: 'BTC',
        type: ActivityType.buy,
        crypto: 0.009,
        fee: 2.2,
        status: ActivityStatus.completed,
        daysAgo: 3,
        hoursOffset: 6,
      ),
      (
        symbol: 'USDT',
        type: ActivityType.deposit,
        crypto: 800,
        fee: 0,
        status: ActivityStatus.completed,
        daysAgo: 4,
        hoursOffset: 1,
      ),
      (
        symbol: 'ADA',
        type: ActivityType.buy,
        crypto: 1000,
        fee: 1.1,
        status: ActivityStatus.completed,
        daysAgo: 5,
        hoursOffset: 9,
      ),
      (
        symbol: 'SOL',
        type: ActivityType.sell,
        crypto: 3,
        fee: 1.4,
        status: ActivityStatus.pending,
        daysAgo: 6,
        hoursOffset: 4,
      ),
    ];

    _cache = specs.asMap().entries.map((entry) {
      final spec = entry.value;
      final unitPrice =
          priceMap[spec.symbol] ?? _fallbackPrices[spec.symbol] ?? 1;
      final amountFiat = spec.crypto * unitPrice;
      final timestamp = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: spec.daysAgo)).add(
            Duration(hours: 22 - spec.hoursOffset),
          );

      return ActivityTransaction(
        id: 'tx-${entry.key + 1}',
        type: spec.type,
        symbol: spec.symbol,
        amountCrypto: spec.crypto,
        amountFiat: amountFiat,
        fee: spec.fee,
        status: spec.status,
        timestamp: timestamp,
      );
    }).toList(growable: false)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return _cache!;
  }

  @override
  Future<ActivityTransaction?> getTransactionById(String id) async {
    final items = await getTransactions();
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Future<Map<String, double>> _loadPriceMap() async {
    try {
      final coins = await _coinsRepository.getCoins(
        limit: 120,
        offset: 0,
        orderBy: 'marketCap',
        orderDirection: 'desc',
      );
      final map = <String, double>{};
      for (final coin in coins) {
        map[coin.symbol.toUpperCase()] = coin.price;
      }
      return map;
    } catch (_) {
      return const {};
    }
  }
}
