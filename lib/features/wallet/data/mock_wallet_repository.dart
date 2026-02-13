import '../domain/entities/recipient.dart';
import '../domain/entities/wallet_balance.dart';
import '../domain/entities/wallet_payment_method.dart';
import '../domain/entities/wallet_transaction.dart';
import '../domain/wallet_fee_calculator.dart';
import '../domain/wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  MockWalletRepository();

  WalletBalance _balance = const WalletBalance(
    currency: 'USD',
    available: 8786.55,
    pending: 240.0,
  );

  int _nextId = 10;

  final List<WalletPaymentMethod> _methods = const [
    WalletPaymentMethod(
      id: 'bank-bofa',
      type: WalletPaymentMethodType.bankTransfer,
      title: 'Bank of America',
      subtitle: 'Checked automatically',
      iconName: 'bank',
    ),
    WalletPaymentMethod(
      id: 'bank-barclays',
      type: WalletPaymentMethodType.bankTransfer,
      title: 'Barclays',
      subtitle: '**** 9907',
      iconName: 'bank',
    ),
    WalletPaymentMethod(
      id: 'card-visa',
      type: WalletPaymentMethodType.card,
      title: 'Visa',
      subtitle: '**** 4457',
      iconName: 'credit-card',
    ),
    WalletPaymentMethod(
      id: 'card-master',
      type: WalletPaymentMethodType.card,
      title: 'Mastercard',
      subtitle: '**** 3814',
      iconName: 'card-payment',
    ),
  ];

  final List<WalletTransaction> _transactions = [
    WalletTransaction(
      id: 'wtx-1',
      type: WalletTransactionType.transfer,
      amount: 21,
      fee: 0,
      status: WalletTransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      counterparty: 'Aileen Fulbright',
    ),
    WalletTransaction(
      id: 'wtx-2',
      type: WalletTransactionType.withdraw,
      amount: 120,
      fee: 2.5,
      status: WalletTransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      methodTitle: 'Visa',
    ),
    WalletTransaction(
      id: 'wtx-3',
      type: WalletTransactionType.deposit,
      amount: 325,
      fee: 0,
      status: WalletTransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      methodTitle: 'Bank of America',
    ),
    WalletTransaction(
      id: 'wtx-4',
      type: WalletTransactionType.transfer,
      amount: 60,
      fee: 0,
      status: WalletTransactionStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      counterparty: 'Leif Floyd',
    ),
  ];

  @override
  Future<WalletBalance> getBalance() async {
    return _balance;
  }

  @override
  Future<List<WalletPaymentMethod>> getPaymentMethods() async {
    return _methods;
  }

  @override
  Future<List<WalletTransaction>> getTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    if (offset >= _transactions.length) {
      return const [];
    }

    final end = (offset + limit) > _transactions.length
        ? _transactions.length
        : (offset + limit);
    return _transactions.sublist(offset, end);
  }

  @override
  Future<WalletTransaction?> getTransactionById(String id) async {
    for (final tx in _transactions) {
      if (tx.id == id) {
        return tx;
      }
    }
    return null;
  }

  @override
  Future<WalletTransaction> deposit({
    required double amount,
    required WalletPaymentMethod method,
  }) async {
    final normalizedAmount = _sanitizeAmount(amount);
    final fee = WalletFeeCalculator.depositFee(normalizedAmount);
    final tx = WalletTransaction(
      id: _nextTransactionId(),
      type: WalletTransactionType.deposit,
      amount: normalizedAmount,
      fee: fee,
      status: WalletTransactionStatus.completed,
      timestamp: DateTime.now(),
      methodTitle: method.title,
    );

    _transactions.insert(0, tx);
    _balance = _balance.copyWith(
      available: _balance.available + (normalizedAmount - fee),
    );
    return tx;
  }

  @override
  Future<WalletTransaction> transfer({
    required double amount,
    required Recipient recipient,
  }) async {
    final normalizedAmount = _sanitizeAmount(amount);
    final fee = WalletFeeCalculator.transferFee(normalizedAmount);
    final requiredTotal = normalizedAmount + fee;
    if (_balance.available < requiredTotal) {
      throw Exception('Insufficient wallet balance for transfer.');
    }

    final tx = WalletTransaction(
      id: _nextTransactionId(),
      type: WalletTransactionType.transfer,
      amount: normalizedAmount,
      fee: fee,
      status: WalletTransactionStatus.completed,
      timestamp: DateTime.now(),
      counterparty: recipient.name,
    );

    _transactions.insert(0, tx);
    _balance = _balance.copyWith(
      available: _balance.available - requiredTotal,
    );
    return tx;
  }

  @override
  Future<WalletTransaction> withdraw({
    required double amount,
    required WalletPaymentMethod method,
  }) async {
    final normalizedAmount = _sanitizeAmount(amount);
    final fee = WalletFeeCalculator.withdrawFee(normalizedAmount);
    final requiredTotal = normalizedAmount + fee;
    if (_balance.available < requiredTotal) {
      throw Exception('Insufficient wallet balance for withdrawal.');
    }

    final tx = WalletTransaction(
      id: _nextTransactionId(),
      type: WalletTransactionType.withdraw,
      amount: normalizedAmount,
      fee: fee,
      status: WalletTransactionStatus.completed,
      timestamp: DateTime.now(),
      methodTitle: method.title,
    );

    _transactions.insert(0, tx);
    _balance = _balance.copyWith(
      available: _balance.available - requiredTotal,
    );
    return tx;
  }

  String _nextTransactionId() {
    _nextId += 1;
    return 'wtx-$_nextId';
  }

  double _sanitizeAmount(double amount) {
    if (!amount.isFinite || amount <= 0) {
      throw Exception('Amount must be greater than zero.');
    }
    return double.parse(amount.toStringAsFixed(2));
  }
}
