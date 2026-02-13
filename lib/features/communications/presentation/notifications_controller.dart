import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/entities/notification_item.dart';
import '../domain/notifications_repository.dart';

enum NotificationsTab { all, activity }

class NotificationsState {
  const NotificationsState({
    required this.items,
    required this.tab,
    required this.statusFilter,
  });

  final List<NotificationItem> items;
  final NotificationsTab tab;
  final NotificationStatusFilter statusFilter;

  NotificationsState copyWith({
    List<NotificationItem>? items,
    NotificationsTab? tab,
    NotificationStatusFilter? statusFilter,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      tab: tab ?? this.tab,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

final notificationsControllerProvider = StateNotifierProvider<
    NotificationsController, AsyncValue<NotificationsState>>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return NotificationsController(repository)..load();
});

class NotificationsController
    extends StateNotifier<AsyncValue<NotificationsState>> {
  NotificationsController(this._repository) : super(const AsyncLoading());

  final NotificationsRepository _repository;

  Future<void> load({
    NotificationsTab tab = NotificationsTab.all,
    NotificationStatusFilter statusFilter = NotificationStatusFilter.all,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final items = await _repository.listNotifications(
        statusFilter: statusFilter,
        activityOnly: tab == NotificationsTab.activity,
      );
      return NotificationsState(
        items: items,
        tab: tab,
        statusFilter: statusFilter,
      );
    });
  }

  Future<void> setTab(NotificationsTab tab) async {
    final current = state.valueOrNull;
    final filter = current?.statusFilter ?? NotificationStatusFilter.all;
    await load(tab: tab, statusFilter: filter);
  }

  Future<void> setStatusFilter(NotificationStatusFilter filter) async {
    final current = state.valueOrNull;
    final tab = current?.tab ?? NotificationsTab.all;
    await load(tab: tab, statusFilter: filter);
  }

  Future<void> markRead(String id) async {
    await _repository.markRead(id);
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final items = await _repository.listNotifications(
      statusFilter: current.statusFilter,
      activityOnly: current.tab == NotificationsTab.activity,
    );
    state = AsyncData(current.copyWith(items: items));
  }

  Future<NotificationItem?> getById(String id) async {
    return _repository.getNotificationById(id);
  }
}
