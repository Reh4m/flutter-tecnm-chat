import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversation_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';

abstract class ConversationRepository {
  Future<Either<Failure, ConversationEntity>> createConversation(
    ConversationEntity conversation,
  );
  Future<Either<Failure, ConversationEntity>> getOrCreateDirectConversation({
    required String userId1,
    required String userId2,
  });
  Stream<Either<Failure, List<ConversationEntity>>> getUserConversationsStream(
    String userId,
  );
  Future<Either<Failure, ConversationEntity>> getConversationById(
    String conversationId,
  );
  Future<Either<Failure, ConversationEntity>> updateConversation(
    ConversationEntity conversation,
  );
  Future<Either<Failure, Unit>> deleteConversation(String conversationId);
  Future<Either<Failure, MessageEntity>> sendMessage(MessageEntity message);
  Stream<Either<Failure, List<MessageEntity>>> getConversationMessagesStream({
    required String conversationId,
    int limit = 50,
  });
  Future<Either<Failure, List<MessageEntity>>> getConversationMessages({
    required String conversationId,
    int limit = 50,
    DocumentSnapshot? startAfter,
  });
  Future<Either<Failure, Unit>> markMessageAsRead({
    required String messageId,
    required String userId,
  });
  Future<Either<Failure, Unit>> markConversationAsRead({
    required String conversationId,
    required String userId,
  });
  Future<Either<Failure, Unit>> deleteMessage(String messageId);
  Future<Either<Failure, MessageEntity>> getMessageById(String messageId);
  Future<Either<Failure, Unit>> updateMessageStatus({
    required String messageId,
    required MessageStatus status,
  });
  Future<Either<Failure, Unit>> markAllMessagesAsDelivered({
    required String conversationId,
    required String userId,
  });
}
