class MessageThread {
  const MessageThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
    required this.pinned,
    required this.unanswered,
    this.avatarSymbol,
  });

  final String id;
  final String name;
  final String? avatarSymbol;
  final String lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final bool pinned;
  final bool unanswered;

  MessageThread copyWith({
    String? id,
    String? name,
    Object? avatarSymbol = _sentinel,
    String? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
    bool? pinned,
    bool? unanswered,
  }) {
    return MessageThread(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarSymbol: identical(avatarSymbol, _sentinel)
          ? this.avatarSymbol
          : avatarSymbol as String?,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      pinned: pinned ?? this.pinned,
      unanswered: unanswered ?? this.unanswered,
    );
  }
}

const _sentinel = Object();
