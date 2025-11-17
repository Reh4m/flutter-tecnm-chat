import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/user_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseUserService firebaseUserService;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.firebaseUserService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> getUserById(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final user = await firebaseUserService.getUserById(userId);
      return Right(user.toEntity());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final user = await firebaseUserService.getCurrentUser();
      return Right(user?.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, UserEntity>> getCurrentUserStream() async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final user in firebaseUserService.getCurrentUserStream()) {
        if (user != null) {
          yield Right(user.toEntity());
        } else {
          yield Left(UserNotFoundFailure());
        }
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final userModel = UserModel.fromEntity(user);
      final createdUser = await firebaseUserService.createUser(userModel);
      return Right(createdUser.toEntity());
    } on UserAlreadyExistsException {
      return Left(UserAlreadyExistsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final userModel = UserModel.fromEntity(user);
      final updatedUser = await firebaseUserService.updateUser(userModel);
      return Right(updatedUser.toEntity());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on UserUpdateFailedException {
      return Left(UserUpdateFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseUserService.deleteUser(userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
    File image,
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final imageUrl = await firebaseUserService.uploadProfileImage(
        image,
        userId,
      );
      return Right(imageUrl);
    } on ProfileImageUploadException {
      return Left(ProfileImageUploadFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfileImage(
    String userId,
    String imageUrl,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final updatedUser = await firebaseUserService.updateProfileImage(
        userId,
        imageUrl,
      );
      return Right(updatedUser.toEntity());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on UserUpdateFailedException {
      return Left(UserUpdateFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateNotificationSettings(
    String userId, {
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final updatedUser = await firebaseUserService.updateNotificationSettings(
        userId,
        notificationsEnabled: notificationsEnabled,
        emailNotificationsEnabled: emailNotificationsEnabled,
      );
      return Right(updatedUser.toEntity());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on UserUpdateFailedException {
      return Left(UserUpdateFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markUserAsVerified(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseUserService.markUserAsVerified(userId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkUserExists(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final exists = await firebaseUserService.checkUserExists(userId);
      return Right(exists);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
