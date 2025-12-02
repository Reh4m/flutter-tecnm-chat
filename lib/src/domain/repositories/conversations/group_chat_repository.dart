import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/group_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';

abstract class GroupChatRepository {
  Future<Either<Failure, GroupEntity>> createGroup(GroupEntity group);
  Future<Either<Failure, GroupEntity>> getGroupById(String groupId);
  Stream<Either<Failure, List<GroupEntity>>> getUserGroupsStream(String userId);
  Future<Either<Failure, List<GroupEntity>>> getUserGroups(String userId);
  Future<Either<Failure, GroupEntity>> updateGroup(GroupEntity group);
  Future<Either<Failure, Unit>> deleteGroup(String groupId);
  Future<Either<Failure, String>> uploadProfileImage({
    required File image,
    required String groupId,
  });
  Future<Either<Failure, GroupEntity>> updateProfileImage({
    required String groupId,
    required String imageUrl,
  });
  Future<Either<Failure, GroupEntity>> addMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  });
  Future<Either<Failure, GroupEntity>> removeMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  });
  Future<Either<Failure, GroupEntity>> addAdmin({
    required String groupId,
    required String userId,
    required String requestingUserId,
  });
  Future<Either<Failure, GroupEntity>> removeAdmin({
    required String groupId,
    required String userId,
    required String requestingUserId,
  });
  Future<Either<Failure, GroupEntity>> updateGroupPrivacy({
    required String groupId,
    required bool hidePhoneNumbers,
    required String requestingUserId,
  });
  Future<Either<Failure, GroupEntity>> updateGroupInfo({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
    required String requestingUserId,
  });
  Future<Either<Failure, Unit>> markChatAsRead({
    required String chatId,
    required String userId,
  });
  Future<Either<Failure, Unit>> updateChatLastMessage({
    required MessageEntity message,
  });
}
