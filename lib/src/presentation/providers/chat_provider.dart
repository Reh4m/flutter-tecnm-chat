import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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
  final MarkConversationAsReadUseCase _markConversationAsReadUseCase =
      sl<MarkConversationAsReadUseCase>();
  final DeleteMessageUseCase _deleteMessageUseCase = sl<DeleteMessageUseCase>();
  final UpdateMessageStatusUseCase _updateMessageStatusUseCase =
      sl<UpdateMessageStatusUseCase>();
  final MarkAllMessagesAsDeliveredUseCase _markAllMessagesAsDeliveredUseCase =
      sl<MarkAllMessagesAsDeliveredUseCase>();

  ChatState _messagesState = ChatState.initial;
  List<MessageEntity> _messages = [];
  String? _messagesError;
  StreamSubscription? _messagesSubscription;

  ChatState _operationState = ChatState.initial;
  String? _operationError;

  String? _currentConversationId;
  Timer? _statusCheckTimer;

  ChatState get messagesState => _messagesState;
  List<MessageEntity> get messages => _messages;
  String? get messagesError => _messagesError;

  ChatState get operationState => _operationState;
  String? get operationError => _operationError;

  String? get currentConversationId => _currentConversationId;

  void startMessagesListener(String conversationId, {int limit = 50}) {
    _currentConversationId = conversationId;
    _setMessagesState(ChatState.loading);

    _statusCheckTimer?.cancel();

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

            _markMessagesAsDeliveredOnLoad(conversationId);

            _startStatusCheckTimer(conversationId);
          },
        );
      },
      onError: (error) {
        _setMessagesError('Error de conexión: $error');
      },
    );
  }

  void _startStatusCheckTimer(String conversationId) {
    _statusCheckTimer?.cancel();

    _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkAndUpdateMessageStatuses(conversationId);
    });
  }

  Future<void> _checkAndUpdateMessageStatuses(String conversationId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return;

    // Actualizar mensajes en estado 'sending' a 'sent'
    for (final message in _messages) {
      if (message.senderId == currentUserId) {
        if (message.status == MessageStatus.sending) {
          await _updateMessageStatusUseCase(
            messageId: message.id,
            status: MessageStatus.sent,
          );
        }
      }
    }
  }

  Future<void> _markMessagesAsDeliveredOnLoad(String conversationId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return;

    await _markAllMessagesAsDeliveredUseCase(
      conversationId: conversationId,
      userId: currentUserId,
    );
  }

  void stopMessagesListener() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
    _currentConversationId = null;
  }

  Future<bool> sendMessage(MessageEntity message) async {
    _setOperationState(ChatState.loading);

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
        _setOperationState(ChatState.success);

        // Actualizar a 'sent' después de enviar exitosamente
        _updateMessageStatusUseCase(
          messageId: sentMessage.id,
          status: MessageStatus.sent,
        );

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

  Future<void> markMessagesAsReadInConversation(String conversationId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    await _markConversationAsReadUseCase(
      conversationId: conversationId,
      userId: currentUserId,
    );

    for (final message in _messages) {
      if (message.senderId != currentUserId &&
          message.status != MessageStatus.read) {
        await _markMessageAsReadUseCase(
          messageId: message.id,
          userId: currentUserId,
        );
      }
    }
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
    _statusCheckTimer?.cancel();
    super.dispose();
  }
}
