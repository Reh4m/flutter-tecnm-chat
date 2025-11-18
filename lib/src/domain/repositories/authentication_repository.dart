import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/password_reset_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_auth_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_registration_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_verification_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_in_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_up_entity.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, UserCredential>> signInWithEmailAndPassword(
    SignInEntity signInData,
  );
  Future<Either<Failure, UserCredential>> signUpWithEmailAndPassword(
    SignUpEntity signUpData,
  );
  Future<Either<Failure, Unit>> sendEmailVerification();
  Future<Either<Failure, bool>> checkEmailVerification();

  Future<Either<Failure, String>> sendPhoneVerificationCode(
    PhoneAuthEntity phoneAuthData,
  );
  Future<Either<Failure, UserCredential>> verifyPhoneCode(
    PhoneVerificationEntity verificationData,
  );
  Future<Either<Failure, Unit>> completeUserRegistration(
    UserRegistrationEntity registrationData,
  );
  Future<Either<Failure, String>> resendPhoneVerificationCode(
    PhoneAuthEntity phoneAuthData,
    int? resendToken,
  );
  Future<Either<Failure, bool>> isRegistrationComplete();
  Future<Either<Failure, UserCredential>> linkEmailPasswordToPhoneAccount({
    required String email,
    required String password,
  });
  Future<Either<Failure, Unit>> resetPassword(
    PasswordResetEntity passwordResetData,
  );
  Future<Either<Failure, Unit>> signOut();
}
