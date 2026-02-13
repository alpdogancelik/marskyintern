enum NotificationType { emailVerified, priceAlert, depositSuccess, security }

enum NotificationStatus { unread, read }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.status,
    required this.isActivity,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationStatus status;
  final bool isActivity;

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationStatus? status,
    bool? isActivity,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isActivity: isActivity ?? this.isActivity,
    );
  }
}
