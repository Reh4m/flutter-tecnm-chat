import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/message_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/message_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final FirebaseMessageService messageService;
  final NetworkInfo networkInfo;

  MessageRepositoryImpl({
    required this.messageService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    MessageEntity message,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final messageModel = MessageModel.fromEntity(message);
      final sent = await messageService.sendMessage(messageModel);
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
  Future<Either<Failure, Unit>> updateMessageStatus({
    required String messageId,
    required MessageStatus status,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await messageService.updateMessageStatus(
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
  Future<Either<Failure, Unit>> markMessageAsRead({
    required String messageId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await messageService.markMessageAsRead(
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
  Future<Either<Failure, Unit>> markAllMessagesAsDelivered({
    required String conversationId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await messageService.markAllMessagesAsDelivered(
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
  Future<Either<Failure, Unit>> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      messageService.markConversationAsRead(
        conversationId: conversationId,
        userId: userId,
      );

      return Future.value(const Right(unit));
    } on ServerException {
      return Future.value(Left(ServerFailure()));
    } catch (e) {
      return Future.value(Left(ServerFailure()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage(String messageId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await messageService.deleteMessage(messageId);
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
      final message = await messageService.getMessageById(messageId);
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
  Future<Either<Failure, List<MessageEntity>>> getConversationMessages({
    required String conversationId,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final messages = await messageService.getConversationMessages(
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
  Stream<Either<Failure, List<MessageEntity>>> getConversationMessagesStream({
    required String conversationId,
    int limit = 50,
  }) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final messages in messageService.getConversationMessagesStream(
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
}
