import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/entities/message.dart';
import '../domain/entities/message_thread.dart';
import '../domain/messages_repository.dart';

enum MessagesFilter { all, unread, unanswered }

class MessagesState {
  const MessagesState({
    required this.threads,
    required this.filter,
    required this.threadMessages,
    required this.searchResults,
    this.searchQuery = '',
  });

  final List<MessageThread> threads;
  final MessagesFilter filter;
  final Map<String, List<Message>> threadMessages;
  final List<MessageThread> searchResults;
  final String searchQuery;

  List<MessageThread> get filteredThreads {
    return switch (filter) {
      MessagesFilter.all => threads,
      MessagesFilter.unread => threads
          .where((thread) => thread.unreadCount > 0)
          .toList(growable: false),
      MessagesFilter.unanswered =>
        threads.where((thread) => thread.unanswered).toList(growable: false),
    };
  }

  MessageThread? threadById(String id) {
    for (final thread in threads) {
      if (thread.id == id) {
        return thread;
      }
    }
    return null;
  }

  MessagesState copyWith({
    List<MessageThread>? threads,
    MessagesFilter? filter,
    Map<String, List<Message>>? threadMessages,
    List<MessageThread>? searchResults,
    String? searchQuery,
  }) {
    return MessagesState(
      threads: threads ?? this.threads,
      filter: filter ?? this.filter,
      threadMessages: threadMessages ?? this.threadMessages,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final messagesControllerProvider =
    StateNotifierProvider<MessagesController, AsyncValue<MessagesState>>((ref) {
  final repository = ref.watch(messagesRepositoryProvider);
  return MessagesController(repository)..load();
});

class MessagesController extends StateNotifier<AsyncValue<MessagesState>> {
  MessagesController(this._repository) : super(const AsyncLoading());

  final MessagesRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final threads = await _repository.listThreads();
      return MessagesState(
        threads: threads,
        filter: MessagesFilter.all,
        threadMessages: <String, List<Message>>{},
        searchResults: threads,
      );
    });
  }

  void setFilter(MessagesFilter filter) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(filter: filter));
  }

  Future<void> search(String query) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final results = await _repository.searchThreads(query);
    state = AsyncData(
      current.copyWith(
        searchQuery: query,
        searchResults: results,
      ),
    );
  }

  Future<void> openThread(String threadId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _repository.markThreadRead(threadId);
    final threads = await _repository.listThreads();
    final messages = await _repository.getThreadMessages(threadId);

    final nextMap = Map<String, List<Message>>.from(current.threadMessages);
    nextMap[threadId] = messages;

    state = AsyncData(
      current.copyWith(
        threads: threads,
        searchResults: _rebuildSearchResults(current.searchQuery, threads),
        threadMessages: nextMap,
      ),
    );
  }

  Future<void> sendThreadMessage({
    required String threadId,
    required String text,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _repository.sendMessage(threadId: threadId, text: text);
    final threads = await _repository.listThreads();
    final messages = await _repository.getThreadMessages(threadId);

    final nextMap = Map<String, List<Message>>.from(current.threadMessages);
    nextMap[threadId] = messages;

    state = AsyncData(
      current.copyWith(
        threads: threads,
        searchResults: _rebuildSearchResults(current.searchQuery, threads),
        threadMessages: nextMap,
      ),
    );
  }

  List<MessageThread> _rebuildSearchResults(
    String query,
    List<MessageThread> source,
  ) {
    final normalized = query.trim().toLowerCase();
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
}
