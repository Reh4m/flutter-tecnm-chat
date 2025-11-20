class ErrorMessages {
  static const String networkError = 'Sin conexión a internet';
  static const String serverError = 'Error del servidor';
  static const String userNotFound = 'Usuario no encontrado';
  static const String wrongPassword = 'Contraseña incorrecta';
  static const String weakPassword = 'Contraseña muy débil';
  static const String emailInUse = 'Email ya está en uso';
  static const String tooManyRequests = 'Demasiados intentos';
  static const String passwordMismatch = 'Las contraseñas no coinciden';
  static const String emailNotVerified = 'Email no verificado';
  static const String invalidEmail = 'Email inválido';
  static const String emptyFields = 'Todos los campos son obligatorios';
  static const String invalidPhoneNumber = 'Número de teléfono inválido';
  static const String phoneAlreadyInUse = 'Este número ya está registrado';
  static const String invalidVerificationCode =
      'Código de verificación incorrecto';
  static const String tooManySMSRequests =
      'Demasiados intentos. Espera un momento e intenta de nuevo';
  static const String smsQuotaExceeded =
      'Se ha excedido el límite de mensajes. Intenta más tarde';
  static const String verificationExpired =
      'El código ha expirado. Solicita uno nuevo';
  static const String incompleteRegistration =
      'Completa tu registro con nombre y email';
  static const String missingVerificationId =
      'Error en el proceso de verificación. Inicia de nuevo';
  static const String phoneAuthNotEnabled =
      'Autenticación por teléfono no disponible';
  static const String smsNotSent =
      'No se pudo enviar el código. Verifica tu número';
  static const String emptyPhoneNumber = 'Ingresa tu número de teléfono';
  static const String emptyVerificationCode =
      'Ingresa el código de verificación';
  static const String emptyName = 'El nombre es obligatorio';
  static const String emptyEmail = 'El email es obligatorio';
  static const String phoneNumberHint =
      'Ingresa tu número con código de país: +52 123 456 7890';
  static const String verificationCodeHint =
      'Código de 6 dígitos enviado por SMS';
  // Contact Errors
  static const String contactAlreadyExists = 'Este contacto ya está agregado';
  static const String contactNotFound = 'Contacto no encontrado';
  static const String cannotAddSelfAsContact =
      'No puedes agregarte a ti mismo como contacto';
  static const String contactOperationFailed =
      'No se pudo completar la operación';
  static const String userNotFoundByPhone =
      'No se encontró ningún usuario con ese número';
  static const String userNotFoundByEmail =
      'No se encontró ningún usuario con ese correo';
}
