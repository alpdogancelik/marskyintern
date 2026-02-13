import 'entities/recipient.dart';
import 'entities/wallet_balance.dart';
import 'entities/wallet_payment_method.dart';
import 'entities/wallet_transaction.dart';

abstract class WalletRepository {
  Future<WalletBalance> getBalance();

  Future<List<WalletTransaction>> getTransactions({
    int limit = 20,
    int offset = 0,
  });

  Future<List<WalletPaymentMethod>> getPaymentMethods();

  Future<WalletTransaction> deposit({
    required double amount,
    required WalletPaymentMethod method,
  });

  Future<WalletTransaction> withdraw({
    required double amount,
    required WalletPaymentMethod method,
  });

  Future<WalletTransaction> transfer({
    required double amount,
    required Recipient recipient,
  });

  Future<WalletTransaction?> getTransactionById(String id);
}
