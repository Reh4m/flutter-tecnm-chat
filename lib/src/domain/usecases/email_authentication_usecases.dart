import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/password_reset_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/email_authentication_repository.dart';

class SendEmailVerificationUseCase {
  final EmailAuthenticationRepository repository;

  SendEmailVerificationUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.sendEmailVerification();
  }
}

class CheckEmailVerificationUseCase {
  final EmailAuthenticationRepository repository;

  CheckEmailVerificationUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.checkEmailVerification();
  }
}

class ResetPasswordUseCase {
  final EmailAuthenticationRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call(
    PasswordResetEntity passwordResetData,
  ) async {
    return await repository.resetPassword(passwordResetData);
  }
}
