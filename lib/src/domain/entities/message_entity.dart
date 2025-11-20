import 'package:equatable/equatable.dart';

enum MessageType { text, image, video, audio, document, emoji }

enum MessageStatus { sending, sent, delivered, read, failed }

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final DateTime timestamp;
  final List<String> readBy;
  final MessageStatus status;
  final String? replyToMessageId;
  final bool isDeleted;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.timestamp,
    this.readBy = const [],
    this.status = MessageStatus.sent,
    this.replyToMessageId,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    type,
    content,
    mediaUrl,
    thumbnailUrl,
    timestamp,
    readBy,
    status,
    replyToMessageId,
    isDeleted,
  ];

  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  bool get isTextMessage => type == MessageType.text;
  bool get isMediaMessage =>
      type == MessageType.image ||
      type == MessageType.video ||
      type == MessageType.audio;

  MessageEntity copyWith({
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
    return MessageEntity(
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
