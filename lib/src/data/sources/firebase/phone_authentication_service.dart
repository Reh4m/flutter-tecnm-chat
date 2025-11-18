import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/phone_auth_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/phone_verification_model.dart';

class FirebasePhoneAuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static const Duration _verificationTimeout = Duration(seconds: 30);

  Future<String> sendVerificationCode(
    PhoneAuthModel phoneAuthData, {
    Function(String verificationId, int? resendToken)? onCodeSent,
    Function(PhoneAuthCredential credential)? onVerificationCompleted,
    Function(FirebaseAuthException e)? onVerificationFailed,
    Function(String verificationId)? onCodeAutoRetrievalTimeout,
  }) async {
    final Completer<String> completer = Completer<String>();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneAuthData.phoneNumber,
        timeout: _verificationTimeout,

        verificationCompleted: (PhoneAuthCredential credential) async {
          if (onVerificationCompleted != null) {
            onVerificationCompleted(credential);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(_handleVerificationError(e));
          }
          if (onVerificationFailed != null) {
            onVerificationFailed(e);
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
          if (onCodeSent != null) {
            onCodeSent(verificationId, resendToken);
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
          if (onCodeAutoRetrievalTimeout != null) {
            onCodeAutoRetrievalTimeout(verificationId);
          }
        },
      );

      return await completer.future;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ServerException();
    }
  }

  Future<UserCredential> verifyOTPCode(
    PhoneVerificationModel verificationData,
  ) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationData.verificationId,
        smsCode: verificationData.verificationCode,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleVerificationError(e);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<bool> isRegistrationComplete() async {
    try {
      final User? user = _firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      final hasName = user.displayName != null && user.displayName!.isNotEmpty;
      final hasEmail = user.email != null && user.email!.isNotEmpty;

      return hasName && hasEmail;
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<void> updateUserProfile({String? displayName}) async {
    try {
      final User? user = _firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw UnauthorizedUserOperationException();
      }
      throw ServerException();
    } catch (e) {
      if (e is UserNotFoundException ||
          e is UnauthorizedUserOperationException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  Future<String> resendVerificationCode(
    PhoneAuthModel phoneAuthData,
    int? resendToken, {
    Function(String verificationId, int? newResendToken)? onCodeSent,
    Function(FirebaseAuthException e)? onVerificationFailed,
  }) async {
    final Completer<String> completer = Completer<String>();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneAuthData.phoneNumber,
        timeout: _verificationTimeout,

        verificationCompleted: (PhoneAuthCredential credential) async {},

        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(_handleVerificationError(e));
          }
          if (onVerificationFailed != null) {
            onVerificationFailed(e);
          }
        },

        codeSent: (String verificationId, int? newResendToken) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
          if (onCodeSent != null) {
            onCodeSent(verificationId, newResendToken);
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
      );

      return await completer.future;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ServerException();
    }
  }

  Future<UserCredential> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final User? user = _firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final UserCredential userCredential = await user.linkWithCredential(
        credential,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw ExistingEmailException();
      } else if (e.code == 'invalid-email') {
        throw InvalidUserDataException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'provider-already-linked') {
        throw UserAlreadyExistsException();
      }
      throw ServerException();
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Exception _handleVerificationError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return InvalidPhoneNumberException();

      case 'invalid-verification-code':
        return InvalidVerificationCodeException();

      case 'invalid-verification-id':
        return MissingVerificationIdException();

      case 'session-expired':
        return VerificationExpiredException();

      case 'quota-exceeded':
        return SMSQuotaExceededException();

      case 'too-many-requests':
        return TooManySMSRequestsException();

      case 'credential-already-in-use':
      case 'phone-number-already-exists':
        return PhoneAlreadyInUseException();

      case 'operation-not-allowed':
        return PhoneAuthNotEnabledException();

      case 'user-disabled':
        return UnauthorizedUserOperationException();

      default:
        return ServerException();
    }
  }
}
