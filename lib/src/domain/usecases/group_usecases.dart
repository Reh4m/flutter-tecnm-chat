import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/group_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/group_chat_repository.dart';

class CreateGroupUseCase {
  final GroupChatRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call(GroupEntity group) async {
    return await repository.createGroup(group);
  }
}

class GetGroupByIdUseCase {
  final GroupChatRepository repository;

  GetGroupByIdUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call(String groupId) async {
    return await repository.getGroupById(groupId);
  }
}

class GetUserGroupsStreamUseCase {
  final GroupChatRepository repository;

  GetUserGroupsStreamUseCase(this.repository);

  Stream<Either<Failure, List<GroupEntity>>> call(String userId) {
    return repository.getUserGroupsStream(userId);
  }
}

class GetUserGroupsUseCase {
  final GroupChatRepository repository;

  GetUserGroupsUseCase(this.repository);

  Future<Either<Failure, List<GroupEntity>>> call(String userId) async {
    return await repository.getUserGroups(userId);
  }
}

class UpdateGroupUseCase {
  final GroupChatRepository repository;

  UpdateGroupUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call(GroupEntity group) async {
    return await repository.updateGroup(group);
  }
}

class DeleteGroupUseCase {
  final GroupChatRepository repository;

  DeleteGroupUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String groupId) async {
    return await repository.deleteGroup(groupId);
  }
}

class AddGroupMemberUseCase {
  final GroupChatRepository repository;

  AddGroupMemberUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    return await repository.addMember(
      groupId: groupId,
      userId: userId,
      requestingUserId: requestingUserId,
    );
  }
}

class RemoveGroupMemberUseCase {
  final GroupChatRepository repository;

  RemoveGroupMemberUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    return await repository.removeMember(
      groupId: groupId,
      userId: userId,
      requestingUserId: requestingUserId,
    );
  }
}

class AddGroupAdminUseCase {
  final GroupChatRepository repository;

  AddGroupAdminUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    return await repository.addAdmin(
      groupId: groupId,
      userId: userId,
      requestingUserId: requestingUserId,
    );
  }
}

class RemoveGroupAdminUseCase {
  final GroupChatRepository repository;

  RemoveGroupAdminUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    return await repository.removeAdmin(
      groupId: groupId,
      userId: userId,
      requestingUserId: requestingUserId,
    );
  }
}

class UpdateGroupPrivacyUseCase {
  final GroupChatRepository repository;

  UpdateGroupPrivacyUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call({
    required String groupId,
    required bool hidePhoneNumbers,
    required String requestingUserId,
  }) async {
    return await repository.updateGroupPrivacy(
      groupId: groupId,
      hidePhoneNumbers: hidePhoneNumbers,
      requestingUserId: requestingUserId,
    );
  }
}

class UpdateGroupInfoUseCase {
  final GroupChatRepository repository;

  UpdateGroupInfoUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
    required String requestingUserId,
  }) async {
    return await repository.updateGroupInfo(
      groupId: groupId,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      requestingUserId: requestingUserId,
    );
  }
}
