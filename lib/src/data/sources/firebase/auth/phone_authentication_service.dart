import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/phone_auth_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/phone_verification_model.dart';

class FirebasePhoneAuthenticationService {
  final FirebaseAuth firebaseAuth;

  FirebasePhoneAuthenticationService({required this.firebaseAuth});

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
      await firebaseAuth.verifyPhoneNumber(
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

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleVerificationError(e);
    } catch (e) {
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
      await firebaseAuth.verifyPhoneNumber(
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
        return PhoneAlreadyInUseException();

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
