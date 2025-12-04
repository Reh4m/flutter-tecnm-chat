import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';

class GroupEntity extends ChatEntity {
  final String name;
  final String? description;
  final String? avatarUrl;
  final String createdBy;
  final List<String> adminIds;
  final bool hidePhoneNumbers;

  const GroupEntity({
    required super.id,
    required super.participantIds,
    required super.type,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.createdBy,
    required this.adminIds,
    this.hidePhoneNumbers = false,
    super.lastMessage,
    super.lastMessageSenderId,
    super.lastMessageType,
    super.lastMessageTime,
    super.unreadCount,
    required super.createdAt,
    super.updatedAt,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    description,
    avatarUrl,
    createdBy,
    adminIds,
    hidePhoneNumbers,
  ];

  int get memberCount => participantIds.length;

  bool isAdmin(String userId) => adminIds.contains(userId);
  bool isMember(String userId) => participantIds.contains(userId);
  bool isCreator(String userId) => createdBy == userId;

  GroupEntity copyWith({
    String? id,
    List<String>? participantIds,
    ConversationType? type,
    String? name,
    String? description,
    String? avatarUrl,
    String? createdBy,
    List<String>? adminIds,
    bool? hidePhoneNumbers,
    String? lastMessage,
    String? lastMessageSenderId,
    MessageType? lastMessageType,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      adminIds: adminIds ?? this.adminIds,
      hidePhoneNumbers: hidePhoneNumbers ?? this.hidePhoneNumbers,
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
