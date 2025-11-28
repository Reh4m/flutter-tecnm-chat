import 'package:equatable/equatable.dart';

enum ConversationType { direct, group }

class DirectChatEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final ConversationType type;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DirectChatEntity({
    required this.id,
    required this.participantIds,
    required this.type,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    this.unreadCount = const {},
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    participantIds,
    type,
    lastMessage,
    lastMessageSenderId,
    lastMessageTime,
    unreadCount,
    createdAt,
    updatedAt,
  ];

  bool get isGroup => type == ConversationType.group;
  bool get isDirect => type == ConversationType.direct;

  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  DirectChatEntity copyWith({
    String? id,
    List<String>? participantIds,
    ConversationType? type,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DirectChatEntity(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      type: type ?? this.type,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
