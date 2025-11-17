import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/user_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/storage_service.dart';

class FirebaseUserService {
  final FirebaseFirestore firestore;
  final FirebaseStorageService storageService;

  FirebaseUserService({required this.firestore, required this.storageService});

  static const String _usersCollection = 'users';

  Future<UserModel> getUserById(String userId) async {
    try {
      final doc =
          await firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        throw UserNotFoundException();
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseInstance = FirebaseAuth.instance;

      await firebaseInstance.currentUser?.reload();

      final currentUser = firebaseInstance.currentUser;

      if (currentUser == null) return null;

      final doc =
          await firestore
              .collection(_usersCollection)
              .doc(currentUser.uid)
              .get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<UserModel?> getCurrentUserStream() {
    try {
      final firebaseInstance = FirebaseAuth.instance;

      final currentUser = firebaseInstance.currentUser;

      if (currentUser == null) {
        return Stream.value(null);
      }

      return firestore
          .collection(_usersCollection)
          .doc(currentUser.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            return UserModel.fromFirestore(doc);
          });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<UserModel> createUser(UserModel user) async {
    try {
      final userWithTimestamp = user.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(userWithTimestamp.toFirestore());

      return userWithTimestamp;
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        throw UserAlreadyExistsException();
      }
      throw ServerException();
    }
  }

  Future<UserModel> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      await firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(updatedUser.toFirestore());

      return updatedUser;
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        throw UserNotFoundException();
      }
      throw UserUpdateFailedException();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // 1. Eliminar foto de perfil si existe
      try {
        await storageService.deleteImageByUrl('users/$userId/profile.jpg');
      } catch (e) {
        // Si no existe la imagen, continuar
      }

      // 2. Eliminar documento de usuario
      await firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      return await storageService.uploadUserProfileImage(image, userId);
    } catch (e) {
      throw ProfileImageUploadException();
    }
  }

  Future<UserModel> updateProfileImage(String userId, String imageUrl) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).update({
        'photoUrl': imageUrl,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Retornar el usuario actualizado
      return await getUserById(userId);
    } catch (e) {
      throw UserUpdateFailedException();
    }
  }

  Future<UserModel> updateNotificationSettings(
    String userId, {
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (notificationsEnabled != null) {
        updateData['notificationsEnabled'] = notificationsEnabled;
      }

      if (emailNotificationsEnabled != null) {
        updateData['emailNotificationsEnabled'] = emailNotificationsEnabled;
      }

      await firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(updateData);

      return await getUserById(userId);
    } catch (e) {
      throw UserUpdateFailedException();
    }
  }

  Future<void> markUserAsVerified(String userId) async {
    try {
      await firestore.collection(_usersCollection).doc(userId).update({
        'isVerified': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<bool> checkUserExists(String userId) async {
    try {
      final doc =
          await firestore.collection(_usersCollection).doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw ServerException();
    }
  }
}
