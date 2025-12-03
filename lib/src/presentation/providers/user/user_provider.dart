import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user/user_usecases.dart';

enum UserState { initial, loading, success, error }

enum AvatarUploadState { initial, uploading, success, error }

class UserProvider extends ChangeNotifier {
  final GetCurrentUserUseCase _getCurrentUserUseCase =
      sl<GetCurrentUserUseCase>();
  final GetCurrentUserStreamUseCase _getCurrentUserStreamUseCase =
      sl<GetCurrentUserStreamUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();
  final UpdateUserUseCase _updateUserUseCase = sl<UpdateUserUseCase>();
  final UpdateNotificationSettingsUseCase _updateNotificationSettingsUseCase =
      sl<UpdateNotificationSettingsUseCase>();
  final UploadUserProfileImageUseCase _uploadProfileImageUseCase =
      sl<UploadUserProfileImageUseCase>();

  UserState _currentUserState = UserState.initial;
  UserEntity? _currentUser;
  String? _currentUserError;
  StreamSubscription? _currentUserSubscription;
  StreamSubscription? _authStateSubscription;

  UserState _operationState = UserState.initial;
  String? _operationError;

  UserState _userProfileState = UserState.initial;
  UserEntity? _userProfile;
  String? _userProfileError;

  FirebaseAuth get _firebaseAuth => sl<FirebaseAuth>();

  UserState get currentUserState => _currentUserState;
  UserEntity? get currentUser => _currentUser;
  String? get currentUserError => _currentUserError;
  bool get isLoggedIn => _currentUser != null;

  UserState get operationState => _operationState;
  String? get operationError => _operationError;

  UserState get userProfileState => _userProfileState;
  UserEntity? get userProfile => _userProfile;
  String? get userProfileError => _userProfileError;

  void initialize() async {
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        // User is signed in
        startCurrentUserListener();
      } else {
        // User is signed out
        clearCurrentUser();
      }
    });
  }

  void startCurrentUserListener() {
    _setCurrentUserState(UserState.loading);

    _currentUserSubscription = _getCurrentUserStreamUseCase().listen(
      (either) {
        either.fold(
          (failure) => _setCurrentUserError(_mapFailureToMessage(failure)),
          (user) {
            _currentUser = user;
            _setCurrentUserState(UserState.success);
          },
        );
      },
      onError: (error) {
        _setCurrentUserError('Error de conexión: $error');
      },
    );
  }

  void stopCurrentUserListener() {
    _currentUserSubscription?.cancel();
    _currentUserSubscription = null;
  }

  void stopAuthStateListener() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
  }

  Future<void> loadCurrentUser() async {
    _setCurrentUserState(UserState.loading);

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => _setCurrentUserError(_mapFailureToMessage(failure)),
      (user) {
        _currentUser = user;
        _setCurrentUserState(UserState.success);
      },
    );
  }

  Future<void> loadUserProfile(String userId) async {
    _setUserProfileState(UserState.loading);

    final result = await _getUserByIdUseCase(userId);

    result.fold(
      (failure) => _setUserProfileError(_mapFailureToMessage(failure)),
      (user) {
        _userProfile = user;
        _setUserProfileState(UserState.success);
      },
    );
  }

  Future<bool> updateCurrentUserWithImage({
    required UserEntity updatedUser,
    File? profileImageFile,
  }) async {
    if (_currentUser == null) return false;

    _setOperationState(UserState.loading);

    String? imageUrl;

    if (profileImageFile != null) {
      final uploadResult = await _uploadProfileImageUseCase(
        profileImageFile,
        _currentUser!.id,
      );

      final imageUploadSuccess = await uploadResult.fold(
        (failure) {
          _setOperationError(_mapFailureToMessage(failure));
          return false;
        },
        (url) {
          imageUrl = url;
          return true;
        },
      );

      if (!imageUploadSuccess) return false;
    }

    final userToUpdate =
        imageUrl != null
            ? updatedUser.copyWith(photoUrl: imageUrl)
            : updatedUser;

    final result = await _updateUserUseCase(userToUpdate);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (user) {
        _currentUser = user;
        _setOperationState(UserState.success);
        return true;
      },
    );
  }

  Future<bool> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  }) async {
    if (_currentUser == null) return false;

    _setOperationState(UserState.loading);

    final result = await _updateNotificationSettingsUseCase(
      _currentUser!.id,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (user) {
        _currentUser = user;
        _setOperationState(UserState.success);
        return true;
      },
    );
  }

  void clearUserProfile() {
    _userProfile = null;
    _setUserProfileState(UserState.initial);
  }

  void clearCurrentUser() {
    _currentUser = null;
    stopCurrentUserListener();
    stopAuthStateListener();
    _setCurrentUserState(UserState.initial);
    clearUserProfile();
  }

  bool get isProfileComplete {
    if (_currentUser == null) return false;
    return _currentUser!.hasPhoto && _currentUser!.hasBio;
  }

  void _setCurrentUserState(UserState newState) {
    _currentUserState = newState;
    if (newState != UserState.error) {
      _currentUserError = null;
    }
    notifyListeners();
  }

  void _setCurrentUserError(String message) {
    _currentUserError = message;
    _setCurrentUserState(UserState.error);
  }

  void _setOperationState(UserState newState) {
    _operationState = newState;
    if (newState != UserState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(UserState.error);
  }

  void _setUserProfileState(UserState newState) {
    _userProfileState = newState;

    if (newState != UserState.error) {
      _userProfileError = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setUserProfileError(String message) {
    _userProfileError = message;
    _setUserProfileState(UserState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (UserNotFoundFailure):
        return 'Usuario no encontrado';
      case const (UserUpdateFailedFailure):
        return 'Error al actualizar perfil';
      case const (ProfileImageUploadFailure):
        return 'Error al subir imagen';
      case const (ServerFailure):
        return ErrorMessages.serverError;
      default:
        return 'Error inesperado';
    }
  }

  void clearCurrentUserError() {
    _currentUserError = null;
    notifyListeners();
  }

  void clearOperationError() {
    _operationError = null;
    notifyListeners();
  }

  void clearUserProfileError() {
    _userProfileError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopCurrentUserListener();
    stopAuthStateListener();
    super.dispose();
  }
}
