import 'activity_transaction.dart';

class TransactionGroup {
  const TransactionGroup({
    required this.date,
    required this.items,
  });

  final DateTime date;
  final List<ActivityTransaction> items;
}
