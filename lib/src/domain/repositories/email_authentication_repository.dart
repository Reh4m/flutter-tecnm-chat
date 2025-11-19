import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/password_reset_entity.dart';

abstract class EmailAuthenticationRepository {
  Future<Either<Failure, Unit>> sendEmailVerification();
  Future<Either<Failure, bool>> checkEmailVerification();
  Future<Either<Failure, Unit>> resetPassword(
    PasswordResetEntity passwordResetData,
  );
}
