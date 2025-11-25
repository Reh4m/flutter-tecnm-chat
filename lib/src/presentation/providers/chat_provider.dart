import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversation_usecases.dart';

enum ChatState { initial, loading, success, error }

class ChatProvider extends ChangeNotifier {
  final GetConversationMessagesStreamUseCase _getMessagesStreamUseCase =
      sl<GetConversationMessagesStreamUseCase>();
  final SendMessageUseCase _sendMessageUseCase = sl<SendMessageUseCase>();
  final MarkMessageAsReadUseCase _markMessageAsReadUseCase =
      sl<MarkMessageAsReadUseCase>();
  final DeleteMessageUseCase _deleteMessageUseCase = sl<DeleteMessageUseCase>();

  ChatState _messagesState = ChatState.initial;
  List<MessageEntity> _messages = [];
  String? _messagesError;
  StreamSubscription? _messagesSubscription;

  ChatState _operationState = ChatState.initial;
  String? _operationError;

  String? _currentConversationId;

  ChatState get messagesState => _messagesState;
  List<MessageEntity> get messages => _messages;
  String? get messagesError => _messagesError;

  ChatState get operationState => _operationState;
  String? get operationError => _operationError;

  String? get currentConversationId => _currentConversationId;

  void startMessagesListener(String conversationId, {int limit = 50}) {
    _currentConversationId = conversationId;
    _setMessagesState(ChatState.loading);

    _messagesSubscription = _getMessagesStreamUseCase(
      conversationId: conversationId,
      limit: limit,
    ).listen(
      (either) {
        either.fold(
          (failure) => _setMessagesError(_mapFailureToMessage(failure)),
          (messages) {
            _messages = messages;
            _setMessagesState(ChatState.success);
          },
        );
      },
      onError: (error) {
        _setMessagesError('Error de conexión: $error');
      },
    );
  }

  void stopMessagesListener() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _currentConversationId = null;
  }

  Future<bool> sendMessage(MessageEntity message) async {
    _setOperationState(ChatState.loading);

    final result = await _sendMessageUseCase(message);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (sentMessage) {
        _setOperationState(ChatState.success);
        return true;
      },
    );
  }

  Future<bool> markMessageAsRead({
    required String messageId,
    required String userId,
  }) async {
    final result = await _markMessageAsReadUseCase(
      messageId: messageId,
      userId: userId,
    );

    return result.fold((failure) => false, (_) => true);
  }

  Future<bool> deleteMessage(String messageId) async {
    _setOperationState(ChatState.loading);

    final result = await _deleteMessageUseCase(messageId);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setOperationState(ChatState.success);
        return true;
      },
    );
  }

  void _setMessagesState(ChatState newState) {
    _messagesState = newState;
    if (newState != ChatState.error) {
      _messagesError = null;
    }
    notifyListeners();
  }

  void _setMessagesError(String message) {
    _messagesError = message;
    _setMessagesState(ChatState.error);
  }

  void _setOperationState(ChatState newState) {
    _operationState = newState;
    if (newState != ChatState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(ChatState.error);
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
    stopMessagesListener();
    super.dispose();
  }
}
