import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/password_reset_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/sign_in_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/sign_up_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/password_reset_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_in_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/authentication_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FirebaseAuthenticationService firebaseAuthentication;
  final NetworkInfo networkInfo;

  AuthenticationRepositoryImpl({
    required this.firebaseAuthentication,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserCredential>> signInWithEmailAndPassword(
    SignInEntity signInData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final signInModel = SignInModel(
        email: signInData.email,
        password: signInData.password,
      );
      final userCredential = await firebaseAuthentication
          .signInWithEmailAndPassword(signInModel);

      return Right(userCredential);
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on WrongPasswordException {
      return Left(WrongPasswordFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signUpWithEmailAndPassword(
    SignUpEntity signUpData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Future.value(Left(NetworkFailure()));
    }

    if (signUpData.password != signUpData.confirmPassword) {
      return Future.value(Left(PasswordMismatchFailure()));
    }

    try {
      final signUpModel = SignUpModel(
        name: signUpData.name,
        email: signUpData.email,
        password: signUpData.password,
        confirmPassword: signUpData.confirmPassword,
      );

      final userCredential = await firebaseAuthentication
          .signUpWithEmailAndPassword(signUpModel);

      return Right(userCredential);
    } on WeakPasswordException {
      return Left(WeakPasswordFailure());
    } on ExistingEmailException {
      return Left(ExistingEmailFailure());
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyEmail() async {
    if (!await networkInfo.isConnected) {
      return Future.value(Left(NetworkFailure()));
    }

    try {
      await firebaseAuthentication.verifyEmail();

      return const Right(unit);
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  Future<void> waitForEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      while (!user.emailVerified) {
        await Future.delayed(const Duration(seconds: 5));
        await user.reload();
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> checkEmailVerification() {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        return Future.value(const Right(unit));
      } else {
        return Future.value(Left(EmailVerificationFailure()));
      }
    } catch (e) {
      return Future.value(Left(ServerFailure()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(
    PasswordResetEntity passwordResetData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Future.value(Left(NetworkFailure()));
    }

    try {
      final passwordResetModel = PasswordResetModel(
        email: passwordResetData.email,
      );
      await firebaseAuthentication.resetPassword(passwordResetModel);
      return Future.value(const Right(unit));
    } on UserNotFoundException {
      return Future.value(Left(UserNotFoundFailure()));
    } on TooManyRequestsException {
      return Future.value(Left(TooManyRequestsFailure()));
    } on ServerException {
      return Future.value(Left(ServerFailure()));
    } catch (e) {
      return Future.value(Left(ServerFailure()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await FirebaseAuth.instance.signOut();

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
