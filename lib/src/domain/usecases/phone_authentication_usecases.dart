import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_auth_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_verification_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/authentication_repository.dart';

class SendPhoneVerificationCodeUseCase {
  final AuthenticationRepository repository;

  SendPhoneVerificationCodeUseCase(this.repository);

  Future<Either<Failure, String>> call(PhoneAuthEntity phoneAuthData) async {
    return await repository.sendPhoneVerificationCode(phoneAuthData);
  }
}

class VerifyPhoneCodeUseCase {
  final AuthenticationRepository repository;

  VerifyPhoneCodeUseCase(this.repository);

  Future<Either<Failure, UserCredential>> call(
    PhoneVerificationEntity verificationData,
  ) async {
    return await repository.verifyPhoneCode(verificationData);
  }
}

class CompleteUserRegistrationUseCase {
  final AuthenticationRepository repository;

  CompleteUserRegistrationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(UserSignUpEntity registrationData) async {
    return await repository.completeUserRegistration(registrationData);
  }
}

class ResendPhoneVerificationCodeUseCase {
  final AuthenticationRepository repository;

  ResendPhoneVerificationCodeUseCase(this.repository);

  Future<Either<Failure, String>> call(
    PhoneAuthEntity phoneAuthData,
    int? resendToken,
  ) async {
    return await repository.resendPhoneVerificationCode(
      phoneAuthData,
      resendToken,
    );
  }
}

class IsRegistrationCompleteUseCase {
  final AuthenticationRepository repository;

  IsRegistrationCompleteUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isRegistrationComplete();
  }
}

class LinkEmailPasswordToPhoneAccountUseCase {
  final AuthenticationRepository repository;

  LinkEmailPasswordToPhoneAccountUseCase(this.repository);

  Future<Either<Failure, UserCredential>> call({
    required String email,
    required String password,
  }) async {
    return await repository.linkEmailPasswordToPhoneAccount(
      email: email,
      password: password,
    );
  }
}
