import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/group_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/group_usecases.dart';

enum GroupState { initial, loading, success, error }

class GroupProvider extends ChangeNotifier {
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

  GroupState _groupsState = GroupState.initial;
  List<GroupEntity> _groups = [];
  String? _groupsError;
  StreamSubscription? _groupsSubscription;

  GroupState _operationState = GroupState.initial;
  String? _operationError;

  GroupState _groupDetailState = GroupState.initial;
  GroupEntity? _currentGroup;
  String? _groupDetailError;

  GroupState get groupsState => _groupsState;
  List<GroupEntity> get groups => _groups;
  String? get groupsError => _groupsError;

  GroupState get operationState => _operationState;
  String? get operationError => _operationError;

  GroupState get groupDetailState => _groupDetailState;
  GroupEntity? get currentGroup => _currentGroup;
  String? get groupDetailError => _groupDetailError;

  void startGroupsListener(String userId) {
    _setGroupsState(GroupState.loading);

    _groupsSubscription = _getUserGroupsStreamUseCase(userId).listen(
      (either) {
        either.fold(
          (failure) => _setGroupsError(_mapFailureToMessage(failure)),
          (groups) {
            _groups = groups;
            _setGroupsState(GroupState.success);
          },
        );
      },
      onError: (error) {
        _setGroupsError('Error de conexión: $error');
      },
    );
  }

  void stopGroupsListener() {
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
  }

  Future<GroupEntity?> createGroup(GroupEntity group) async {
    _setOperationState(GroupState.loading);

    final result = await _createGroupUseCase(group);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return null;
      },
      (createdGroup) {
        _setOperationState(GroupState.success);
        return createdGroup;
      },
    );
  }

  Future<void> loadGroupById(String groupId) async {
    _setGroupDetailState(GroupState.loading);

    final result = await _getGroupByIdUseCase(groupId);

    result.fold(
      (failure) => _setGroupDetailError(_mapFailureToMessage(failure)),
      (group) {
        _currentGroup = group;
        _setGroupDetailState(GroupState.success);
      },
    );
  }

  Future<bool> updateGroupInfo({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
    required String requestingUserId,
  }) async {
    _setOperationState(GroupState.loading);

    final result = await _updateGroupInfoUseCase(
      groupId: groupId,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      requestingUserId: requestingUserId,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (updatedGroup) {
        _currentGroup = updatedGroup;
        _setOperationState(GroupState.success);
        return true;
      },
    );
  }

  Future<bool> addMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    _setOperationState(GroupState.loading);

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
        _setOperationState(GroupState.success);
        return true;
      },
    );
  }

  Future<bool> removeMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    _setOperationState(GroupState.loading);

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
        _setOperationState(GroupState.success);
        return true;
      },
    );
  }

  Future<bool> updatePrivacy({
    required String groupId,
    required bool hidePhoneNumbers,
    required String requestingUserId,
  }) async {
    _setOperationState(GroupState.loading);

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
        _setOperationState(GroupState.success);
        return true;
      },
    );
  }

  void clearCurrentGroup() {
    _currentGroup = null;
    _groupDetailState = GroupState.initial;
    _groupDetailError = null;
    notifyListeners();
  }

  void _setGroupsState(GroupState newState) {
    _groupsState = newState;
    if (newState != GroupState.error) {
      _groupsError = null;
    }
    notifyListeners();
  }

  void _setGroupsError(String message) {
    _groupsError = message;
    _setGroupsState(GroupState.error);
  }

  void _setOperationState(GroupState newState) {
    _operationState = newState;
    if (newState != GroupState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(GroupState.error);
  }

  void _setGroupDetailState(GroupState newState) {
    _groupDetailState = newState;
    if (newState != GroupState.error) {
      _groupDetailError = null;
    }
    notifyListeners();
  }

  void _setGroupDetailError(String message) {
    _groupDetailError = message;
    _setGroupDetailState(GroupState.error);
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
