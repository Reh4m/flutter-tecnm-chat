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

// Contact Failures
class ContactAlreadyExistsFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ContactNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class CannotAddSelfAsContactFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ContactOperationFailedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// Conversation Failures
class ConversationNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ConversationAlreadyExistsFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class MessageNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidConversationDataFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ConversationOperationFailedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class MessageSendFailedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// Media Failures
class MediaUploadFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidMediaFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class MediaTooLargeFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UnsupportedMediaTypeFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ThumbnailGenerationFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// Group Failures
class GroupNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class GroupAlreadyExistsFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class NotGroupAdminFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class NotGroupMemberFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class GroupOperationFailedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class MaxGroupMembersExceededFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class CannotRemoveGroupCreatorFailure extends Failure {
  @override
  List<Object?> get props => [];
}
