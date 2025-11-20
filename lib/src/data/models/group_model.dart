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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
