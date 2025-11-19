import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_auth_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_verification_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/phone_authentication_repository.dart';

class SendPhoneVerificationCodeUseCase {
  final PhoneAuthenticationRepository repository;

  SendPhoneVerificationCodeUseCase(this.repository);

  Future<Either<Failure, String>> call(PhoneAuthEntity phoneAuthData) async {
    return await repository.sendPhoneVerificationCode(phoneAuthData);
  }
}

class VerifyPhoneCodeUseCase {
  final PhoneAuthenticationRepository repository;

  VerifyPhoneCodeUseCase(this.repository);

  Future<Either<Failure, UserCredential>> call(
    PhoneVerificationEntity verificationData,
  ) async {
    return await repository.verifyPhoneCode(verificationData);
  }
}

class ResendPhoneVerificationCodeUseCase {
  final PhoneAuthenticationRepository repository;

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
