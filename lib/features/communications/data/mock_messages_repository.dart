import '../domain/entities/message.dart';
import '../domain/entities/message_thread.dart';
import '../domain/messages_repository.dart';

class MockMessagesRepository implements MessagesRepository {
  int _sequence = 100;

  final List<MessageThread> _threads = [
    MessageThread(
      id: 'thread-1',
      name: 'Marielle Wigington',
      avatarSymbol: 'ETH',
      lastMessage: 'Hello, we are checking if all items came through.',
      unreadCount: 2,
      updatedAt: DateTime.now().subtract(const Duration(minutes: 6)),
      pinned: true,
      unanswered: false,
    ),
    MessageThread(
      id: 'thread-2',
      name: 'Tyra Dhillon',
      avatarSymbol: 'BTC',
      lastMessage: 'Can you share the transfer screenshot?',
      unreadCount: 1,
      updatedAt: DateTime.now().subtract(const Duration(minutes: 39)),
      pinned: true,
      unanswered: true,
    ),
    MessageThread(
      id: 'thread-3',
      name: 'Marci Senter',
      avatarSymbol: 'SOL',
      lastMessage: 'Let us check and come back shortly.',
      unreadCount: 0,
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      pinned: false,
      unanswered: false,
    ),
    MessageThread(
      id: 'thread-4',
      name: 'Rachel Fose',
      avatarSymbol: 'ADA',
      lastMessage: 'Your ticket is now closed.',
      unreadCount: 0,
      updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      pinned: false,
      unanswered: false,
    ),
    MessageThread(
      id: 'thread-5',
      name: 'Rodolfo Goode',
      avatarSymbol: 'BNB',
      lastMessage: 'Thanks for your update.',
      unreadCount: 0,
      updatedAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      pinned: false,
      unanswered: false,
    ),
  ];

  final Map<String, List<Message>> _messages = {
    'thread-1': [
      Message(
        id: 'm-1',
        threadId: 'thread-1',
        sender: 'Marielle Wigington',
        text:
            'Hello Helen! We checked your account and all assets are visible.',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 4, minutes: 20)),
        type: MessageType.text,
        isOutgoing: false,
      ),
      Message(
        id: 'm-2',
        threadId: 'thread-1',
        sender: 'You',
        text: 'Most of them are visible, but one transfer is delayed.',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 3, minutes: 52)),
        type: MessageType.text,
        isOutgoing: true,
      ),
      Message(
        id: 'm-3',
        threadId: 'thread-1',
        sender: 'Marielle Wigington',
        text: 'Please send the payment preview card.',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 31)),
        type: MessageType.text,
        isOutgoing: false,
      ),
      Message(
        id: 'm-4',
        threadId: 'thread-1',
        sender: 'You',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 12)),
        type: MessageType.image,
        isOutgoing: true,
        attachment: const Attachment(
          type: AttachmentType.card,
          title: 'Payment Preview',
          subtitle: 'Transfer to Helen - \$320.00',
          previewAsset:
              'lib/media/svg/illustrations/qr-payment-with-payment-machine-and-phone.svg',
        ),
      ),
      Message(
        id: 'm-5',
        threadId: 'thread-1',
        sender: 'Marielle Wigington',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
        type: MessageType.voice,
        isOutgoing: false,
        voiceDuration: const Duration(seconds: 26),
      ),
    ],
    'thread-2': [
      Message(
        id: 'm-6',
        threadId: 'thread-2',
        sender: 'Tyra Dhillon',
        text: 'Hi, any update on your withdrawal case?',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 12)),
        type: MessageType.text,
        isOutgoing: false,
      ),
      Message(
        id: 'm-7',
        threadId: 'thread-2',
        sender: 'You',
        text: 'I am waiting for the final confirmation.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 48)),
        type: MessageType.text,
        isOutgoing: true,
      ),
    ],
    'thread-3': [
      Message(
        id: 'm-8',
        threadId: 'thread-3',
        sender: 'Marci Senter',
        text: 'Thanks. We have escalated your request.',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 3, minutes: 25)),
        type: MessageType.text,
        isOutgoing: false,
      ),
    ],
  };

  @override
  Future<List<MessageThread>> listThreads() async {
    final result = List<MessageThread>.from(_threads)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  @override
  Future<List<MessageThread>> searchThreads(String query) async {
    final normalized = query.trim().toLowerCase();
    final source = await listThreads();
    if (normalized.isEmpty) {
      return source;
    }
    return source
        .where(
          (thread) =>
              thread.name.toLowerCase().contains(normalized) ||
              thread.lastMessage.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  @override
  Future<List<Message>> getThreadMessages(String threadId) async {
    final items = _messages[threadId] ?? const <Message>[];
    return List<Message>.from(items)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<void> markThreadRead(String threadId) async {
    final index = _threads.indexWhere((thread) => thread.id == threadId);
    if (index < 0) {
      return;
    }
    _threads[index] = _threads[index].copyWith(unreadCount: 0);
  }

  @override
  Future<Message> sendMessage({
    required String threadId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw Exception('Message cannot be empty.');
    }

    _sequence += 1;
    final message = Message(
      id: 'm-$_sequence',
      threadId: threadId,
      sender: 'You',
      text: trimmed,
      timestamp: DateTime.now(),
      type: MessageType.text,
      isOutgoing: true,
    );

    final existing = _messages[threadId] ?? <Message>[];
    _messages[threadId] = [...existing, message];

    final threadIndex = _threads.indexWhere((thread) => thread.id == threadId);
    if (threadIndex >= 0) {
      final original = _threads[threadIndex];
      _threads[threadIndex] = original.copyWith(
        lastMessage: trimmed,
        updatedAt: message.timestamp,
        unanswered: false,
      );
    }

    return message;
  }
}
