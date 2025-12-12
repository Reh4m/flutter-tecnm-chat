class ServerException implements Exception {}

class NetworkException implements Exception {}

class UserNotFoundException implements Exception {}

class WrongPasswordException implements Exception {}

class WeakPasswordException implements Exception {}

class ExistingEmailException implements Exception {}

class TooManyRequestsException implements Exception {}

// User Exceptions
class UserAlreadyExistsException implements Exception {}

class InvalidUserDataException implements Exception {}

class UnauthorizedUserOperationException implements Exception {}

class UserUpdateFailedException implements Exception {}

class ProfileImageUploadException implements Exception {}

class InvalidPhoneNumberException implements Exception {}

// Phone Auth Exceptions
class PhoneAlreadyInUseException implements Exception {}

class InvalidVerificationCodeException implements Exception {}

class TooManySMSRequestsException implements Exception {}

class SMSQuotaExceededException implements Exception {}

class VerificationExpiredException implements Exception {}

class IncompleteRegistrationException implements Exception {}

class MissingVerificationIdException implements Exception {}

class PhoneAuthNotEnabledException implements Exception {}

// Contact Exceptions
class ContactAlreadyExistsException implements Exception {}

class ContactNotFoundException implements Exception {}

class CannotAddSelfAsContactException implements Exception {}

class ContactOperationFailedException implements Exception {}

// Conversation Exceptions
class ConversationNotFoundException implements Exception {}

class ConversationAlreadyExistsException implements Exception {}

class MessageNotFoundException implements Exception {}

class InvalidConversationDataException implements Exception {}

class ConversationOperationFailedException implements Exception {}

class MessageSendFailedException implements Exception {}

// Media Exceptions
class MediaUploadException implements Exception {}

class InvalidMediaException implements Exception {}

class MediaTooLargeException implements Exception {}

class UnsupportedMediaTypeException implements Exception {}

class ThumbnailGenerationException implements Exception {}

// Group Exceptions
class GroupNotFoundException implements Exception {}

class GroupAlreadyExistsException implements Exception {}

class NotGroupAdminException implements Exception {}

class NotGroupMemberException implements Exception {}

class GroupOperationFailedException implements Exception {}

class MaxGroupMembersExceededException implements Exception {}

class CannotRemoveGroupCreatorException implements Exception {}

// Call Exceptions
class CallNotFoundException implements Exception {}

class CallAlreadyActiveException implements Exception {}

class CallConnectionFailedException implements Exception {}

class MediaPermissionDeniedException implements Exception {}

class WebRTCNotInitializedException implements Exception {}

class CallOperationFailedException implements Exception {}

class InvalidCallStateException implements Exception {}
