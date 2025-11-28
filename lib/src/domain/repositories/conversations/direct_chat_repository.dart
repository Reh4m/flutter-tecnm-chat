import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';

abstract class DirectChatRepository {
  Future<Either<Failure, DirectChatEntity>> createChat(DirectChatEntity chat);
  Future<Either<Failure, DirectChatEntity>> getOrCreateChat({
    required String userId1,
    required String userId2,
  });
  Stream<Either<Failure, List<DirectChatEntity>>> getUserChatsStream(
    String userId,
  );
  Future<Either<Failure, DirectChatEntity>> getChatById(String chatId);
  Future<Either<Failure, DirectChatEntity>> updateChat(DirectChatEntity chat);
  Future<Either<Failure, Unit>> deleteChat(String chatId);
  Future<Either<Failure, Unit>> markChatAsRead({
    required String chatId,
    required String userId,
  });
  Future<Either<Failure, Unit>> updateChatLastMessage({
    required MessageEntity message,
  });
}
