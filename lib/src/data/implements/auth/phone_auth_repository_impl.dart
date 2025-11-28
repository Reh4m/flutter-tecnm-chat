import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/phone_auth_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/phone_verification_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/auth/phone_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_auth_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_verification_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/auth/phone_authentication_repository.dart';

class PhoneAuthRepositoryImpl implements PhoneAuthenticationRepository {
  final FirebasePhoneAuthenticationService firebasePhoneAuthentication;
  final NetworkInfo networkInfo;

  PhoneAuthRepositoryImpl({
    required this.firebasePhoneAuthentication,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> sendPhoneVerificationCode(
    PhoneAuthEntity phoneAuthData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final phoneAuthModel = PhoneAuthModel(
        phoneNumber: phoneAuthData.phoneNumber,
      );

      final verificationId = await firebasePhoneAuthentication
          .sendVerificationCode(phoneAuthModel);

      return Right(verificationId);
    } on InvalidPhoneNumberException {
      return Left(InvalidPhoneNumberFailure());
    } on TooManySMSRequestsException {
      return Left(TooManySMSRequestsFailure());
    } on SMSQuotaExceededException {
      return Left(SMSQuotaExceededFailure());
    } on PhoneAuthNotEnabledException {
      return Left(PhoneAuthNotEnabledFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserCredential>> verifyPhoneCode(
    PhoneVerificationEntity verificationData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final verificationModel = PhoneVerificationModel(
        verificationId: verificationData.verificationId,
        verificationCode: verificationData.verificationCode,
      );

      final userCredential = await firebasePhoneAuthentication.verifyOTPCode(
        verificationModel,
      );

      return Right(userCredential);
    } on InvalidVerificationCodeException {
      return Left(InvalidVerificationCodeFailure());
    } on MissingVerificationIdException {
      return Left(MissingVerificationIdFailure());
    } on VerificationExpiredException {
      return Left(VerificationExpiredFailure());
    } on PhoneAlreadyInUseException {
      return Left(PhoneAlreadyInUseFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> resendPhoneVerificationCode(
    PhoneAuthEntity phoneAuthData,
    int? resendToken,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final phoneAuthModel = PhoneAuthModel(
        phoneNumber: phoneAuthData.phoneNumber,
      );

      final verificationId = await firebasePhoneAuthentication
          .resendVerificationCode(phoneAuthModel, resendToken);

      return Right(verificationId);
    } on InvalidPhoneNumberException {
      return Left(InvalidPhoneNumberFailure());
    } on TooManySMSRequestsException {
      return Left(TooManySMSRequestsFailure());
    } on SMSQuotaExceededException {
      return Left(SMSQuotaExceededFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
