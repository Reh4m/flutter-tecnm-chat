import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/notification_repository.dart';

class InitializeNotificationsUseCase {
  final NotificationRepository repository;

  InitializeNotificationsUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.initialize();
  }
}

class RequestNotificationPermissionUseCase {
  final NotificationRepository repository;

  RequestNotificationPermissionUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.requestPermission();
  }
}

class GetAndSaveTokenUseCase {
  final NotificationRepository repository;

  GetAndSaveTokenUseCase(this.repository);

  Future<Either<Failure, String?>> call(String userId) async {
    return await repository.getAndSaveToken(userId);
  }
}

class RemoveNotificationTokenUseCase {
  final NotificationRepository repository;

  RemoveNotificationTokenUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.removeToken(userId);
  }
}

class GetInitialMessageUseCase {
  final NotificationRepository repository;

  GetInitialMessageUseCase(this.repository);

  Future<Either<Failure, RemoteMessage?>> call() async {
    return await repository.getInitialMessage();
  }
}

class ShowLocalNotificationUseCase {
  final NotificationRepository repository;

  ShowLocalNotificationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(RemoteMessage message) async {
    return await repository.showLocalNotification(message);
  }
}

class SubscribeToGroupNotificationsUseCase {
  final NotificationRepository repository;

  SubscribeToGroupNotificationsUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String groupId) async {
    return await repository.subscribeToGroup(groupId);
  }
}

class UnsubscribeFromGroupNotificationsUseCase {
  final NotificationRepository repository;

  UnsubscribeFromGroupNotificationsUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String groupId) async {
    return await repository.unsubscribeFromGroup(groupId);
  }
}

class GetTokenRefreshStreamUseCase {
  final NotificationRepository repository;

  GetTokenRefreshStreamUseCase(this.repository);

  Stream<String> call() {
    return repository.onTokenRefresh;
  }
}

class GetForegroundMessageStreamUseCase {
  final NotificationRepository repository;

  GetForegroundMessageStreamUseCase(this.repository);

  Stream<RemoteMessage> call() {
    return repository.onMessageForeground;
  }
}

class GetMessageOpenedAppStreamUseCase {
  final NotificationRepository repository;

  GetMessageOpenedAppStreamUseCase(this.repository);

  Stream<RemoteMessage> call() {
    return repository.onMessageOpenedApp;
  }
}
