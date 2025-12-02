import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/user/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String userId) async {
    return await repository.getUserById(userId);
  }
}

class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}

class GetCurrentUserStreamUseCase {
  final UserRepository repository;

  GetCurrentUserStreamUseCase(this.repository);

  Stream<Either<Failure, UserEntity>> call() {
    return repository.getCurrentUserStream();
  }
}

class CreateUserUseCase {
  final UserRepository repository;

  CreateUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UserEntity user) async {
    return await repository.createUser(user);
  }
}

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UserEntity user) async {
    return await repository.updateUser(user);
  }
}

class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.deleteUser(userId);
  }
}

class UploadUserProfileImageUseCase {
  final UserRepository repository;

  UploadUserProfileImageUseCase(this.repository);

  Future<Either<Failure, String>> call(File image, String userId) async {
    return await repository.uploadProfileImage(image, userId);
  }
}

class UpdateUserProfileImageUseCase {
  final UserRepository repository;

  UpdateUserProfileImageUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String userId,
    String imageUrl,
  ) async {
    return await repository.updateProfileImage(userId, imageUrl);
  }
}

class UpdateNotificationSettingsUseCase {
  final UserRepository repository;

  UpdateNotificationSettingsUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String userId, {
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  }) async {
    return await repository.updateNotificationSettings(
      userId,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
    );
  }
}

class MarkUserAsVerifiedUseCase {
  final UserRepository repository;

  MarkUserAsVerifiedUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.markUserAsVerified(userId);
  }
}

class CheckUserExistsUseCase {
  final UserRepository repository;

  CheckUserExistsUseCase(this.repository);

  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.checkUserExists(userId);
  }
}
