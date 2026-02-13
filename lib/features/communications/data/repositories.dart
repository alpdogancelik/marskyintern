import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/messages_repository.dart';
import '../domain/notifications_repository.dart';
import 'mock_messages_repository.dart';
import 'mock_notifications_repository.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MockMessagesRepository();
});

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return MockNotificationsRepository();
});
