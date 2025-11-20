import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/email_authentication_usecases.dart';

enum EmailVerificationState { initial, loading, checking, verified, error }

class EmailVerificationProvider extends ChangeNotifier {
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase =
      sl<SendEmailVerificationUseCase>();
  final CheckEmailVerificationUseCase _checkEmailVerificationUseCase =
      sl<CheckEmailVerificationUseCase>();
  final SaveUserDataToFirestoreUseCase _saveUserDataToFirestoreUseCase =
      sl<SaveUserDataToFirestoreUseCase>();

  EmailVerificationState _state = EmailVerificationState.initial;
  String? _errorMessage;

  EmailVerificationState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> sendEmailVerification() async {
    _setState(EmailVerificationState.loading);

    final result = await _sendEmailVerificationUseCase();

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (_) => _setState(EmailVerificationState.initial),
    );
  }

  Future<bool> checkEmailVerification() async {
    _setState(EmailVerificationState.checking);

    final result = await _checkEmailVerificationUseCase();

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (isVerified) {
        if (isVerified) {
          _setState(EmailVerificationState.verified);
        } else {
          _setState(EmailVerificationState.initial);
        }
        return isVerified;
      },
    );
  }

  Future<bool> createUserAfterEmailVerification() async {
    _setState(EmailVerificationState.loading);

    final result = await _saveUserDataToFirestoreUseCase();

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setState(EmailVerificationState.verified);
        return true;
      },
    );
  }

  void _setState(EmailVerificationState newState) {
    _state = newState;
    if (newState != EmailVerificationState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(EmailVerificationState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (UserNotFoundFailure):
        return ErrorMessages.userNotFound;
      case const (TooManyRequestsFailure):
        return ErrorMessages.tooManyRequests;
      case const (EmailVerificationFailure):
        return ErrorMessages.emailNotVerified;
      default:
        return ErrorMessages.serverError;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
