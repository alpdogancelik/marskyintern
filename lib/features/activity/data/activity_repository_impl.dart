import '../../../core/errors/app_exception.dart';
import '../../coins/domain/coins_repository.dart';
import '../domain/activity_repository.dart';
import '../domain/entities/activity_transaction.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this._coinsRepository);

  final CoinsRepository _coinsRepository;
  List<ActivityTransaction>? _cache;

  @override
  Future<List<ActivityTransaction>> getTransactions() async {
    if (_cache != null) {
      return _cache!;
    }

    final symbols = await _loadTradeableSymbols();
    final now = DateTime.now();
    final specs = <_TxSpec>[
      _TxSpec(
          type: ActivityType.sell,
          crypto: 250,
          fee: 1.2,
          status: ActivityStatus.completed,
          daysAgo: 0,
          hoursOffset: 2,
          symbolIndex: 2),
      _TxSpec(
          type: ActivityType.buy,
          crypto: 0.021,
          fee: 3.1,
          status: ActivityStatus.completed,
          daysAgo: 0,
          hoursOffset: 5,
          symbolIndex: 0),
      _TxSpec(
          type: ActivityType.deposit,
          crypto: 1200,
          fee: 0,
          status: ActivityStatus.completed,
          daysAgo: 0,
          hoursOffset: 8,
          symbolIndex: 1),
      _TxSpec(
          type: ActivityType.withdraw,
          crypto: 0.45,
          fee: 2.4,
          status: ActivityStatus.pending,
          daysAgo: 1,
          hoursOffset: 3,
          symbolIndex: 3),
      _TxSpec(
          type: ActivityType.buy,
          crypto: 7.8,
          fee: 1.8,
          status: ActivityStatus.completed,
          daysAgo: 1,
          hoursOffset: 7,
          symbolIndex: 4),
      _TxSpec(
          type: ActivityType.sell,
          crypto: 2.4,
          fee: 1.6,
          status: ActivityStatus.completed,
          daysAgo: 2,
          hoursOffset: 4,
          symbolIndex: 5),
      _TxSpec(
          type: ActivityType.buy,
          crypto: 0.009,
          fee: 2.2,
          status: ActivityStatus.completed,
          daysAgo: 3,
          hoursOffset: 6,
          symbolIndex: 0),
      _TxSpec(
          type: ActivityType.deposit,
          crypto: 800,
          fee: 0,
          status: ActivityStatus.completed,
          daysAgo: 4,
          hoursOffset: 1,
          symbolIndex: 1),
      _TxSpec(
          type: ActivityType.buy,
          crypto: 1000,
          fee: 1.1,
          status: ActivityStatus.completed,
          daysAgo: 5,
          hoursOffset: 9,
          symbolIndex: 2),
      _TxSpec(
          type: ActivityType.sell,
          crypto: 3,
          fee: 1.4,
          status: ActivityStatus.pending,
          daysAgo: 6,
          hoursOffset: 4,
          symbolIndex: 4),
    ];

    _cache = specs.asMap().entries.map((entry) {
      final spec = entry.value;
      final symbolPrice = symbols[spec.symbolIndex % symbols.length];
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
        symbol: symbolPrice.symbol,
        amountCrypto: spec.crypto,
        amountFiat: spec.crypto * symbolPrice.price,
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

  Future<List<_SymbolPrice>> _loadTradeableSymbols() async {
    final coins = await _coinsRepository.getCoins(
      limit: 60,
      offset: 0,
      orderBy: 'marketCap',
      orderDirection: 'desc',
    );
    if (coins.isEmpty) {
      throw const ApiException(
        'Unable to load market prices for activity feed.',
      );
    }

    final symbols = coins
        .where((coin) => coin.price > 0 && coin.symbol.trim().isNotEmpty)
        .take(12)
        .map((coin) =>
            _SymbolPrice(symbol: coin.symbol.toUpperCase(), price: coin.price))
        .toList(growable: false);
    if (symbols.isEmpty) {
      throw const ParsingException(
        'Unable to parse market symbols for activity feed.',
      );
    }
    return symbols;
  }
}

class _TxSpec {
  const _TxSpec({
    required this.type,
    required this.crypto,
    required this.fee,
    required this.status,
    required this.daysAgo,
    required this.hoursOffset,
    required this.symbolIndex,
  });

  final ActivityType type;
  final double crypto;
  final double fee;
  final ActivityStatus status;
  final int daysAgo;
  final int hoursOffset;
  final int symbolIndex;
}

class _SymbolPrice {
  const _SymbolPrice({
    required this.symbol,
    required this.price,
  });

  final String symbol;
  final double price;
}
