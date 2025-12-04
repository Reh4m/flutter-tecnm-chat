import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';

class FirebaseChatMediaService {
  final FirebaseStorage storage;

  FirebaseChatMediaService({required this.storage});

  Future<String> uploadChatImage({
    required File image,
    required String conversationId,
    required String senderId,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$senderId.jpg';
      final ref = storage
          .ref()
          .child('chat_media')
          .child(conversationId)
          .child('images')
          .child(fileName);

      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> uploadChatVideo({
    required File video,
    required String conversationId,
    required String senderId,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$senderId.mp4';
      final ref = storage
          .ref()
          .child('chat_media')
          .child(conversationId)
          .child('videos')
          .child(fileName);

      final uploadTask = ref.putFile(video);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> uploadChatAudio({
    required File audio,
    required String conversationId,
    required String senderId,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$senderId.m4a';
      final ref = storage
          .ref()
          .child('chat_media')
          .child(conversationId)
          .child('audios')
          .child(fileName);

      final uploadTask = ref.putFile(audio);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> uploadChatDocument({
    required File document,
    required String conversationId,
    required String senderId,
    required String fileExtension,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$senderId.$fileExtension';
      final ref = storage
          .ref()
          .child('chat_media')
          .child(conversationId)
          .child('documents')
          .child(fileName);

      final uploadTask = ref.putFile(document);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> uploadVideoThumbnail({
    required File thumbnail,
    required String conversationId,
    required String videoFileName,
  }) async {
    try {
      final fileName = 'thumb_$videoFileName.jpg';
      final ref = storage
          .ref()
          .child('chat_media')
          .child(conversationId)
          .child('thumbnails')
          .child(fileName);

      final uploadTask = ref.putFile(thumbnail);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> deleteMediaByUrl(String mediaUrl) async {
    try {
      final ref = storage.refFromURL(mediaUrl);
      await ref.delete();
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<TaskSnapshot> uploadFileWithProgress({
    required File file,
    required String path,
  }) {
    try {
      final ref = storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      return uploadTask.snapshotEvents;
    } catch (e) {
      throw ServerException();
    }
  }
}
