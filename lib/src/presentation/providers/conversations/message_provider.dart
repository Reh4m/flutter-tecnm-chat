import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart' as di;
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/message_use_cases.dart';

enum MessageState { initial, loading, success, error }

class MessageProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = di.sl<FirebaseAuth>();
  final GetConversationMessagesStreamUseCase _getMessagesStreamUseCase =
      sl<GetConversationMessagesStreamUseCase>();
  final MarkConversationAsReadUseCase _markConversationAsReadUseCase =
      sl<MarkConversationAsReadUseCase>();
  final MarkAllMessagesAsDeliveredUseCase _markAllMessagesAsDeliveredUseCase =
      sl<MarkAllMessagesAsDeliveredUseCase>();
  final DeleteMessageUseCase _deleteMessageUseCase = sl<DeleteMessageUseCase>();

  MessageState _messagesState = MessageState.initial;
  List<MessageEntity> _messages = [];
  String? _messagesError;
  StreamSubscription? _messagesSubscription;

  MessageState _operationState = MessageState.initial;
  String? _operationError;

  String? _currentConversationId;
  bool _isDisposed = false;

  MessageState get messagesState => _messagesState;
  List<MessageEntity> get messages => _messages;
  String? get messagesError => _messagesError;

  MessageState get operationState => _operationState;
  String? get operationError => _operationError;

  String? get currentConversationId => _currentConversationId;

  void startMessagesListener(String conversationId, {int limit = 50}) {
    if (_currentConversationId != null) {
      stopMessagesListener();
    }

    _setMessagesState(MessageState.loading);

    _currentConversationId = conversationId;

    _messagesSubscription = _getMessagesStreamUseCase(
      conversationId: conversationId,
      limit: limit,
    ).listen(
      (either) {
        if (_isDisposed) return;

        either.fold(
          (failure) => _setMessagesError(_mapFailureToMessage(failure)),
          (messages) {
            _messages = messages;

            _markMessagesAsDeliveredOnLoad(conversationId);
            _markMessagesAsReadInConversation(conversationId);

            _setMessagesState(MessageState.success);
          },
        );
      },
      onError: (error) {
        if (!_isDisposed) {
          _setMessagesError('Error de conexión: $error');
        }
      },
    );
  }

  Future<void> _markMessagesAsDeliveredOnLoad(String conversationId) async {
    if (_isDisposed) return;

    final currentUserId = firebaseAuth.currentUser?.uid;

    if (currentUserId == null) return;

    await _markAllMessagesAsDeliveredUseCase(
      conversationId: conversationId,
      userId: currentUserId,
    );
  }

  Future<void> _markMessagesAsReadInConversation(String conversationId) async {
    if (_isDisposed) return;

    final currentUserId = firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return;

    await _markConversationAsReadUseCase(
      conversationId: conversationId,
      userId: currentUserId,
    );
  }

  void stopMessagesListener() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _currentConversationId = null;
  }

  Future<bool> deleteMessage(String messageId) async {
    _setOperationState(MessageState.loading);

    final result = await _deleteMessageUseCase(messageId);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setOperationState(MessageState.success);
        return true;
      },
    );
  }

  void _setMessagesState(MessageState newState) {
    _messagesState = newState;
    if (newState != MessageState.error) {
      _messagesError = null;
    }
    notifyListeners();
  }

  void _setMessagesError(String message) {
    _messagesError = message;
    _setMessagesState(MessageState.error);
  }

  void _setOperationState(MessageState newState) {
    _operationState = newState;
    if (newState != MessageState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(MessageState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (MessageSendFailedFailure):
        return 'Error al enviar mensaje';
      case const (MessageNotFoundFailure):
        return 'Mensaje no encontrado';
      default:
        return ErrorMessages.serverError;
    }
  }

  void clearOperationError() {
    _operationError = null;
    notifyListeners();
  }

  void clearMessagesError() {
    _messagesError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopMessagesListener();
    super.dispose();
  }
}
