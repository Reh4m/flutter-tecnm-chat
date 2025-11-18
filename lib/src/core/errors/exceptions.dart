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
