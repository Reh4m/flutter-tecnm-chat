import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/password_reset_model.dart';

class FirebaseEmailAuthenticationService {
  final FirebaseAuth firebaseAuth;

  FirebaseEmailAuthenticationService({required this.firebaseAuth});

  Future<Unit> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      await user.reload();
      await user.sendEmailVerification();

      return unit;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw TooManyRequestsException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      await user.reload();

      return user.emailVerified;
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<Unit> resetPassword(PasswordResetModel passwordResetData) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: passwordResetData.email);

      return unit;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'too-many-requests') {
        throw TooManyRequestsException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
