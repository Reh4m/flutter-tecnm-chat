import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _localNotifications;

  // Canal de notificaciones para Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'tecchat_messages_channel',
    'Mensajes de TecChat',
    description: 'Notificaciones de mensajes nuevos en TecChat',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  FirebaseNotificationService({
    required FirebaseMessaging firebaseMessaging,
    required FirebaseFirestore firestore,
    required FlutterLocalNotificationsPlugin localNotifications,
  }) : _firebaseMessaging = firebaseMessaging,
       _firestore = firestore,
       _localNotifications = localNotifications;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    // Crear canal de notificaciones en Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Configurar opciones de presentación en foreground
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Inicializar notificaciones locales
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Solicita permisos de notificación
  Future<bool> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      throw ServerException();
    }
  }

  /// Obtiene el token FCM del dispositivo
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      throw ServerException();
    }
  }

  /// Guarda el token FCM en Firestore asociado al usuario
  Future<void> saveTokenToFirestore({
    required String userId,
    required String token,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  /// Elimina un token FCM específico del usuario
  Future<void> removeTokenFromFirestore({
    required String userId,
    required String token,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  /// Stream para escuchar cambios en el token
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  /// Stream para mensajes recibidos en foreground
  Stream<RemoteMessage> get onMessageForeground => FirebaseMessaging.onMessage;

  /// Stream para cuando el usuario toca una notificación (app en background)
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Obtiene el mensaje inicial si la app se abrió desde una notificación
  Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessaging.getInitialMessage();
  }

  /// Muestra una notificación local cuando la app está en foreground
  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  /// Callback cuando el usuario toca una notificación local
  void _onNotificationTapped(NotificationResponse response) {
    // Este callback se maneja en el NotificationHandler
    // El payload contiene los datos para navegar al chat
  }

  /// Suscribirse a un topic (útil para notificaciones grupales)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      throw ServerException();
    }
  }

  /// Desuscribirse de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw ServerException();
    }
  }
}
