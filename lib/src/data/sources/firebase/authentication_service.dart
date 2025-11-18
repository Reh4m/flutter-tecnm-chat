import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/password_reset_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/sign_up_model.dart';

class FirebaseAuthenticationService {
  Future<UserCredential> signUpWithEmailAndPassword(
    SignUpModel signUpData,
  ) async {
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: signUpData.email,
        password: signUpData.password,
      );

      await result.user?.updateDisplayName(signUpData.name);

      return result;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw ExistingEmailException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else {
        throw ServerException();
      }
    }
  }

  Future<Unit> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

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
      final user = FirebaseAuth.instance.currentUser;

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
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: passwordResetData.email,
      );

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
