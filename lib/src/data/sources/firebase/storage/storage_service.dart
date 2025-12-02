import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';

class FirebaseStorageService {
  final FirebaseStorage storage;

  FirebaseStorageService({required this.storage});

  Future<String> uploadUserProfileImage(File image, String userId) async {
    try {
      final fileName = '${userId}_profile.jpg';
      final ref = storage.ref().child('users').child(userId).child(fileName);

      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> uploadGroupProfileImage(File image, String groupId) async {
    try {
      final fileName = '${groupId}_profile.jpg';
      final ref = storage.ref().child('groups').child(groupId).child(fileName);

      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw ServerException();
    }
  }
}
