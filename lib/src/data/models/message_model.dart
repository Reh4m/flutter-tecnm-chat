import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.type,
    required super.content,
    super.mediaUrl,
    super.thumbnailUrl,
    required super.timestamp,
    super.readBy,
    super.status,
    super.replyToMessageId,
    super.isDeleted,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      type: _parseMessageType(data['type']),
      content: data['content'] ?? '',
      mediaUrl: data['mediaUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
      status: _parseMessageStatus(data['status']),
      replyToMessageId: data['replyToMessageId'],
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'type': _messageTypeToString(type),
      'content': content,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
      'status': _messageStatusToString(status),
      'replyToMessageId': replyToMessageId,
      'isDeleted': isDeleted,
    };
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'document':
        return MessageType.document;
      case 'emoji':
        return MessageType.emoji;
      default:
        return MessageType.text;
    }
  }

  static String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.audio:
        return 'audio';
      case MessageType.document:
        return 'document';
      case MessageType.emoji:
        return 'emoji';
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  static String _messageStatusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.failed:
        return 'failed';
    }
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      type: entity.type,
      content: entity.content,
      mediaUrl: entity.mediaUrl,
      thumbnailUrl: entity.thumbnailUrl,
      timestamp: entity.timestamp,
      readBy: entity.readBy,
      status: entity.status,
      replyToMessageId: entity.replyToMessageId,
      isDeleted: entity.isDeleted,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      content: content,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      timestamp: timestamp,
      readBy: readBy,
      status: status,
      replyToMessageId: replyToMessageId,
      isDeleted: isDeleted,
    );
  }

  @override
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? thumbnailUrl,
    DateTime? timestamp,
    List<String>? readBy,
    MessageStatus? status,
    String? replyToMessageId,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
