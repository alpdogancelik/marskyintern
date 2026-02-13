import 'entities/notification_item.dart';

enum NotificationStatusFilter { all, read, unread }

abstract class NotificationsRepository {
  Future<List<NotificationItem>> listNotifications({
    NotificationStatusFilter statusFilter = NotificationStatusFilter.all,
    bool activityOnly = false,
  });

  Future<NotificationItem?> getNotificationById(String id);

  Future<void> markRead(String id);
}
