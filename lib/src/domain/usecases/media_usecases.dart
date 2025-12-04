import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/media_repository.dart';

class UploadChatImageUseCase {
  final MediaRepository repository;

  UploadChatImageUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required File image,
    required String conversationId,
    required String senderId,
  }) async {
    return await repository.uploadChatImage(
      image: image,
      conversationId: conversationId,
      senderId: senderId,
    );
  }
}

class UploadChatVideoUseCase {
  final MediaRepository repository;

  UploadChatVideoUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required File video,
    required String conversationId,
    required String senderId,
  }) async {
    return await repository.uploadChatVideo(
      video: video,
      conversationId: conversationId,
      senderId: senderId,
    );
  }
}

class UploadChatAudioUseCase {
  final MediaRepository repository;

  UploadChatAudioUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required File audio,
    required String conversationId,
    required String senderId,
  }) async {
    return await repository.uploadChatAudio(
      audio: audio,
      conversationId: conversationId,
      senderId: senderId,
    );
  }
}

class UploadChatDocumentUseCase {
  final MediaRepository repository;

  UploadChatDocumentUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required File document,
    required String conversationId,
    required String senderId,
    required String fileExtension,
  }) async {
    return await repository.uploadChatDocument(
      document: document,
      conversationId: conversationId,
      senderId: senderId,
      fileExtension: fileExtension,
    );
  }
}

class UploadVideoThumbnailUseCase {
  final MediaRepository repository;

  UploadVideoThumbnailUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required File thumbnail,
    required String conversationId,
    required String videoFileName,
  }) async {
    return await repository.uploadVideoThumbnail(
      thumbnail: thumbnail,
      conversationId: conversationId,
      videoFileName: videoFileName,
    );
  }
}

class DeleteMediaUseCase {
  final MediaRepository repository;

  DeleteMediaUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String mediaUrl) async {
    return await repository.deleteMedia(mediaUrl);
  }
}

class UploadFileWithProgressUseCase {
  final MediaRepository repository;

  UploadFileWithProgressUseCase(this.repository);

  Stream<Either<Failure, double>> call({
    required File file,
    required String path,
  }) {
    return repository.uploadFileWithProgress(file: file, path: path);
  }
}

class ValidateImageSizeUseCase {
  final MediaRepository repository;

  ValidateImageSizeUseCase(this.repository);

  Future<Either<Failure, bool>> call(File image) async {
    return await repository.validateImageSize(image);
  }
}

class ValidateVideoSizeUseCase {
  final MediaRepository repository;

  ValidateVideoSizeUseCase(this.repository);

  Future<Either<Failure, bool>> call(File video) async {
    return await repository.validateVideoSize(video);
  }
}

class ValidateAudioSizeUseCase {
  final MediaRepository repository;

  ValidateAudioSizeUseCase(this.repository);

  Future<Either<Failure, bool>> call(File audio) async {
    return await repository.validateAudioSize(audio);
  }
}
