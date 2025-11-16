import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/password_reset_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_in_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/authentication_repository.dart';

class SignInUseCase {
  final AuthenticationRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserCredential>> call(SignInEntity signInData) async {
    return await repository.signInWithEmailAndPassword(signInData);
  }
}

class SignUpUseCase {
  final AuthenticationRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserCredential>> call(SignUpEntity signUpData) async {
    return await repository.signUpWithEmailAndPassword(signUpData);
  }
}

class VerifyEmailUseCase {
  final AuthenticationRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.verifyEmail();
  }
}

class CheckEmailVerificationUseCase {
  final AuthenticationRepository repository;

  CheckEmailVerificationUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.checkEmailVerification();
  }
}

class ResetPasswordUseCase {
  final AuthenticationRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call(
    PasswordResetEntity passwordResetData,
  ) async {
    return await repository.resetPassword(passwordResetData);
  }
}

class SignOutUseCase {
  final AuthenticationRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.signOut();
  }
}
