import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/message_repository.dart';

class SendMessageUseCase {
  final MessageRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(MessageEntity message) async {
    return await repository.sendMessage(message);
  }
}

class UpdateMessageStatusUseCase {
  final MessageRepository repository;

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

class MarkMessageAsReadUseCase {
  final MessageRepository repository;

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

class MarkAllMessagesAsDeliveredUseCase {
  final MessageRepository repository;

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

class DeleteMessageUseCase {
  final MessageRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String messageId) async {
    return await repository.deleteMessage(messageId);
  }
}

class GetMessageByIdUseCase {
  final MessageRepository repository;

  GetMessageByIdUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(String messageId) async {
    return await repository.getMessageById(messageId);
  }
}

class GetConversationMessagesUseCase {
  final MessageRepository repository;

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

class GetConversationMessagesStreamUseCase {
  final MessageRepository repository;

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
