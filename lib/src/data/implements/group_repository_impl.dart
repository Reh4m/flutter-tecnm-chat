import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/group_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/group_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/group_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final FirebaseGroupService groupService;
  final NetworkInfo networkInfo;

  GroupRepositoryImpl({required this.groupService, required this.networkInfo});

  @override
  Future<Either<Failure, GroupEntity>> createGroup(GroupEntity group) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final groupModel = GroupModel.fromEntity(group);
      final created = await groupService.createGroup(groupModel);
      return Right(created.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> getGroupById(String groupId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final group = await groupService.getGroupById(groupId);
      return Right(group.toEntity());
    } on GroupNotFoundException {
      return Left(GroupNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<GroupEntity>>> getUserGroupsStream(
    String userId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final groups in groupService.getUserGroupsStream(userId)) {
        yield Right(groups.map((g) => g.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> getUserGroups(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final groups = await groupService.getUserGroups(userId);
      return Right(groups.map((g) => g.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> updateGroup(GroupEntity group) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final groupModel = GroupModel.fromEntity(group);
      final updated = await groupService.updateGroup(groupModel);
      return Right(updated.toEntity());
    } on GroupOperationFailedException {
      return Left(GroupOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteGroup(String groupId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await groupService.deleteGroup(groupId);
      return const Right(unit);
    } on GroupOperationFailedException {
      return Left(GroupOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> addMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final group = await groupService.addMember(
        groupId: groupId,
        userId: userId,
        requestingUserId: requestingUserId,
      );
      return Right(group.toEntity());
    } on NotGroupAdminException {
      return Left(NotGroupAdminFailure());
    } on MaxGroupMembersExceededException {
      return Left(MaxGroupMembersExceededFailure());
    } on GroupOperationFailedException {
      return Left(GroupOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> removeMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final group = await groupService.removeMember(
        groupId: groupId,
        userId: userId,
        requestingUserId: requestingUserId,
      );
      return Right(group.toEntity());
    } on NotGroupAdminException {
      return Left(NotGroupAdminFailure());
    } on CannotRemoveGroupCreatorException {
      return Left(CannotRemoveGroupCreatorFailure());
    } on GroupOperationFailedException {
      return Left(GroupOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> addAdmin({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final group = await groupService.addAdmin(
        groupId: groupId,
        userId: userId,
        requestingUserId: requestingUserId,
      );
      return Right(group.toEntity());
    } on NotGroupAdminException {
      return Left(NotGroupAdminFailure());
    } on NotGroupMemberException {
      return Left(NotGroupMemberFailure());
    } on GroupOperationFailedException {
      return Left(GroupOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> removeAdmin({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final group = await groupService.removeAdmin(
        groupId: groupId,
        userId: userId,
        requestingUserId: requestingUserId,
      );
      return Right(group.toEntity());
    } on NotGroupAdminException {
      return Left(NotGroupAdminFailure());
    } on CannotRemoveGroupCreatorException {
      return Left(CannotRemoveGroupCreatorFailure());
    } on GroupOperationFailedException {
      return Left(GroupOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> updateGroupPrivacy({
    required String groupId,
    required bool hidePhoneNumbers,
    required String requestingUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final group = await groupService.updateGroupPrivacy(
        groupId: groupId,
        hidePhoneNumbers: hidePhoneNumbers,
        requestingUserId: requestingUserId,
      );
      return Right(group.toEntity());
    } on NotGroupAdminException {
      return Left(NotGroupAdminFailure());
    } on GroupOperationFailedException {
      return Left(GroupOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> updateGroupInfo({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
    required String requestingUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final group = await groupService.updateGroupInfo(
        groupId: groupId,
        name: name,
        description: description,
        avatarUrl: avatarUrl,
        requestingUserId: requestingUserId,
      );
      return Right(group.toEntity());
    } on NotGroupAdminException {
      return Left(NotGroupAdminFailure());
    } on GroupOperationFailedException {
      return Left(GroupOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
