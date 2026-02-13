enum WalletTransactionType { deposit, withdraw, transfer }

enum WalletTransactionStatus { completed, pending, failed }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.fee,
    required this.status,
    required this.timestamp,
    this.counterparty,
    this.methodTitle,
  });

  final String id;
  final WalletTransactionType type;
  final double amount;
  final double fee;
  final WalletTransactionStatus status;
  final DateTime timestamp;
  final String? counterparty;
  final String? methodTitle;
}
