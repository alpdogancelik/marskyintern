import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/activity_repository.dart';
import '../domain/entities/activity_transaction.dart';
import '../domain/entities/transaction_group.dart';

enum ActivityTypeFilter { all, buy, sell, deposit, withdraw }

enum ActivityStatusFilter { all, completed, pending }

class ActivityState {
  const ActivityState({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.groups,
    required this.typeFilter,
    required this.statusFilter,
  });

  final List<ActivityTransaction> allTransactions;
  final List<ActivityTransaction> filteredTransactions;
  final List<TransactionGroup> groups;
  final ActivityTypeFilter typeFilter;
  final ActivityStatusFilter statusFilter;

  double get totalIncoming {
    return filteredTransactions
        .where((tx) =>
            tx.type == ActivityType.buy || tx.type == ActivityType.deposit)
        .fold<double>(0, (sum, tx) => sum + tx.amountFiat);
  }

  double get totalOutgoing {
    return filteredTransactions
        .where((tx) =>
            tx.type == ActivityType.sell || tx.type == ActivityType.withdraw)
        .fold<double>(0, (sum, tx) => sum + tx.amountFiat);
  }

  ActivityState copyWith({
    List<ActivityTransaction>? allTransactions,
    List<ActivityTransaction>? filteredTransactions,
    List<TransactionGroup>? groups,
    ActivityTypeFilter? typeFilter,
    ActivityStatusFilter? statusFilter,
  }) {
    return ActivityState(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      groups: groups ?? this.groups,
      typeFilter: typeFilter ?? this.typeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

final activityControllerProvider =
    StateNotifierProvider<ActivityController, AsyncValue<ActivityState>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return ActivityController(repository)..load();
});

class ActivityController extends StateNotifier<AsyncValue<ActivityState>> {
  ActivityController(this._repository) : super(const AsyncLoading());

  final ActivityRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final transactions = await _repository.getTransactions();
      return _buildState(
        allTransactions: transactions,
        typeFilter: ActivityTypeFilter.all,
        statusFilter: ActivityStatusFilter.all,
      );
    });
  }

  void applyFilters({
    required ActivityTypeFilter typeFilter,
    required ActivityStatusFilter statusFilter,
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final nextState = _buildState(
      allTransactions: current.allTransactions,
      typeFilter: typeFilter,
      statusFilter: statusFilter,
    );
    state = AsyncData(nextState);
  }

  ActivityState _buildState({
    required List<ActivityTransaction> allTransactions,
    required ActivityTypeFilter typeFilter,
    required ActivityStatusFilter statusFilter,
  }) {
    final filtered = allTransactions.where((tx) {
      if (!_matchesType(tx, typeFilter)) {
        return false;
      }
      if (!_matchesStatus(tx, statusFilter)) {
        return false;
      }
      return true;
    }).toList(growable: false)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final grouped = _groupByDate(filtered);

    return ActivityState(
      allTransactions: allTransactions,
      filteredTransactions: filtered,
      groups: grouped,
      typeFilter: typeFilter,
      statusFilter: statusFilter,
    );
  }

  bool _matchesType(ActivityTransaction tx, ActivityTypeFilter filter) {
    return switch (filter) {
      ActivityTypeFilter.all => true,
      ActivityTypeFilter.buy => tx.type == ActivityType.buy,
      ActivityTypeFilter.sell => tx.type == ActivityType.sell,
      ActivityTypeFilter.deposit => tx.type == ActivityType.deposit,
      ActivityTypeFilter.withdraw => tx.type == ActivityType.withdraw,
    };
  }

  bool _matchesStatus(ActivityTransaction tx, ActivityStatusFilter filter) {
    return switch (filter) {
      ActivityStatusFilter.all => true,
      ActivityStatusFilter.completed => tx.status == ActivityStatus.completed,
      ActivityStatusFilter.pending => tx.status == ActivityStatus.pending,
    };
  }

  List<TransactionGroup> _groupByDate(List<ActivityTransaction> items) {
    final map = <DateTime, List<ActivityTransaction>>{};
    for (final item in items) {
      final day = DateTime(
          item.timestamp.year, item.timestamp.month, item.timestamp.day);
      map.putIfAbsent(day, () => <ActivityTransaction>[]).add(item);
    }

    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys
        .map((key) => TransactionGroup(date: key, items: map[key] ?? const []))
        .toList(growable: false);
  }
}

final activityTransactionProvider = FutureProvider.autoDispose
    .family<ActivityTransaction?, String>((ref, id) async {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getTransactionById(id);
});
