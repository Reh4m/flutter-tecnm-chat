import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_sign_up_entity.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, Unit>> linkEmailCredentialsAndVerify(
    UserSignUpEntity userRegistrationData,
  );
  Future<Either<Failure, Unit>> saveUserDataToFirestore();
  Future<Either<Failure, bool>> isRegistrationComplete();
  Future<Either<Failure, Unit>> signOut();
}
