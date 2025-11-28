import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/direct_chat_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/direct_chat_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/direct_chat_repository.dart';

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
}
