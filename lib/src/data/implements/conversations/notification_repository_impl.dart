import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/notification_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseNotificationService notificationService;
  final NetworkInfo networkInfo;

  String? _currentToken;

  NotificationRepositoryImpl({
    required this.notificationService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Unit>> initialize() async {
    try {
      await notificationService.initialize();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      final granted = await notificationService.requestPermission();
      return Right(granted);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> getAndSaveToken(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final token = await notificationService.getToken();

      if (token != null) {
        await notificationService.saveTokenToFirestore(
          userId: userId,
          token: token,
        );
        _currentToken = token;
      }

      return Right(token);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeToken(String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      if (_currentToken != null) {
        await notificationService.removeTokenFromFirestore(
          userId: userId,
          token: _currentToken!,
        );
        _currentToken = null;
      }
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<String> get onTokenRefresh => notificationService.onTokenRefresh;

  @override
  Stream<RemoteMessage> get onMessageForeground =>
      notificationService.onMessageForeground;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      notificationService.onMessageOpenedApp;

  @override
  Future<Either<Failure, RemoteMessage?>> getInitialMessage() async {
    try {
      final message = await notificationService.getInitialMessage();
      return Right(message);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> showLocalNotification(
    RemoteMessage message,
  ) async {
    try {
      await notificationService.showLocalNotification(message);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> subscribeToGroup(String groupId) async {
    try {
      await notificationService.subscribeToTopic('group_$groupId');
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> unsubscribeFromGroup(String groupId) async {
    try {
      await notificationService.unsubscribeFromTopic('group_$groupId');
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
