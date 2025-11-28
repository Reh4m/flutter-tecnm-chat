import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';

abstract class MessageRepository {
  Future<Either<Failure, MessageEntity>> sendMessage(MessageEntity message);

  Future<Either<Failure, Unit>> updateMessageStatus({
    required String messageId,
    required MessageStatus status,
  });

  Future<Either<Failure, Unit>> markMessageAsRead({
    required String messageId,
    required String userId,
  });

  Future<Either<Failure, Unit>> markAllMessagesAsDelivered({
    required String conversationId,
    required String userId,
  });

  Future<Either<Failure, Unit>> deleteMessage(String messageId);

  Future<Either<Failure, MessageEntity>> getMessageById(String messageId);

  Future<Either<Failure, List<MessageEntity>>> getConversationMessages({
    required String conversationId,
    int limit = 50,
    DocumentSnapshot? startAfter,
  });

  Stream<Either<Failure, List<MessageEntity>>> getConversationMessagesStream({
    required String conversationId,
    int limit = 50,
  });
}
