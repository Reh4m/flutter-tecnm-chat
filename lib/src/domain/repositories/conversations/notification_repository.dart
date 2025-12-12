import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';

abstract class NotificationRepository {
  Future<Either<Failure, Unit>> initialize();

  Future<Either<Failure, bool>> requestPermission();

  Future<Either<Failure, String?>> getAndSaveToken(String userId);

  Future<Either<Failure, Unit>> removeToken(String userId);

  Stream<String> get onTokenRefresh;

  Stream<RemoteMessage> get onMessageForeground;

  Stream<RemoteMessage> get onMessageOpenedApp;

  Future<Either<Failure, RemoteMessage?>> getInitialMessage();

  Future<Either<Failure, Unit>> showLocalNotification(RemoteMessage message);

  Future<Either<Failure, Unit>> subscribeToGroup(String groupId);

  Future<Either<Failure, Unit>> unsubscribeFromGroup(String groupId);
}
