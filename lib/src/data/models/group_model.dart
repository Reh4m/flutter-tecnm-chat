import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    super.description,
    super.avatarUrl,
    required super.createdBy,
    required super.memberIds,
    required super.adminIds,
    super.hidePhoneNumbers,
    super.lastMessage,
    super.lastMessageSenderId,
    super.lastMessageTime,
    super.unreadCount,
    required super.createdAt,
    super.updatedAt,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      avatarUrl: data['avatarUrl'],
      createdBy: data['createdBy'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
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
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'createdBy': createdBy,
      'memberIds': memberIds,
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

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      avatarUrl: entity.avatarUrl,
      createdBy: entity.createdBy,
      memberIds: entity.memberIds,
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
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      createdBy: createdBy,
      memberIds: memberIds,
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
  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? createdBy,
    List<String>? memberIds,
    List<String>? adminIds,
    bool? hidePhoneNumbers,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      memberIds: memberIds ?? this.memberIds,
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
