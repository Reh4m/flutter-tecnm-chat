import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/direct_chat_repository.dart';

class CreateDirectChatUseCase {
  final DirectChatRepository repository;

  CreateDirectChatUseCase(this.repository);

  Future<Either<Failure, DirectChatEntity>> call(DirectChatEntity chat) async {
    return await repository.createChat(chat);
  }
}

class GetOrCreateDirectChatUseCase {
  final DirectChatRepository repository;

  GetOrCreateDirectChatUseCase(this.repository);

  Future<Either<Failure, DirectChatEntity>> call({
    required String userId1,
    required String userId2,
  }) async {
    return await repository.getOrCreateChat(userId1: userId1, userId2: userId2);
  }
}

class GetUserDirectChatsStreamUseCase {
  final DirectChatRepository repository;

  GetUserDirectChatsStreamUseCase(this.repository);

  Stream<Either<Failure, List<DirectChatEntity>>> call(String userId) {
    return repository.getUserChatsStream(userId);
  }
}

class GetDirectChatByIdUseCase {
  final DirectChatRepository repository;

  GetDirectChatByIdUseCase(this.repository);

  Future<Either<Failure, DirectChatEntity>> call(String chatId) async {
    return await repository.getChatById(chatId);
  }
}

class UpdateDirectChatUseCase {
  final DirectChatRepository repository;

  UpdateDirectChatUseCase(this.repository);

  Future<Either<Failure, DirectChatEntity>> call(DirectChatEntity chat) async {
    return await repository.updateChat(chat);
  }
}

class DeleteDirectChatUseCase {
  final DirectChatRepository repository;

  DeleteDirectChatUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String chatId) async {
    return await repository.deleteChat(chatId);
  }
}

class UpdateDirectChatLastMessageUseCase {
  final DirectChatRepository repository;

  UpdateDirectChatLastMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required MessageEntity message}) async {
    return await repository.updateChatLastMessage(message: message);
  }
}
