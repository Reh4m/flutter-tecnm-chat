import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/group_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/group_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/message_use_cases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user/user_usecases.dart';

enum GroupChatState { initial, loading, success, error }

class GroupChatProvider extends ChangeNotifier {
  final CreateGroupUseCase _createGroupUseCase = sl<CreateGroupUseCase>();
  final GetUserGroupsStreamUseCase _getUserGroupsStreamUseCase =
      sl<GetUserGroupsStreamUseCase>();
  final GetGroupByIdUseCase _getGroupByIdUseCase = sl<GetGroupByIdUseCase>();
  final AddGroupMemberUseCase _addGroupMemberUseCase =
      sl<AddGroupMemberUseCase>();
  final RemoveGroupMemberUseCase _removeGroupMemberUseCase =
      sl<RemoveGroupMemberUseCase>();
  final UpdateGroupPrivacyUseCase _updateGroupPrivacyUseCase =
      sl<UpdateGroupPrivacyUseCase>();
  final UpdateGroupInfoUseCase _updateGroupInfoUseCase =
      sl<UpdateGroupInfoUseCase>();
  final SendMessageUseCase _sendMessageUseCase = sl<SendMessageUseCase>();
  final UpdateMessageStatusUseCase _updateMessageStatusUseCase =
      sl<UpdateMessageStatusUseCase>();
  final UpdateGroupChatLastMessageUseCase _updateChatLastMessageUseCase =
      sl<UpdateGroupChatLastMessageUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();
  final UploadGroupProfileImageUseCase _uploadProfileImageUseCase =
      sl<UploadGroupProfileImageUseCase>();
  final UpdateGroupProfileImageUseCase _updateProfileImageUseCase =
      sl<UpdateGroupProfileImageUseCase>();

  GroupChatState _groupsState = GroupChatState.initial;
  List<GroupEntity> _groups = [];
  final Map<String, Map<String, UserEntity>> _groupParticipants = {};
  String? _groupsError;
  StreamSubscription? _groupsSubscription;

  GroupChatState _operationState = GroupChatState.initial;
  String? _operationError;

  GroupChatState _groupDetailState = GroupChatState.initial;
  GroupEntity? _currentGroup;
  String? _groupDetailError;

  GroupChatState get groupsState => _groupsState;
  List<GroupEntity> get groups => _groups;
  Map<String, Map<String, UserEntity>> get groupParticipants =>
      _groupParticipants;
  String? get groupsError => _groupsError;

  GroupChatState get operationState => _operationState;
  String? get operationError => _operationError;

  GroupChatState get groupDetailState => _groupDetailState;
  GroupEntity? get currentGroup => _currentGroup;
  String? get groupDetailError => _groupDetailError;

  void startGroupsListener(String userId) {
    _setGroupsState(GroupChatState.loading);

    _groupsSubscription = _getUserGroupsStreamUseCase(userId).listen(
      (either) {
        either.fold(
          (failure) => _setGroupsError(_mapFailureToMessage(failure)),
          (groups) async {
            _groups = groups;

            await _loadGroupParticipants(groups);

            _setGroupsState(GroupChatState.success);
          },
        );
      },
      onError: (error) {
        _setGroupsError('Error de conexión: $error');
      },
    );
  }

  Future<void> _loadGroupParticipants(List<GroupEntity> groups) async {
    for (final group in groups) {
      final Map<String, UserEntity> participants = {};

      for (final userId in group.participantIds) {
        if (!_groupParticipants.containsKey(group.id) ||
            !_groupParticipants[group.id]!.containsKey(userId)) {
          final result = await _getUserByIdUseCase(userId);

          result.fold((_) => null, (user) {
            participants[userId] = user;
          });
        } else {
          participants[userId] = _groupParticipants[group.id]![userId]!;
        }
      }

      _groupParticipants[group.id] = participants;
    }
  }

  void stopGroupsListener() {
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
  }

