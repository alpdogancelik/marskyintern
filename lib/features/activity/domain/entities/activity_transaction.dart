enum ActivityType { buy, sell, deposit, withdraw }

enum ActivityStatus { completed, pending }

class ActivityTransaction {
  const ActivityTransaction({
    required this.id,
    required this.type,
    required this.symbol,
    required this.amountCrypto,
    required this.amountFiat,
    required this.fee,
    required this.status,
    required this.timestamp,
  });

  final String id;
  final ActivityType type;
  final String symbol;
  final double amountCrypto;
  final double amountFiat;
  final double fee;
  final ActivityStatus status;
  final DateTime timestamp;

  String get actionLabel {
    return switch (type) {
      ActivityType.buy => 'Buy',
      ActivityType.sell => 'Sell',
      ActivityType.deposit => 'Deposit',
      ActivityType.withdraw => 'Withdraw',
    };
  }
}
