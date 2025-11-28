import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/direct_chat_entity.dart';

abstract class DirectChatRepository {
  Future<Either<Failure, DirectChatEntity>> createConversation(
    DirectChatEntity conversation,
  );
  Future<Either<Failure, DirectChatEntity>> getOrCreateDirectConversation({
    required String userId1,
    required String userId2,
  });
  Stream<Either<Failure, List<DirectChatEntity>>> getUserConversationsStream(
    String userId,
  );
  Future<Either<Failure, DirectChatEntity>> getConversationById(
    String conversationId,
  );
  Future<Either<Failure, DirectChatEntity>> updateConversation(
    DirectChatEntity conversation,
  );
  Future<Either<Failure, Unit>> deleteConversation(String conversationId);
  Future<Either<Failure, Unit>> markConversationAsRead({
    required String conversationId,
    required String userId,
  });
}
