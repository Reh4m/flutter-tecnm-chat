import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/storage/chat_media_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final FirebaseChatMediaService mediaService;
  final NetworkInfo networkInfo;

  MediaRepositoryImpl({required this.mediaService, required this.networkInfo});

  static const int maxImageSizeInBytes = 10 * 1024 * 1024;
  static const int maxVideoSizeInBytes = 50 * 1024 * 1024;
  static const int maxAudioSizeInBytes = 10 * 1024 * 1024;

  @override
  Future<Either<Failure, String>> uploadChatImage({
    required File image,
    required String conversationId,
    required String senderId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final isValidSize = await validateImageSize(image);
      if (isValidSize.isLeft()) {
        return Left(MediaTooLargeFailure());
      }

      final url = await mediaService.uploadChatImage(
        image: image,
        conversationId: conversationId,
        senderId: senderId,
      );
      return Right(url);
    } on MediaUploadException {
      return Left(MediaUploadFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadChatVideo({
    required File video,
    required String conversationId,
    required String senderId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final isValidSize = await validateVideoSize(video);
      if (isValidSize.isLeft()) {
        return Left(MediaTooLargeFailure());
      }

      final url = await mediaService.uploadChatVideo(
        video: video,
        conversationId: conversationId,
        senderId: senderId,
      );
      return Right(url);
    } on MediaUploadException {
      return Left(MediaUploadFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadChatAudio({
    required File audio,
    required String conversationId,
    required String senderId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final isValidSize = await validateAudioSize(audio);
      if (isValidSize.isLeft()) {
        return Left(MediaTooLargeFailure());
      }

      final url = await mediaService.uploadChatAudio(
        audio: audio,
        conversationId: conversationId,
        senderId: senderId,
      );
      return Right(url);
    } on MediaUploadException {
      return Left(MediaUploadFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadChatDocument({
    required File document,
    required String conversationId,
    required String senderId,
    required String fileExtension,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final url = await mediaService.uploadChatDocument(
        document: document,
        conversationId: conversationId,
        senderId: senderId,
        fileExtension: fileExtension,
      );
      return Right(url);
    } on MediaUploadException {
      return Left(MediaUploadFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadVideoThumbnail({
    required File thumbnail,
    required String conversationId,
    required String videoFileName,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final url = await mediaService.uploadVideoThumbnail(
        thumbnail: thumbnail,
        conversationId: conversationId,
        videoFileName: videoFileName,
      );
      return Right(url);
    } on ThumbnailGenerationException {
      return Left(ThumbnailGenerationFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMedia(String mediaUrl) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await mediaService.deleteMediaByUrl(mediaUrl);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, double>> uploadFileWithProgress({
    required File file,
    required String path,
  }) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final snapshot in mediaService.uploadFileWithProgress(
        file: file,
        path: path,
      )) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        yield Right(progress);
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> validateImageSize(File image) async {
    try {
      final fileSize = await image.length();
      if (fileSize > maxImageSizeInBytes) {
        return Left(MediaTooLargeFailure());
      }
      return const Right(true);
    } catch (e) {
      return Left(InvalidMediaFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> validateVideoSize(File video) async {
    try {
      final fileSize = await video.length();
      if (fileSize > maxVideoSizeInBytes) {
        return Left(MediaTooLargeFailure());
      }
      return const Right(true);
    } catch (e) {
      return Left(InvalidMediaFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> validateAudioSize(File audio) async {
    try {
      final fileSize = await audio.length();
      if (fileSize > maxAudioSizeInBytes) {
        return Left(MediaTooLargeFailure());
      }
      return const Right(true);
    } catch (e) {
      return Left(InvalidMediaFailure());
    }
  }
}
