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
  final MarkMessageAsReadUseCase _markMessageAsReadUseCase =
      sl<MarkMessageAsReadUseCase>();
  final MarkConversationAsReadUseCase _markConversationAsReadUseCase =
      sl<MarkConversationAsReadUseCase>();
  final DeleteMessageUseCase _deleteMessageUseCase = sl<DeleteMessageUseCase>();
  final UpdateMessageStatusUseCase _updateMessageStatusUseCase =
      sl<UpdateMessageStatusUseCase>();
  final MarkAllMessagesAsDeliveredUseCase _markAllMessagesAsDeliveredUseCase =
      sl<MarkAllMessagesAsDeliveredUseCase>();

  MessageState _messagesState = MessageState.initial;
  List<MessageEntity> _messages = [];
  String? _messagesError;
  StreamSubscription? _messagesSubscription;

  MessageState _operationState = MessageState.initial;
  String? _operationError;

  String? _currentConversationId;
  Timer? _statusCheckTimer;

  MessageState get messagesState => _messagesState;
  List<MessageEntity> get messages => _messages;
  String? get messagesError => _messagesError;

  MessageState get operationState => _operationState;
  String? get operationError => _operationError;

  String? get currentConversationId => _currentConversationId;

  void startMessagesListener(String conversationId, {int limit = 50}) {
    _currentConversationId = conversationId;
    _setMessagesState(MessageState.loading);

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
            _setMessagesState(MessageState.success);

            _markMessagesAsDeliveredOnLoad(conversationId);

            _startStatusCheckTimer(conversationId);

            _markMessagesAsReadInConversation(conversationId);
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
    final currentUserId = firebaseAuth.currentUser?.uid;

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
    final currentUserId = firebaseAuth.currentUser?.uid;

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

  Future<void> _markMessagesAsReadInConversation(String conversationId) async {
    final currentUserId = firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return;

    await _markConversationAsReadUseCase(
      conversationId: conversationId,
      userId: currentUserId,
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
    stopMessagesListener();
    _statusCheckTimer?.cancel();
    super.dispose();
  }
}
