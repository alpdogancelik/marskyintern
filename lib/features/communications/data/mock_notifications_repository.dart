import '../domain/entities/notification_item.dart';
import '../domain/notifications_repository.dart';

class MockNotificationsRepository implements NotificationsRepository {
  final List<NotificationItem> _items = [
    NotificationItem(
      id: 'n-1',
      type: NotificationType.emailVerified,
      title: 'Email verified',
      body: 'Your account security level has been upgraded.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      status: NotificationStatus.unread,
      isActivity: false,
    ),
    NotificationItem(
      id: 'n-2',
      type: NotificationType.priceAlert,
      title: 'Price alert',
      body: 'BTC moved +3.2% in the last hour.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
      status: NotificationStatus.unread,
      isActivity: true,
    ),
    NotificationItem(
      id: 'n-3',
      type: NotificationType.depositSuccess,
      title: 'Deposit success',
      body: 'USD 320.00 has been credited to your wallet.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 6)),
      status: NotificationStatus.read,
      isActivity: true,
    ),
    NotificationItem(
      id: 'n-4',
      type: NotificationType.security,
      title: 'Security update',
      body: 'New login detected from a trusted device.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: NotificationStatus.read,
      isActivity: false,
    ),
    NotificationItem(
      id: 'n-5',
      type: NotificationType.priceAlert,
      title: 'Price alert',
      body: 'ETH moved -1.4% in the last 24h.',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      status: NotificationStatus.read,
      isActivity: true,
    ),
  ];

  @override
  Future<NotificationItem?> getNotificationById(String id) async {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<NotificationItem>> listNotifications({
    NotificationStatusFilter statusFilter = NotificationStatusFilter.all,
    bool activityOnly = false,
  }) async {
    final result = _items.where((item) {
      if (activityOnly && !item.isActivity) {
        return false;
      }
      return switch (statusFilter) {
        NotificationStatusFilter.all => true,
        NotificationStatusFilter.read => item.status == NotificationStatus.read,
        NotificationStatusFilter.unread =>
          item.status == NotificationStatus.unread,
      };
    }).toList(growable: false)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return result;
  }

  @override
  Future<void> markRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    _items[index] = _items[index].copyWith(status: NotificationStatus.read);
  }
}
