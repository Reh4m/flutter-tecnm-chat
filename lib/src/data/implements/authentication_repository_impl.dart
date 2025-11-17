import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/password_reset_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/sign_in_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/sign_up_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/user_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/password_reset_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_in_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/authentication_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FirebaseAuthenticationService firebaseAuthentication;
  final FirebaseUserService firebaseUserService;
  final NetworkInfo networkInfo;

  AuthenticationRepositoryImpl({
    required this.firebaseAuthentication,
    required this.firebaseUserService,
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
      return Left(NetworkFailure());
    }

    if (signUpData.password != signUpData.confirmPassword) {
      return Left(PasswordMismatchFailure());
    }

    try {
      final userCredential = await firebaseAuthentication
          .signUpWithEmailAndPassword(
            SignUpModel(
              name: signUpData.name,
              email: signUpData.email,
              password: signUpData.password,
              confirmPassword: signUpData.confirmPassword,
            ),
          );

      final currentUser = userCredential.user;

      await firebaseUserService.createUser(
        UserModel(
          id: currentUser!.uid,
          name: signUpData.name,
          email: signUpData.email,
          createdAt: DateTime.now(),
          isVerified: currentUser.emailVerified,
        ),
      );

      await firebaseAuthentication.sendEmailVerification();

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
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseAuthentication.sendEmailVerification();

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
  Future<Either<Failure, Unit>> waitForEmailVerification() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return Left(UserNotFoundFailure());
      }

      while (!await firebaseAuthentication.isEmailVerified()) {
        await Future.delayed(const Duration(seconds: 5));
      }

      return const Right(unit);
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
      await firebaseAuthentication.resetPassword(passwordResetModel);
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
