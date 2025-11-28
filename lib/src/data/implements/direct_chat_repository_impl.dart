import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/direct_chat_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/message_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/direct_chat_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/direct_chat_repository.dart';

class DirectChatRepositoryImpl implements DirectChatRepository {
  final FirebaseDirectChatService conversationService;
  final NetworkInfo networkInfo;

  DirectChatRepositoryImpl({
    required this.conversationService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DirectChatEntity>> createConversation(
    DirectChatEntity conversation,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final directChatModel = DirectChatModel.fromEntity(conversation);
      final created = await conversationService.createConversation(
        directChatModel,
      );
      return Right(created.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DirectChatEntity>> getOrCreateDirectConversation({
    required String userId1,
    required String userId2,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final existing = await conversationService.findDirectConversation(
        userId1: userId1,
        userId2: userId2,
      );

      if (existing != null) {
        return Right(existing.toEntity());
      }

      final newConversation = DirectChatModel(
        id: '',
        participantIds: [userId1, userId2],
        type: ConversationType.direct,
        createdAt: DateTime.now(),
      );

      final created = await conversationService.createConversation(
        newConversation,
      );
      return Right(created.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<DirectChatEntity>>> getUserConversationsStream(
    String userId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final conversations in conversationService
          .getUserConversationsStream(userId)) {
        yield Right(conversations.map((c) => c.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DirectChatEntity>> getConversationById(
    String conversationId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final conversation = await conversationService.getConversationById(
        conversationId,
      );
      return Right(conversation.toEntity());
    } on ConversationNotFoundException {
      return Left(ConversationNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DirectChatEntity>> updateConversation(
    DirectChatEntity conversation,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final directChatModel = DirectChatModel.fromEntity(conversation);
      final updated = await conversationService.updateConversation(
        directChatModel,
      );
      return Right(updated.toEntity());
    } on ConversationOperationFailedException {
      return Left(ConversationOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteConversation(
    String conversationId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await conversationService.deleteConversation(conversationId);
      return const Right(unit);
    } on ConversationOperationFailedException {
      return Left(ConversationOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    MessageEntity message,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final messageModel = MessageModel.fromEntity(message);
      final sent = await conversationService.sendMessage(messageModel);
      return Right(sent.toEntity());
    } on MessageSendFailedException {
      return Left(MessageSendFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getConversationMessagesStream({
    required String conversationId,
    int limit = 50,
  }) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final messages in conversationService
          .getConversationMessagesStream(
            conversationId: conversationId,
            limit: limit,
          )) {
        yield Right(messages.map((m) => m.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getConversationMessages({
    required String conversationId,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final messages = await conversationService.getConversationMessages(
        conversationId: conversationId,
        limit: limit,
        startAfter: startAfter,
      );
      return Right(messages.map((m) => m.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markMessageAsRead({
    required String messageId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await conversationService.markMessageAsRead(
        messageId: messageId,
        userId: userId,
      );
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await conversationService.markConversationAsRead(
        conversationId: conversationId,
        userId: userId,
      );
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage(String messageId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await conversationService.deleteMessage(messageId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> getMessageById(
    String messageId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final message = await conversationService.getMessageById(messageId);
      return Right(message.toEntity());
    } on MessageNotFoundException {
      return Left(MessageNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMessageStatus({
    required String messageId,
    required MessageStatus status,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await conversationService.updateMessageStatus(
        messageId: messageId,
        status: status,
      );
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllMessagesAsDelivered({
    required String conversationId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await conversationService.markAllMessagesAsDelivered(
        conversationId: conversationId,
        userId: userId,
      );
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
