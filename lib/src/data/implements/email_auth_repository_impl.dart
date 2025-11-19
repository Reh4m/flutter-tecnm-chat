import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/password_reset_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/email_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/password_reset_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/email_authentication_repository.dart';

class EmailAuthRepositoryImpl implements EmailAuthenticationRepository {
  final FirebaseEmailAuthenticationService firebaseEmailAuthentication;
  final FirebaseUserService firebaseUserService;
  final NetworkInfo networkInfo;

  EmailAuthRepositoryImpl({
    required this.firebaseEmailAuthentication,
    required this.firebaseUserService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseEmailAuthentication.sendEmailVerification();

      return const Right(unit);
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailVerification() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return Left(UserNotFoundFailure());
      }

      await user.reload();

      final isVerified = user.emailVerified;

      if (isVerified) {
        await firebaseUserService.markUserAsVerified(user.uid);
      }

      return Right(isVerified);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(
    PasswordResetEntity passwordResetData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final passwordResetModel = PasswordResetModel(
        email: passwordResetData.email,
      );
      await firebaseEmailAuthentication.resetPassword(passwordResetModel);
      return const Right(unit);
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
