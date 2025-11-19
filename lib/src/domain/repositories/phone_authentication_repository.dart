import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_auth_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_verification_entity.dart';

abstract class PhoneAuthenticationRepository {
  Future<Either<Failure, String>> sendPhoneVerificationCode(
    PhoneAuthEntity phoneAuthData,
  );
  Future<Either<Failure, UserCredential>> verifyPhoneCode(
    PhoneVerificationEntity verificationData,
  );
  Future<Either<Failure, String>> resendPhoneVerificationCode(
    PhoneAuthEntity phoneAuthData,
    int? resendToken,
  );
}