  Future<GroupEntity?> createGroup({
    required GroupEntity group,
    File? profileImageFile,
  }) async {
    _setOperationState(GroupChatState.loading);

    final result = await _createGroupUseCase(group);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return null;
      },
      (createdGroup) async {
        String? imageUrl;

        if (profileImageFile != null) {
          final uploadResult = await _uploadProfileImageUseCase(
            groupId: createdGroup.id,
            image: profileImageFile,
          );

          final uploadSuccess = await uploadResult.fold(
            (failure) {
              _setOperationError(_mapFailureToMessage(failure));
              return false;
            },
            (url) {
              imageUrl = url;
              return true;
            },
          );

          if (uploadSuccess && imageUrl != null) {
            await _updateProfileImageUseCase(
              groupId: createdGroup.id,
              imageUrl: imageUrl!,
            );
          }
        }

        _setOperationState(GroupChatState.success);
        return createdGroup;
      },
    );
  }

  Future<void> loadGroupById(String groupId) async {
    _setGroupDetailState(GroupChatState.loading);

    final result = await _getGroupByIdUseCase(groupId);

    result.fold(
      (failure) => _setGroupDetailError(_mapFailureToMessage(failure)),
      (group) {
        _currentGroup = group;
        _setGroupDetailState(GroupChatState.success);
      },
    );
  }

  Future<bool> sendMessage(MessageEntity message) async {
    // _setOperationState(MessageState.loading);

    // Crear mensaje con estado 'sending'
    final messageToSend = message.copyWith(status: MessageStatus.sending);

    final result = await _sendMessageUseCase(messageToSend);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));

        // Marcar como fallido si hay error
        if (message.id.isNotEmpty) {
          _updateMessageStatusUseCase(
            messageId: message.id,
            status: MessageStatus.failed,
          );
        }

        return false;
      },
      (sentMessage) {
        // _setOperationState(MessageState.success);

        // Actualizar a 'sent' después de enviar exitosamente
        _updateMessageStatusUseCase(
          messageId: sentMessage.id,
          status: MessageStatus.sent,
        );

        _updateChatLastMessageUseCase(message: sentMessage);

        return true;
      },
    );
  }

  Future<bool> retryFailedMessage(MessageEntity message) async {
    // Actualizar estado a 'sending'
    await _updateMessageStatusUseCase(
      messageId: message.id,
      status: MessageStatus.sending,
    );

    // Intentar reenviar
    return await sendMessage(message);
  }

  Future<bool> updateGroupInfoWithImage({
    required String groupId,
    String? name,
    String? description,
    required String requestingUserId,
    File? profileImageFile,
  }) async {
    _setOperationState(GroupChatState.loading);

    String? imageUrl;

    if (profileImageFile != null) {
      final uploadResult = await _uploadProfileImageUseCase(
        groupId: groupId,
        image: profileImageFile,
      );

      final imageUploadSuccess = await uploadResult.fold(
        (failure) {
          _setOperationError(_mapFailureToMessage(failure));
          return false;
        },
        (url) {
          imageUrl = url;
          return true;
        },
      );

      if (!imageUploadSuccess) return false;
    }

    final result = await _updateGroupInfoUseCase(
      groupId: groupId,
      name: name,
      description: description,
      avatarUrl: imageUrl,
      requestingUserId: requestingUserId,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (updatedGroup) {
        _currentGroup = updatedGroup;
        _setOperationState(GroupChatState.success);
        return true;
      },
    );
  }

  Future<bool> addMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    _setOperationState(GroupChatState.loading);

    final result = await _addGroupMemberUseCase(
      groupId: groupId,
      userId: userId,
      requestingUserId: requestingUserId,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (updatedGroup) {
        _currentGroup = updatedGroup;
        _setOperationState(GroupChatState.success);
        return true;
      },
    );
  }

  Future<bool> removeMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    _setOperationState(GroupChatState.loading);

    final result = await _removeGroupMemberUseCase(
      groupId: groupId,
      userId: userId,
      requestingUserId: requestingUserId,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (updatedGroup) {
        _currentGroup = updatedGroup;
        _setOperationState(GroupChatState.success);
        return true;
      },
    );
  }

  Future<bool> updatePrivacy({
    required String groupId,
    required bool hidePhoneNumbers,
    required String requestingUserId,
  }) async {
    _setOperationState(GroupChatState.loading);

    final result = await _updateGroupPrivacyUseCase(
      groupId: groupId,
      hidePhoneNumbers: hidePhoneNumbers,
      requestingUserId: requestingUserId,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (updatedGroup) {
        _currentGroup = updatedGroup;
        _setOperationState(GroupChatState.success);
        return true;
      },
    );
  }

  void clearCurrentGroup() {
    _currentGroup = null;
    _groupDetailState = GroupChatState.initial;
    _groupDetailError = null;
  }

  void _setGroupsState(GroupChatState newState) {
    _groupsState = newState;
    if (newState != GroupChatState.error) {
      _groupsError = null;
    }
    notifyListeners();
  }

  void _setGroupsError(String message) {
    _groupsError = message;
    _setGroupsState(GroupChatState.error);
  }

  void _setOperationState(GroupChatState newState) {
    _operationState = newState;
    if (newState != GroupChatState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(GroupChatState.error);
  }

  void _setGroupDetailState(GroupChatState newState) {
    _groupDetailState = newState;
    if (newState != GroupChatState.error) {
      _groupDetailError = null;
    }
    notifyListeners();
  }

  void _setGroupDetailError(String message) {
    _groupDetailError = message;
    _setGroupDetailState(GroupChatState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (GroupNotFoundFailure):
        return 'Grupo no encontrado';
      case const (NotGroupAdminFailure):
        return 'No eres administrador del grupo';
      case const (MaxGroupMembersExceededFailure):
        return 'Se alcanzó el límite de miembros';
      case const (CannotRemoveGroupCreatorFailure):
        return 'No se puede eliminar al creador del grupo';
      default:
        return ErrorMessages.serverError;
    }
  }

  void clearOperationError() {
    _operationError = null;
    notifyListeners();
  }

  void clearGroupsError() {
    _groupsError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopGroupsListener();
    super.dispose();
  }
}
