import 'entities/activity_transaction.dart';

abstract class ActivityRepository {
  Future<List<ActivityTransaction>> getTransactions();

  Future<ActivityTransaction?> getTransactionById(String id);
}
