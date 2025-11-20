import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversation_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversation_repository.dart';

class CreateConversationUseCase {
  final ConversationRepository repository;

  CreateConversationUseCase(this.repository);

  Future<Either<Failure, ConversationEntity>> call(
    ConversationEntity conversation,
  ) async {
    return await repository.createConversation(conversation);
  }
}

class GetOrCreateDirectConversationUseCase {
  final ConversationRepository repository;

  GetOrCreateDirectConversationUseCase(this.repository);

  Future<Either<Failure, ConversationEntity>> call({
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
  final ConversationRepository repository;

  GetUserConversationsStreamUseCase(this.repository);

  Stream<Either<Failure, List<ConversationEntity>>> call(String userId) {
    return repository.getUserConversationsStream(userId);
  }
}

class GetConversationByIdUseCase {
  final ConversationRepository repository;

  GetConversationByIdUseCase(this.repository);

  Future<Either<Failure, ConversationEntity>> call(
    String conversationId,
  ) async {
    return await repository.getConversationById(conversationId);
  }
}

class UpdateConversationUseCase {
  final ConversationRepository repository;

  UpdateConversationUseCase(this.repository);

  Future<Either<Failure, ConversationEntity>> call(
    ConversationEntity conversation,
  ) async {
    return await repository.updateConversation(conversation);
  }
}

class DeleteConversationUseCase {
  final ConversationRepository repository;

  DeleteConversationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String conversationId) async {
    return await repository.deleteConversation(conversationId);
  }
}

class SendMessageUseCase {
  final ConversationRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(MessageEntity message) async {
    return await repository.sendMessage(message);
  }
}

class GetConversationMessagesStreamUseCase {
  final ConversationRepository repository;

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
  final ConversationRepository repository;

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
  final ConversationRepository repository;

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
  final ConversationRepository repository;

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
  final ConversationRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String messageId) async {
    return await repository.deleteMessage(messageId);
  }
}

class GetMessageByIdUseCase {
  final ConversationRepository repository;

  GetMessageByIdUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(String messageId) async {
    return await repository.getMessageById(messageId);
  }
}
