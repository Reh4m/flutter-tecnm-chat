import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversation_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversation_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user_usecases.dart';

enum ConversationsState { initial, loading, success, error }

class ConversationsProvider extends ChangeNotifier {
  final GetUserConversationsStreamUseCase _getConversationsStreamUseCase =
      sl<GetUserConversationsStreamUseCase>();
  final GetOrCreateDirectConversationUseCase
  _getOrCreateDirectConversationUseCase =
      sl<GetOrCreateDirectConversationUseCase>();
  final MarkConversationAsReadUseCase _markConversationAsReadUseCase =
      sl<MarkConversationAsReadUseCase>();
  final DeleteConversationUseCase _deleteConversationUseCase =
      sl<DeleteConversationUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();

  ConversationsState _conversationsState = ConversationsState.initial;
  List<ConversationEntity> _conversations = [];
  final Map<String, UserEntity> _conversationUsers = {};
  String? _conversationsError;
  StreamSubscription? _conversationsSubscription;

  ConversationsState _operationState = ConversationsState.initial;
  String? _operationError;

  ConversationsState get conversationsState => _conversationsState;
  List<ConversationEntity> get conversations => _conversations;
  Map<String, UserEntity> get conversationUsers => _conversationUsers;
  String? get conversationsError => _conversationsError;

  ConversationsState get operationState => _operationState;
  String? get operationError => _operationError;

  int getTotalUnreadCount(String userId) {
    return _conversations.fold<int>(
      0,
      (sum, conv) => sum + conv.getUnreadCount(userId),
    );
  }

  void startConversationsListener(String userId) {
    _setConversationsState(ConversationsState.loading);

    _conversationsSubscription = _getConversationsStreamUseCase(userId).listen(
      (either) {
        either.fold(
          (failure) => _setConversationsError(_mapFailureToMessage(failure)),
          (conversations) async {
            _conversations = conversations;
            await _loadConversationUsers(conversations);
            _setConversationsState(ConversationsState.success);
          },
        );
      },
      onError: (error) {
        _setConversationsError('Error de conexión: $error');
      },
    );
  }

  Future<void> _loadConversationUsers(
    List<ConversationEntity> conversations,
  ) async {
    for (final conversation in conversations) {
      if (conversation.isDirect) {
        for (final userId in conversation.participantIds) {
          if (!_conversationUsers.containsKey(userId)) {
            final result = await _getUserByIdUseCase(userId);
            result.fold(
              (_) => null,
              (user) => _conversationUsers[userId] = user,
            );
          }
        }
      }
    }
  }

  void stopConversationsListener() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = null;
  }

  Future<ConversationEntity?> getOrCreateDirectConversation({
    required String userId1,
    required String userId2,
  }) async {
    _setOperationState(ConversationsState.loading);

    final result = await _getOrCreateDirectConversationUseCase(
      userId1: userId1,
      userId2: userId2,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return null;
      },
      (conversation) {
        _setOperationState(ConversationsState.success);
        return conversation;
      },
    );
  }

  Future<bool> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    final result = await _markConversationAsReadUseCase(
      conversationId: conversationId,
      userId: userId,
    );

    return result.fold((failure) {
      _setOperationError(_mapFailureToMessage(failure));
      return false;
    }, (_) => true);
  }

  Future<bool> deleteConversation(String conversationId) async {
    _setOperationState(ConversationsState.loading);

    final result = await _deleteConversationUseCase(conversationId);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setOperationState(ConversationsState.success);
        return true;
      },
    );
  }

  UserEntity? getConversationUser(String userId) {
    return _conversationUsers[userId];
  }

  String? getOtherUserId(
    ConversationEntity conversation,
    String currentUserId,
  ) {
    if (!conversation.isDirect) return null;

    return conversation.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  void _setConversationsState(ConversationsState newState) {
    _conversationsState = newState;
    if (newState != ConversationsState.error) {
      _conversationsError = null;
    }
    notifyListeners();
  }

  void _setConversationsError(String message) {
    _conversationsError = message;
    _setConversationsState(ConversationsState.error);
  }

  void _setOperationState(ConversationsState newState) {
    _operationState = newState;
    if (newState != ConversationsState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(ConversationsState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (ConversationNotFoundFailure):
        return 'Conversación no encontrada';
      case const (ConversationOperationFailedFailure):
        return ErrorMessages.contactOperationFailed;
      default:
        return ErrorMessages.serverError;
    }
  }

  void clearOperationError() {
    _operationError = null;
    notifyListeners();
  }

  void clearConversationsError() {
    _conversationsError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopConversationsListener();
    super.dispose();
  }
}
