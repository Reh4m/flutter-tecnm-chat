import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';

class DirectChatEntity extends ChatEntity {
  const DirectChatEntity({
    required super.id,
    required super.participantIds,
    required super.type,
    super.lastMessage,
    super.lastMessageSenderId,
    super.lastMessageType,
    super.lastMessageTime,
    super.unreadCount,
    required super.createdAt,
    super.updatedAt,
  });

  DirectChatEntity copyWith({
    String? id,
    List<String>? participantIds,
    ConversationType? type,
    String? lastMessage,
    String? lastMessageSenderId,
    MessageType? lastMessageType,
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
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
