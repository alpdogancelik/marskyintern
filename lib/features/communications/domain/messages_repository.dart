import 'entities/message.dart';
import 'entities/message_thread.dart';

abstract class MessagesRepository {
  Future<List<MessageThread>> listThreads();

  Future<List<MessageThread>> searchThreads(String query);

  Future<List<Message>> getThreadMessages(String threadId);

  Future<Message> sendMessage({
    required String threadId,
    required String text,
  });

  Future<void> markThreadRead(String threadId);
}
