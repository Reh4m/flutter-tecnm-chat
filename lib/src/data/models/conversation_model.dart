import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participantIds,
    required super.type,
    super.lastMessage,
    super.lastMessageSenderId,
    super.lastMessageTime,
    super.unreadCount,
    required super.createdAt,
    super.updatedAt,
    super.groupName,
    super.groupAvatarUrl,
    super.hidePhoneNumbers,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ConversationModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      type:
          data['type'] == 'group'
              ? ConversationType.group
              : ConversationType.direct,
      lastMessage: data['lastMessage'],
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      groupName: data['groupName'],
      groupAvatarUrl: data['groupAvatarUrl'],
      hidePhoneNumbers: data['hidePhoneNumbers'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'type': type == ConversationType.group ? 'group' : 'direct',
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'groupName': groupName,
      'groupAvatarUrl': groupAvatarUrl,
      'hidePhoneNumbers': hidePhoneNumbers,
    };
  }

  factory ConversationModel.fromEntity(ConversationEntity entity) {
    return ConversationModel(
      id: entity.id,
      participantIds: entity.participantIds,
      type: entity.type,
      lastMessage: entity.lastMessage,
      lastMessageSenderId: entity.lastMessageSenderId,
      lastMessageTime: entity.lastMessageTime,
      unreadCount: entity.unreadCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      groupName: entity.groupName,
      groupAvatarUrl: entity.groupAvatarUrl,
      hidePhoneNumbers: entity.hidePhoneNumbers,
    );
  }

  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      participantIds: participantIds,
      type: type,
      lastMessage: lastMessage,
      lastMessageSenderId: lastMessageSenderId,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      groupName: groupName,
      groupAvatarUrl: groupAvatarUrl,
      hidePhoneNumbers: hidePhoneNumbers,
    );
  }

  @override
  ConversationModel copyWith({
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
    return ConversationModel(
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
