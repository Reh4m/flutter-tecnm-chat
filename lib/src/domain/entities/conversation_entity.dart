import 'package:equatable/equatable.dart';

enum ConversationType { direct, group }

class ConversationEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final ConversationType type;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? groupName;
  final String? groupAvatarUrl;
  final bool? hidePhoneNumbers;

  const ConversationEntity({
    required this.id,
    required this.participantIds,
    required this.type,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    this.unreadCount = const {},
    required this.createdAt,
    this.updatedAt,
    this.groupName,
    this.groupAvatarUrl,
    this.hidePhoneNumbers,
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
    groupName,
    groupAvatarUrl,
    hidePhoneNumbers,
  ];

  bool get isGroup => type == ConversationType.group;
  bool get isDirect => type == ConversationType.direct;

  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  ConversationEntity copyWith({
    String? id,
    List<String>? participantIds,
    ConversationType? type,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? groupName,
    String? groupAvatarUrl,
    bool? hidePhoneNumbers,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      type: type ?? this.type,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupName: groupName ?? this.groupName,
      groupAvatarUrl: groupAvatarUrl ?? this.groupAvatarUrl,
      hidePhoneNumbers: hidePhoneNumbers ?? this.hidePhoneNumbers,
    );
  }
}
