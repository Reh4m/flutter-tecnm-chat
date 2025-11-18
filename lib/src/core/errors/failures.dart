import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

class NetworkFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UserNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class WrongPasswordFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class WeakPasswordFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ExistingEmailFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class TooManyRequestsFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class PasswordMismatchFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class NotLoggedInFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class EmailVerificationFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// User Failures
class UserAlreadyExistsFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidUserDataFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UnauthorizedUserOperationFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UserUpdateFailedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ProfileImageUploadFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidPhoneNumberFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// Phone Auth Failures
class PhoneAlreadyInUseFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidVerificationCodeFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class TooManySMSRequestsFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class SMSQuotaExceededFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class VerificationExpiredFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class IncompleteRegistrationFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class MissingVerificationIdFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class PhoneAuthNotEnabledFailure extends Failure {
  @override
  List<Object?> get props => [];
}
