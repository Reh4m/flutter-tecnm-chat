import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/direct_chat_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/message_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/direct_chat_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/direct_chat_repository.dart';

class DirectChatRepositoryImpl implements DirectChatRepository {
  final FirebaseDirectChatService directChatService;
  final NetworkInfo networkInfo;

  DirectChatRepositoryImpl({
    required this.directChatService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DirectChatEntity>> createChat(
    DirectChatEntity chat,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final directChatModel = DirectChatModel.fromEntity(chat);
      final created = await directChatService.createChat(directChatModel);
      return Right(created.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DirectChatEntity>> getOrCreateChat({
    required String userId1,
    required String userId2,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final existing = await directChatService.findChatByParticipants(
        userId1: userId1,
        userId2: userId2,
      );

      if (existing != null) {
        return Right(existing.toEntity());
      }

      final newChat = DirectChatModel(
        id: '',
        participantIds: [userId1, userId2],
        type: ConversationType.direct,
        createdAt: DateTime.now(),
      );

      final created = await directChatService.createChat(newChat);
      return Right(created.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<DirectChatEntity>>> getUserChatsStream(
    String userId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final chats in directChatService.getUserChatsStream(userId)) {
        yield Right(chats.map((c) => c.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DirectChatEntity>> getChatById(String chatId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final chat = await directChatService.getChatById(chatId);
      return Right(chat.toEntity());
    } on ConversationNotFoundException {
      return Left(ConversationNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DirectChatEntity>> updateChat(
    DirectChatEntity chat,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final directChatModel = DirectChatModel.fromEntity(chat);
      final updated = await directChatService.updateChat(directChatModel);
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
  Future<Either<Failure, Unit>> deleteChat(String chatId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await directChatService.deleteChat(chatId);
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
  Future<Either<Failure, Unit>> markChatAsRead({
    required String chatId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await directChatService.markChatAsRead(chatId: chatId, userId: userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateChatLastMessage({
    required MessageEntity message,
  }) async {
    if (!await networkInfo.isConnected) {
      return Future.value(Left(NetworkFailure()));
    }

    try {
      final messageModel = MessageModel.fromEntity(message);
      directChatService.updateChatLastMessage(messageModel);
      return Future.value(const Right(unit));
    } on ServerException {
      return Future.value(Left(ServerFailure()));
    } catch (e) {
      return Future.value(Left(ServerFailure()));
    }
  }
}
