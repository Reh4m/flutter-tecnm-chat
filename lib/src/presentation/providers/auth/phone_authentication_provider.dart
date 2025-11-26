import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_auth_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_verification_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/phone_authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user_usecases.dart';

enum PhoneAuthState {
  initial,
  loading,
  codeSent,
  phoneVerified,
  registrationComplete,
  error,
}

class PhoneAuthenticationProvider extends ChangeNotifier {
  final SendPhoneVerificationCodeUseCase _sendPhoneCodeUseCase =
      sl<SendPhoneVerificationCodeUseCase>();
  final VerifyPhoneCodeUseCase _verifyPhoneCodeUseCase =
      sl<VerifyPhoneCodeUseCase>();
  final ResendPhoneVerificationCodeUseCase _resendCodeUseCase =
      sl<ResendPhoneVerificationCodeUseCase>();
  final IsRegistrationCompleteUseCase _isRegistrationCompleteUseCase =
      sl<IsRegistrationCompleteUseCase>();
  final LinkEmailCredentialsAndVerifyUseCase
  _linkEmailCredentialsAndVerifyUseCase =
      sl<LinkEmailCredentialsAndVerifyUseCase>();
  final UploadProfileImageUseCase _uploadProfileImageUseCase =
      sl<UploadProfileImageUseCase>();

  PhoneAuthState _state = PhoneAuthState.initial;
  String? _errorMessage;
  String? _verificationId;
  String? _phoneNumber;
  int? _resendToken;
  User? _currentUser;
  bool _needsRegistration = false;

  PhoneAuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get verificationId => _verificationId;
  String? get phoneNumber => _phoneNumber;
  User? get currentUser => _currentUser;
  bool get needsRegistration => _needsRegistration;

  Future<void> sendVerificationCode(String phoneNumber) async {
    _setState(PhoneAuthState.loading);
    _phoneNumber = phoneNumber;

    final result = await _sendPhoneCodeUseCase(
      PhoneAuthEntity(phoneNumber: phoneNumber),
    );

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      verificationId,
    ) {
      _verificationId = verificationId;
      _setState(PhoneAuthState.codeSent);
    });
  }

  Future<void> verifyCode(String code) async {
    if (_verificationId == null) {
      _setError(ErrorMessages.missingVerificationId);
      return;
    }

    _setState(PhoneAuthState.loading);

    final result = await _verifyPhoneCodeUseCase(
      PhoneVerificationEntity(
        verificationId: _verificationId!,
        verificationCode: code,
      ),
    );

    await result.fold(
      (failure) async => _setError(_mapFailureToMessage(failure)),
      (userCredential) async {
        _currentUser = userCredential.user;

        final isCompleteResult = await _isRegistrationCompleteUseCase();

        isCompleteResult.fold(
          (failure) => _setError(_mapFailureToMessage(failure)),
          (isComplete) {
            _needsRegistration = !isComplete;
            _setState(PhoneAuthState.phoneVerified);
          },
        );
      },
    );
  }

  Future<void> resendCode() async {
    if (_phoneNumber == null) {
      _setError('Error al reenviar código');
      return;
    }

    _setState(PhoneAuthState.loading);

    final result = await _resendCodeUseCase(
      PhoneAuthEntity(phoneNumber: _phoneNumber!),
      _resendToken,
    );

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      verificationId,
    ) {
      _verificationId = verificationId;
      _setState(PhoneAuthState.codeSent);
    });
  }

  Future<void> completeRegistration({
    required UserSignUpEntity userRegistrationData,
    File? profileImageFile,
  }) async {
    _setState(PhoneAuthState.loading);

    String? imageUrl;

    if (_currentUser == null) {
      _setError('Usuario no autenticado');
      return;
    }

    if (profileImageFile != null) {
      final uploadResult = await _uploadProfileImageUseCase(
        profileImageFile,
        _currentUser!.uid,
      );

      final imageUploadSuccess = await uploadResult.fold(
        (failure) {
          _setError(_mapFailureToMessage(failure));
          return false;
        },
        (url) {
          imageUrl = url;
          return true;
        },
      );

      if (!imageUploadSuccess) return;
    }

    final result = await _linkEmailCredentialsAndVerifyUseCase(
      UserSignUpEntity(
        name: userRegistrationData.name,
        email: userRegistrationData.email,
        photoUrl: imageUrl,
        password: userRegistrationData.password,
        confirmPassword: userRegistrationData.confirmPassword,
      ),
    );

    return result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      _,
    ) {
      _needsRegistration = false;
      _setState(PhoneAuthState.registrationComplete);
    });
  }

  void _setState(PhoneAuthState newState) {
    _state = newState;
    if (newState != PhoneAuthState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(PhoneAuthState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (InvalidPhoneNumberFailure):
        return ErrorMessages.invalidPhoneNumber;
      case const (TooManySMSRequestsFailure):
        return ErrorMessages.tooManySMSRequests;
      case const (SMSQuotaExceededFailure):
        return ErrorMessages.smsQuotaExceeded;
      case const (InvalidVerificationCodeFailure):
        return ErrorMessages.invalidVerificationCode;
      case const (VerificationExpiredFailure):
        return ErrorMessages.verificationExpired;
      case const (PhoneAlreadyInUseFailure):
        return ErrorMessages.phoneAlreadyInUse;
      case const (MissingVerificationIdFailure):
        return ErrorMessages.missingVerificationId;
      case const (ExistingEmailFailure):
        return ErrorMessages.emailInUse;
      case const (WeakPasswordFailure):
        return ErrorMessages.weakPassword;
      case const (PasswordMismatchFailure):
        return ErrorMessages.passwordMismatch;
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

  void reset() {
    _state = PhoneAuthState.initial;
    _errorMessage = null;
    _verificationId = null;
    _resendToken = null;
    _phoneNumber = null;
    notifyListeners();
  }
}
