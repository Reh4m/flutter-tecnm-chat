import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_in_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user_auth_usecases.dart';

enum AuthState { initial, loading, success, error }

class AuthenticationProvider extends ChangeNotifier {
  final SignInUseCase _signInUseCase = sl<SignInUseCase>();
  final SignUpUseCase _signUpUseCase = sl<SignUpUseCase>();
  final SignOutUseCase _signOutUseCase = sl<SignOutUseCase>();
  final CreateOrUpdateUserFromAuthUseCase _createOrUpdateUserFromAuthUseCase =
      sl<CreateOrUpdateUserFromAuthUseCase>();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  User? _currentUser;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> signIn(String email, String password) async {
    _setState(AuthState.loading);

    final result = await _signInUseCase(
      SignInEntity(email: email, password: password),
    );

    await result.fold(
      (failure) async => _setError(_mapFailureToMessage(failure)),
      (userCredential) async {
        _currentUser = userCredential.user;

        // Crear documento de usuario en Firestore
        if (_currentUser != null) {
          await _createOrUpdateUserDocument(_currentUser!);
        }

        _setState(AuthState.success);
      },
    );
  }

  Future<void> signUp(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    _setState(AuthState.loading);

    final result = await _signUpUseCase(
      SignUpEntity(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );

    await result.fold(
      (failure) async => _setError(_mapFailureToMessage(failure)),
      (userCredential) async {
        _currentUser = userCredential.user;

        // Crear documento de usuario en Firestore
        if (_currentUser != null) {
          await _createOrUpdateUserDocument(_currentUser!);
        }

        _setState(AuthState.success);
      },
    );
  }

  Future<void> signOut() async {
    _setState(AuthState.loading);

    final result = await _signOutUseCase();

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (_) {
      _currentUser = null;
      _setState(AuthState.initial);
    });
  }

  Future<void> _createOrUpdateUserDocument(User firebaseUser) async {
    try {
      final result = await _createOrUpdateUserFromAuthUseCase(firebaseUser);

      result.fold(
        (failure) {
          debugPrint(
            'Error al crear/actualizar documento de usuario: $failure',
          );
        },
        (userEntity) {
          debugPrint(
            'Documento de usuario creado/actualizado: ${userEntity.id}',
          );
        },
      );
    } catch (e) {
      debugPrint('Error inesperado al crear documento de usuario: $e');
    }
  }

  Future<void> syncCurrentUserWithFirestore() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await _createOrUpdateUserDocument(firebaseUser);
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (UserNotFoundFailure):
        return ErrorMessages.userNotFound;
      case const (WrongPasswordFailure):
        return ErrorMessages.wrongPassword;
      case const (WeakPasswordFailure):
        return ErrorMessages.weakPassword;
      case const (ExistingEmailFailure):
        return ErrorMessages.emailInUse;
      case const (TooManyRequestsFailure):
        return ErrorMessages.tooManyRequests;
      case const (PasswordMismatchFailure):
        return ErrorMessages.passwordMismatch;
      default:
        return ErrorMessages.serverError;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
