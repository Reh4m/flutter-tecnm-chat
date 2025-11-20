import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/group_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/group_repository.dart';

class CreateGroupUseCase {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call(GroupEntity group) async {
    return await repository.createGroup(group);
  }
}

class GetGroupByIdUseCase {
  final GroupRepository repository;

  GetGroupByIdUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call(String groupId) async {
    return await repository.getGroupById(groupId);
  }
}

class GetUserGroupsStreamUseCase {
  final GroupRepository repository;

  GetUserGroupsStreamUseCase(this.repository);

  Stream<Either<Failure, List<GroupEntity>>> call(String userId) {
    return repository.getUserGroupsStream(userId);
  }
}

class GetUserGroupsUseCase {
  final GroupRepository repository;

  GetUserGroupsUseCase(this.repository);

  Future<Either<Failure, List<GroupEntity>>> call(String userId) async {
    return await repository.getUserGroups(userId);
  }
}

class UpdateGroupUseCase {
  final GroupRepository repository;

  UpdateGroupUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call(GroupEntity group) async {
    return await repository.updateGroup(group);
  }
}

class DeleteGroupUseCase {
  final GroupRepository repository;

  DeleteGroupUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String groupId) async {
    return await repository.deleteGroup(groupId);
  }
}

class AddGroupMemberUseCase {
  final GroupRepository repository;

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
  final GroupRepository repository;

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
  final GroupRepository repository;

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
  final GroupRepository repository;

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
  final GroupRepository repository;

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
  final GroupRepository repository;

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
