import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/authentication_repository.dart';

class LinkEmailCredentialsAndVerify {
  final AuthenticationRepository repository;

  LinkEmailCredentialsAndVerify(this.repository);

  Future<Either<Failure, Unit>> call(
    UserSignUpEntity userRegistrationData,
  ) async {
    return await repository.linkEmailCredentialsAndVerify(userRegistrationData);
  }
}

class SaveUserDataToFirestore {
  final AuthenticationRepository repository;

  SaveUserDataToFirestore(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.saveUserDataToFirestore();
  }
}

class IsRegistrationCompleteUseCase {
  final AuthenticationRepository repository;

  IsRegistrationCompleteUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isRegistrationComplete();
  }
}

class SignOutUseCase {
  final AuthenticationRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.signOut();
  }
}
