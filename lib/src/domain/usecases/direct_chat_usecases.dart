import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/direct_chat_repository.dart';

class CreateConversationUseCase {
  final DirectChatRepository repository;

  CreateConversationUseCase(this.repository);

  Future<Either<Failure, DirectChatEntity>> call(
    DirectChatEntity conversation,
  ) async {
    return await repository.createConversation(conversation);
  }
}

class GetOrCreateDirectConversationUseCase {
  final DirectChatRepository repository;

  GetOrCreateDirectConversationUseCase(this.repository);

  Future<Either<Failure, DirectChatEntity>> call({
    required String userId1,
    required String userId2,
  }) async {
    return await repository.getOrCreateDirectConversation(
      userId1: userId1,
      userId2: userId2,
    );
  }
}

class GetUserConversationsStreamUseCase {
  final DirectChatRepository repository;

  GetUserConversationsStreamUseCase(this.repository);

  Stream<Either<Failure, List<DirectChatEntity>>> call(String userId) {
    return repository.getUserConversationsStream(userId);
  }
}

class GetConversationByIdUseCase {
  final DirectChatRepository repository;

  GetConversationByIdUseCase(this.repository);

  Future<Either<Failure, DirectChatEntity>> call(String conversationId) async {
    return await repository.getConversationById(conversationId);
  }
}

class UpdateConversationUseCase {
  final DirectChatRepository repository;

  UpdateConversationUseCase(this.repository);

  Future<Either<Failure, DirectChatEntity>> call(
    DirectChatEntity conversation,
  ) async {
    return await repository.updateConversation(conversation);
  }
}

class DeleteConversationUseCase {
  final DirectChatRepository repository;

  DeleteConversationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String conversationId) async {
    return await repository.deleteConversation(conversationId);
  }
}

class SendMessageUseCase {
  final DirectChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(MessageEntity message) async {
    return await repository.sendMessage(message);
  }
}

class GetConversationMessagesStreamUseCase {
  final DirectChatRepository repository;

  GetConversationMessagesStreamUseCase(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call({
    required String conversationId,
    int limit = 50,
  }) {
    return repository.getConversationMessagesStream(
      conversationId: conversationId,
      limit: limit,
    );
  }
}

class GetConversationMessagesUseCase {
  final DirectChatRepository repository;

  GetConversationMessagesUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call({
    required String conversationId,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    return await repository.getConversationMessages(
      conversationId: conversationId,
      limit: limit,
      startAfter: startAfter,
    );
  }
}

class MarkMessageAsReadUseCase {
  final DirectChatRepository repository;

  MarkMessageAsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String messageId,
    required String userId,
  }) async {
    return await repository.markMessageAsRead(
      messageId: messageId,
      userId: userId,
    );
  }
}

class MarkConversationAsReadUseCase {
  final DirectChatRepository repository;

  MarkConversationAsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String conversationId,
    required String userId,
  }) async {
    return await repository.markConversationAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }
}

class DeleteMessageUseCase {
  final DirectChatRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String messageId) async {
    return await repository.deleteMessage(messageId);
  }
}

class GetMessageByIdUseCase {
  final DirectChatRepository repository;

  GetMessageByIdUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(String messageId) async {
    return await repository.getMessageById(messageId);
  }
}

class UpdateMessageStatusUseCase {
  final DirectChatRepository repository;

  UpdateMessageStatusUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String messageId,
    required MessageStatus status,
  }) async {
    return await repository.updateMessageStatus(
      messageId: messageId,
      status: status,
    );
  }
}

class MarkAllMessagesAsDeliveredUseCase {
  final DirectChatRepository repository;

  MarkAllMessagesAsDeliveredUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String conversationId,
    required String userId,
  }) async {
    return await repository.markAllMessagesAsDelivered(
      conversationId: conversationId,
      userId: userId,
    );
  }
}
