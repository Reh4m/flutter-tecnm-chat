import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/user_repository.dart';

// Use Case para crear o actualizar usuario después de la autenticación
class CreateOrUpdateUserFromAuthUseCase {
  final UserRepository userRepository;

  CreateOrUpdateUserFromAuthUseCase(this.userRepository);

  Future<Either<Failure, UserEntity>> call(User firebaseUser) async {
    try {
      return await userRepository.createOrUpdateUserFromAuth(firebaseUser);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

// Use Case para sincronizar datos de usuario con Firebase Auth
class SyncUserWithAuthUseCase {
  final UserRepository userRepository;

  SyncUserWithAuthUseCase(this.userRepository);

  Future<Either<Failure, UserEntity?>> call() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return const Right(null);
    }

    try {
      final result = await userRepository.createOrUpdateUserFromAuth(
        firebaseUser,
      );
      return result.fold((failure) => Left(failure), (user) => Right(user));
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
