import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';

abstract class MediaRepository {
  Future<Either<Failure, String>> uploadChatImage({
    required File image,
    required String conversationId,
    required String senderId,
  });
  Future<Either<Failure, String>> uploadChatVideo({
    required File video,
    required String conversationId,
    required String senderId,
  });
  Future<Either<Failure, String>> uploadChatAudio({
    required File audio,
    required String conversationId,
    required String senderId,
  });
  Future<Either<Failure, String>> uploadChatDocument({
    required File document,
    required String conversationId,
    required String senderId,
    required String extension,
  });
  Future<Either<Failure, String>> uploadVideoThumbnail({
    required File thumbnail,
    required String conversationId,
    required String videoFileName,
  });
  Future<Either<Failure, Unit>> deleteMedia(String mediaUrl);
  Stream<Either<Failure, double>> uploadFileWithProgress({
    required File file,
    required String path,
  });
  Future<Either<Failure, bool>> validateImageSize(File image);
  Future<Either<Failure, bool>> validateVideoSize(File video);
  Future<Either<Failure, bool>> validateAudioSize(File audio);
}
