import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/user_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/auth/authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/auth/email_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/auth/authentication_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FirebaseAuthenticationService firebaseAuthentication;
  final FirebaseEmailAuthenticationService firebaseEmailAuthentication;
  final FirebaseUserService firebaseUserService;
  final NetworkInfo networkInfo;

  AuthenticationRepositoryImpl({
    required this.firebaseAuthentication,
    required this.firebaseEmailAuthentication,
    required this.firebaseUserService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Unit>> linkEmailCredentialsAndVerify(
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
      await firebaseEmailAuthentication.linkEmailPassword(
        email: registrationData.email,
        password: registrationData.password,
      );

      // 2. Actualizar perfil en Firebase Auth
      await firebaseUserService.updateUserProfile(
        displayName: registrationData.name,
        photoUrl: registrationData.photoUrl,
      );

      // 3. Enviar verificación de correo electrónico
      await firebaseEmailAuthentication.sendEmailVerification();

      return const Right(unit);
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
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveUserDataToFirestore() async {
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
          photoUrl: currentUser.photoURL,
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
            photoUrl: currentUser.photoURL,
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
