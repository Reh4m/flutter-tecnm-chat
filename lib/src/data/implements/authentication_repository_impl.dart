import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/password_reset_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/phone_auth_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/phone_verification_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/auth/user_sign_up_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/user_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/email_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/phone_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/password_reset_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_auth_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/phone_verification_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/authentication_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FirebaseAuthenticationService firebaseAuthentication;
  final FirebaseEmailAuthenticationService firebaseEmailAuthentication;
  final FirebasePhoneAuthenticationService firebasePhoneAuthentication;
  final FirebaseUserService firebaseUserService;
  final NetworkInfo networkInfo;

  AuthenticationRepositoryImpl({
    required this.firebaseAuthentication,
    required this.firebaseEmailAuthentication,
    required this.firebasePhoneAuthentication,
    required this.firebaseUserService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserCredential>> signUpWithEmailAndPassword(
    UserSignUpEntity signUpData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    if (signUpData.password != signUpData.confirmPassword) {
      return Left(PasswordMismatchFailure());
    }

    try {
      final userCredential = await firebaseEmailAuthentication
          .signUpWithEmailAndPassword(
            UserSignUpModel(
              name: signUpData.name,
              email: signUpData.email,
              password: signUpData.password,
              confirmPassword: signUpData.confirmPassword,
            ),
          );

      final currentUser = userCredential.user;

      await firebaseUserService.createUser(
        UserModel(
          id: currentUser!.uid,
          name: signUpData.name,
          email: signUpData.email,
          createdAt: DateTime.now(),
          isVerified: currentUser.emailVerified,
        ),
      );

      await firebaseEmailAuthentication.sendEmailVerification();

      return Right(userCredential);
    } on WeakPasswordException {
      return Left(WeakPasswordFailure());
    } on ExistingEmailException {
      return Left(ExistingEmailFailure());
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await firebaseEmailAuthentication.sendEmailVerification();

      return const Right(unit);
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailVerification() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return Left(UserNotFoundFailure());
      }

      await user.reload();

      final isVerified = user.emailVerified;

      if (isVerified) {
        await firebaseUserService.markUserAsVerified(user.uid);
      }

      return Right(isVerified);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> sendPhoneVerificationCode(
    PhoneAuthEntity phoneAuthData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final phoneAuthModel = PhoneAuthModel(
        phoneNumber: phoneAuthData.phoneNumber,
      );

      final verificationId = await firebasePhoneAuthentication
          .sendVerificationCode(phoneAuthModel);

      return Right(verificationId);
    } on InvalidPhoneNumberException {
      return Left(InvalidPhoneNumberFailure());
    } on TooManySMSRequestsException {
      return Left(TooManySMSRequestsFailure());
    } on SMSQuotaExceededException {
      return Left(SMSQuotaExceededFailure());
    } on PhoneAuthNotEnabledException {
      return Left(PhoneAuthNotEnabledFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserCredential>> verifyPhoneCode(
    PhoneVerificationEntity verificationData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final verificationModel = PhoneVerificationModel(
        verificationId: verificationData.verificationId,
        verificationCode: verificationData.verificationCode,
      );

      final userCredential = await firebasePhoneAuthentication.verifyOTPCode(
        verificationModel,
      );

      return Right(userCredential);
    } on InvalidVerificationCodeException {
      return Left(InvalidVerificationCodeFailure());
    } on MissingVerificationIdException {
      return Left(MissingVerificationIdFailure());
    } on VerificationExpiredException {
      return Left(VerificationExpiredFailure());
    } on PhoneAlreadyInUseException {
      return Left(PhoneAlreadyInUseFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> completeUserRegistration(
    UserSignUpEntity registrationData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return Left(UserNotFoundFailure());
      }

      if (registrationData.password != registrationData.confirmPassword) {
        return Left(PasswordMismatchFailure());
      }

      // 1. Vincular cuenta de correo electrónico y contraseña
      final linkResult = await linkEmailPasswordToPhoneAccount(
        email: registrationData.email,
        password: registrationData.password,
      );

      return await linkResult.fold((failure) async => Left(failure), (
        userCredential,
      ) async {
        try {
          // 2. Actualizar perfil en Firebase Auth
          await firebaseAuthentication.updateUserProfile(
            displayName: registrationData.name,
          );

          // 3. Enviar verificación de correo electrónico
          await firebaseEmailAuthentication.sendEmailVerification();

          return const Right(unit);
        } on TooManyRequestsException {
          return Left(TooManyRequestsFailure());
        } on ServerException {
          return Left(ServerFailure());
        } catch (e) {
          return Left(ServerFailure());
        }
      });
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on InvalidUserDataException {
      return Left(InvalidUserDataFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> createUserAfterEmailVerification() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return Left(UserNotFoundFailure());
      }

      // Verificar que el email esté realmente verificado
      await currentUser.reload();

      if (!currentUser.emailVerified) {
        return Left(EmailVerificationFailure());
      }

      // Verificar si el usuario ya existe en Firestore
      final userExists = await firebaseUserService.checkUserExists(
        currentUser.uid,
      );

      if (userExists) {
        // Si ya existe, actualizar sus datos y marcar como verificado
        final existingUser = await firebaseUserService.getUserById(
          currentUser.uid,
        );

        final updatedUser = existingUser.copyWith(
          name: currentUser.displayName ?? existingUser.name,
          email: currentUser.email ?? existingUser.email,
          phoneNumber: currentUser.phoneNumber,
          isVerified: true,
          updatedAt: DateTime.now(),
        );

        await firebaseUserService.updateUser(updatedUser);
      } else {
        // Si no existe, crear nuevo usuario en Firestore
        await firebaseUserService.createUser(
          UserModel(
            id: currentUser.uid,
            name: currentUser.displayName ?? '',
            email: currentUser.email ?? '',
            phoneNumber: currentUser.phoneNumber,
            createdAt: DateTime.now(),
            isVerified: true,
          ),
        );
      }

      return const Right(unit);
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on InvalidUserDataException {
      return Left(InvalidUserDataFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> resendPhoneVerificationCode(
    PhoneAuthEntity phoneAuthData,
    int? resendToken,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final phoneAuthModel = PhoneAuthModel(
        phoneNumber: phoneAuthData.phoneNumber,
      );

      final verificationId = await firebasePhoneAuthentication
          .resendVerificationCode(phoneAuthModel, resendToken);

      return Right(verificationId);
    } on InvalidPhoneNumberException {
      return Left(InvalidPhoneNumberFailure());
    } on TooManySMSRequestsException {
      return Left(TooManySMSRequestsFailure());
    } on SMSQuotaExceededException {
      return Left(SMSQuotaExceededFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isRegistrationComplete() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return const Right(false);
      }

      await currentUser.reload();

      // Verificar que tenga los proveedores necesarios
      final hasPhoneProvider = currentUser.providerData.any(
        (provider) => provider.providerId == 'phone',
      );
      final hasEmailProvider = currentUser.providerData.any(
        (provider) => provider.providerId == 'password',
      );

      final isEmailVerified = currentUser.emailVerified;

      final hasName =
          currentUser.displayName != null &&
          currentUser.displayName!.isNotEmpty;
      final hasEmail =
          currentUser.email != null && currentUser.email!.isNotEmpty;

      // Si no tiene todos los datos necesarios en Auth, no está completo
      if (!hasPhoneProvider ||
          !hasEmailProvider ||
          !isEmailVerified ||
          !hasName ||
          !hasEmail) {
        return const Right(false);
      }

      final userExists = await firebaseUserService.checkUserExists(
        currentUser.uid,
      );

      if (!userExists) {
        return const Right(false);
      }

      // Verificar que los datos en Firestore estén completos
      final user = await firebaseUserService.getUserById(currentUser.uid);

      final hasCompleteData =
          user.name.isNotEmpty && user.email.isNotEmpty && user.isVerified;

      return Right(hasCompleteData);
    } on UserNotFoundException {
      return const Right(false);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserCredential>> linkEmailPasswordToPhoneAccount({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final userCredential = await firebaseAuthentication.linkEmailPassword(
        email: email,
        password: password,
      );

      return Right(userCredential);
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on ExistingEmailException {
      return Left(ExistingEmailFailure());
    } on WeakPasswordException {
      return Left(WeakPasswordFailure());
    } on InvalidUserDataException {
      return Left(InvalidUserDataFailure());
    } on UserAlreadyExistsException {
      return Left(UserAlreadyExistsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(
    PasswordResetEntity passwordResetData,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final passwordResetModel = PasswordResetModel(
        email: passwordResetData.email,
      );
      await firebaseEmailAuthentication.resetPassword(passwordResetModel);
      return const Right(unit);
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await FirebaseAuth.instance.signOut();

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
