import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String createdBy;
  final List<String> memberIds;
  final List<String> adminIds;
  final bool hidePhoneNumbers;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.createdBy,
    required this.memberIds,
    required this.adminIds,
    this.hidePhoneNumbers = false,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    this.unreadCount = const {},
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    avatarUrl,
    createdBy,
    memberIds,
    adminIds,
    hidePhoneNumbers,
    lastMessage,
    lastMessageSenderId,
    lastMessageTime,
    unreadCount,
    createdAt,
    updatedAt,
  ];

  bool isAdmin(String userId) => adminIds.contains(userId);
  bool isMember(String userId) => memberIds.contains(userId);
  bool isCreator(String userId) => createdBy == userId;
  int get memberCount => memberIds.length;

  GroupEntity copyWith({
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
    return GroupEntity(
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
