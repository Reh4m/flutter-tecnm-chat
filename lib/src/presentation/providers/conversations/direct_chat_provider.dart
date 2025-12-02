import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/direct_chat_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/message_use_cases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user/user_usecases.dart';

enum DirectChatState { initial, loading, success, error }

class DirectChatProvider extends ChangeNotifier {
  final GetUserDirectChatsStreamUseCase _getChatsStreamUseCase =
      sl<GetUserDirectChatsStreamUseCase>();
  final GetOrCreateDirectChatUseCase _getOrCreateChatUseCase =
      sl<GetOrCreateDirectChatUseCase>();
  final MarkDirectChatAsReadUseCase _markChatAsReadUseCase =
      sl<MarkDirectChatAsReadUseCase>();
  final DeleteDirectChatUseCase _deleteChatUseCase =
      sl<DeleteDirectChatUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();
  final SendMessageUseCase _sendMessageUseCase = sl<SendMessageUseCase>();
  final UpdateMessageStatusUseCase _updateMessageStatusUseCase =
      sl<UpdateMessageStatusUseCase>();
  final UpdateDirectChatLastMessageUseCase _updateChatLastMessageUseCase =
      sl<UpdateDirectChatLastMessageUseCase>();

  DirectChatState _directChatState = DirectChatState.initial;
  List<DirectChatEntity> _chats = [];
  final Map<String, UserEntity> _chatParticipants = {};
  String? _chatsError;
  StreamSubscription? _chatsSubscription;

  DirectChatState _operationState = DirectChatState.initial;
  String? _operationError;

  DirectChatState get directChatState => _directChatState;
  List<DirectChatEntity> get chats => _chats;
  Map<String, UserEntity> get chatParticipants => _chatParticipants;
  String? get chatsError => _chatsError;

  DirectChatState get operationState => _operationState;
  String? get operationError => _operationError;

  int getTotalUnreadCount(String userId) {
    return _chats.fold<int>(
      0,
      (sum, conv) => sum + conv.getUnreadCount(userId),
    );
  }

  void startChatsListener(String userId) {
    _setChatState(DirectChatState.loading);

    _chatsSubscription = _getChatsStreamUseCase(userId).listen(
      (either) {
        either.fold(
          (failure) => _setChatsError(_mapFailureToMessage(failure)),
          (chats) async {
            // Actualizar lista de conversaciones
            _chats = chats;

            // Cargar participantes de las conversaciones
            await _loadChatParticipants(chats);

            _setChatState(DirectChatState.success);
          },
        );
      },
      onError: (error) {
        _setChatsError('Error de conexión: $error');
      },
    );
  }

  Future<void> _loadChatParticipants(List<DirectChatEntity> chats) async {
    for (final chat in chats) {
      for (final userId in chat.participantIds) {
        if (!_chatParticipants.containsKey(userId)) {
          final result = await _getUserByIdUseCase(userId);
          result.fold((_) => null, (user) => _chatParticipants[userId] = user);
        }
      }
    }
  }

  void stopChatsListener() {
    _chatsSubscription?.cancel();
    _chatsSubscription = null;
  }

  Future<DirectChatEntity?> getOrCreateDirectConversation({
    required String userId1,
    required String userId2,
  }) async {
    _setOperationState(DirectChatState.loading);

    final result = await _getOrCreateChatUseCase(
      userId1: userId1,
      userId2: userId2,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return null;
      },
      (conversation) {
        _setOperationState(DirectChatState.success);

        return conversation;
      },
    );
  }

  Future<bool> markChatAsRead({
    required String chatId,
    required String userId,
  }) async {
    final result = await _markChatAsReadUseCase(chatId: chatId, userId: userId);

    return result.fold((failure) {
      _setOperationError(_mapFailureToMessage(failure));
      return false;
    }, (_) => true);
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

  Future<bool> deleteChat(String chatId) async {
    _setOperationState(DirectChatState.loading);

    final result = await _deleteChatUseCase(chatId);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setOperationState(DirectChatState.success);
        return true;
      },
    );
  }

  UserEntity? getParticipantInfo(String userId) {
    return _chatParticipants[userId];
  }

  String? getParticipantId(DirectChatEntity chat, String currentUserId) {
    return chat.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  void _setChatState(DirectChatState newState) {
    _directChatState = newState;
    if (newState != DirectChatState.error) {
      _chatsError = null;
    }
    notifyListeners();
  }

  void _setChatsError(String message) {
    _chatsError = message;
    _setChatState(DirectChatState.error);
  }

  void _setOperationState(DirectChatState newState) {
    _operationState = newState;
    if (newState != DirectChatState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(DirectChatState.error);
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

  @override
  void dispose() {
    stopChatsListener();
    super.dispose();
  }
}
