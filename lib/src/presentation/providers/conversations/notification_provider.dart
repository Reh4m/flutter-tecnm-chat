import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart' as di;
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/notification_usecases.dart';

enum NotificationState { initial, loading, ready, error }

class NotificationProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = di.sl<FirebaseAuth>();

  final InitializeNotificationsUseCase _initializeUseCase =
      di.sl<InitializeNotificationsUseCase>();
  final RequestNotificationPermissionUseCase _requestPermissionUseCase =
      di.sl<RequestNotificationPermissionUseCase>();
  final GetAndSaveTokenUseCase _getAndSaveTokenUseCase =
      di.sl<GetAndSaveTokenUseCase>();
  final RemoveNotificationTokenUseCase _removeTokenUseCase =
      di.sl<RemoveNotificationTokenUseCase>();
  final GetInitialMessageUseCase _getInitialMessageUseCase =
      di.sl<GetInitialMessageUseCase>();
  final ShowLocalNotificationUseCase _showLocalNotificationUseCase =
      di.sl<ShowLocalNotificationUseCase>();
  final GetTokenRefreshStreamUseCase _getTokenRefreshStreamUseCase =
      di.sl<GetTokenRefreshStreamUseCase>();
  final GetForegroundMessageStreamUseCase _getForegroundMessageStreamUseCase =
      di.sl<GetForegroundMessageStreamUseCase>();
  final GetMessageOpenedAppStreamUseCase _getMessageOpenedAppStreamUseCase =
      di.sl<GetMessageOpenedAppStreamUseCase>();

  NotificationState _state = NotificationState.initial;
  String? _error;
  bool _permissionGranted = false;
  String? _currentToken;

  // Subscriptions
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;

  // Callback para manejar navegación cuando se toca una notificación
  Function(String conversationId, bool isGroup)? onNotificationTapped;

  // Getters
  NotificationState get state => _state;
  String? get error => _error;
  bool get permissionGranted => _permissionGranted;
  String? get currentToken => _currentToken;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    _setState(NotificationState.loading);

    // 1. Inicializar el servicio
    final initResult = await _initializeUseCase();

    if (initResult.isLeft()) {
      _setError('Error al inicializar notificaciones');
      return;
    }

    // 2. Solicitar permisos
    final permissionResult = await _requestPermissionUseCase();

    permissionResult.fold(
      (failure) => _setError('Error al solicitar permisos'),
      (granted) => _permissionGranted = granted,
    );

    if (!_permissionGranted) {
      _setState(NotificationState.ready);
      return;
    }

    // 3. Obtener y guardar token si hay usuario autenticado
    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId != null) {
      await _setupToken(currentUserId);
    }

    // 4. Configurar listeners
    _setupListeners();

    // 5. Verificar si la app se abrió desde una notificación
    await _checkInitialMessage();

    _setState(NotificationState.ready);
  }

  /// Configura el token FCM para el usuario actual
  Future<void> _setupToken(String userId) async {
    final tokenResult = await _getAndSaveTokenUseCase(userId);

    tokenResult.fold(
      (failure) => debugPrint('Error al obtener token FCM'),
      (token) => _currentToken = token,
    );
  }

  /// Configura los listeners de notificaciones
  void _setupListeners() {
    // Listener para refresh de token
    _tokenRefreshSubscription = _getTokenRefreshStreamUseCase().listen((
      newToken,
    ) async {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId != null) {
        _currentToken = newToken;
        await _getAndSaveTokenUseCase(userId);
      }
    });

    // Listener para mensajes en foreground
    _foregroundMessageSubscription = _getForegroundMessageStreamUseCase()
        .listen((message) {
          _handleForegroundMessage(message);
        });

    // Listener para cuando se abre la app desde una notificación
    _messageOpenedAppSubscription = _getMessageOpenedAppStreamUseCase().listen((
      message,
    ) {
      _handleNotificationTap(message);
    });
  }

  /// Maneja mensajes recibidos en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Mensaje en foreground: ${message.notification?.title}');

    // Mostrar notificación local
    _showLocalNotificationUseCase(message);
  }

  /// Maneja cuando el usuario toca una notificación
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    final conversationId = data['conversationId'] as String?;
    final isGroup = data['isGroup'] == 'true';

    if (conversationId != null && onNotificationTapped != null) {
      onNotificationTapped!(conversationId, isGroup);
    }
  }

  /// Verifica si la app se abrió desde una notificación
  Future<void> _checkInitialMessage() async {
    final result = await _getInitialMessageUseCase();

    result.fold((failure) => null, (message) {
      if (message != null) {
        // Dar tiempo para que la app se inicialice completamente
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(message);
        });
      }
    });
  }

  /// Actualiza el token cuando el usuario inicia sesión
  Future<void> onUserLogin(String userId) async {
    if (!_permissionGranted) return;
    await _setupToken(userId);
  }

  /// Elimina el token cuando el usuario cierra sesión
  Future<void> onUserLogout(String userId) async {
    final result = await _removeTokenUseCase(userId);

    result.fold(
      (failure) => debugPrint('Error al eliminar token'),
      (_) => _currentToken = null,
    );
  }

  void _setState(NotificationState newState) {
    _state = newState;
    if (newState != NotificationState.error) {
      _error = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _setState(NotificationState.error);
  }

  @override
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
    super.dispose();
  }
}
