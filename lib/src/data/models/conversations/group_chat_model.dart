import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/group_chat_entity.dart';

class GroupChatModel extends GroupEntity {
  const GroupChatModel({
    required super.id,
    required super.participantIds,
    required super.type,
    required super.name,
    super.description,
    super.avatarUrl,
    required super.createdBy,
    required super.adminIds,
    super.hidePhoneNumbers,
    super.lastMessage,
    super.lastMessageSenderId,
    super.lastMessageTime,
    super.unreadCount,
    required super.createdAt,
    super.updatedAt,
  });

  factory GroupChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GroupChatModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      type:
          data['type'] == 'group'
              ? ConversationType.group
              : ConversationType.direct,
      name: data['name'] ?? '',
      description: data['description'],
      avatarUrl: data['avatarUrl'],
      createdBy: data['createdBy'] ?? '',
      adminIds: List<String>.from(data['adminIds'] ?? []),
      hidePhoneNumbers: data['hidePhoneNumbers'] ?? false,
      lastMessage: data['lastMessage'],
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'type': type == ConversationType.group ? 'group' : 'direct',
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'createdBy': createdBy,
      'adminIds': adminIds,
      'hidePhoneNumbers': hidePhoneNumbers,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory GroupChatModel.fromEntity(GroupEntity entity) {
    return GroupChatModel(
      id: entity.id,
      participantIds: entity.participantIds,
      type: entity.type,
      name: entity.name,
      description: entity.description,
      avatarUrl: entity.avatarUrl,
      createdBy: entity.createdBy,
      adminIds: entity.adminIds,
      hidePhoneNumbers: entity.hidePhoneNumbers,
      lastMessage: entity.lastMessage,
      lastMessageSenderId: entity.lastMessageSenderId,
      lastMessageTime: entity.lastMessageTime,
      unreadCount: entity.unreadCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      participantIds: participantIds,
      type: type,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      createdBy: createdBy,
      adminIds: adminIds,
      hidePhoneNumbers: hidePhoneNumbers,
      lastMessage: lastMessage,
      lastMessageSenderId: lastMessageSenderId,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  GroupChatModel copyWith({
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
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupChatModel(
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
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
