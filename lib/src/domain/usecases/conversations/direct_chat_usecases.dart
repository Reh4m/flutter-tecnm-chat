import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/direct_chat_repository.dart';

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
