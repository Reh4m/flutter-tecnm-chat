import 'package:equatable/equatable.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';

enum ConversationType { direct, group }

class ChatEntity extends Equatable {
  final String id;
  final ConversationType type;
  final List<String> participantIds;

  final String? lastMessage;
  final String? lastMessageSenderId;
  final MessageType? lastMessageType;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatEntity({
    required this.id,
    required this.type,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageType,
    this.lastMessageTime,
    this.unreadCount = const {},
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    participantIds,
    lastMessage,
    lastMessageSenderId,
    lastMessageType,
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
}
