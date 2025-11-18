import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/authentication_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/user_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/email_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/phone_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/storage_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/authentication_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/user_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/email_authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/phone_authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user_usecases.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /* External */
  // Internet Connection Checker
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  // Firebase instances
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  /* Core */
  // Network
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl<InternetConnection>()),
  );

  /* Data Sources */
  // Firebase Authentication
  sl.registerLazySingleton<FirebaseEmailAuthenticationService>(
    () => FirebaseEmailAuthenticationService(),
  );

  // Firebase Phone Authentication
  sl.registerLazySingleton<FirebasePhoneAuthenticationService>(
    () => FirebasePhoneAuthenticationService(),
  );

  // Firebase Storage Service
  sl.registerLazySingleton<FirebaseStorageService>(
    () => FirebaseStorageService(storage: sl<FirebaseStorage>()),
  );

  // Firebase Users Service
  sl.registerLazySingleton<FirebaseUserService>(
    () => FirebaseUserService(
      firestore: sl<FirebaseFirestore>(),
      storageService: sl<FirebaseStorageService>(),
    ),
  );

  /* Repositories */
  // Authentication Repository
  // User Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      firebaseUserService: sl<FirebaseUserService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Authentication Repository
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      firebaseEmailAuthentication: sl<FirebaseEmailAuthenticationService>(),
      firebasePhoneAuthentication: sl<FirebasePhoneAuthenticationService>(),
      firebaseUserService: sl<FirebaseUserService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  /* Use Cases */
  // Authentication Use Cases
  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SendEmailVerificationUseCase>(
    () => SendEmailVerificationUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<CheckEmailVerificationUseCase>(
    () => CheckEmailVerificationUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthenticationRepository>()),
  );

  // Phone Authentication Use Cases
  sl.registerLazySingleton<SendPhoneVerificationCodeUseCase>(
    () => SendPhoneVerificationCodeUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<VerifyPhoneCodeUseCase>(
    () => VerifyPhoneCodeUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<CompleteUserRegistrationUseCase>(
    () => CompleteUserRegistrationUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<ResendPhoneVerificationCodeUseCase>(
    () => ResendPhoneVerificationCodeUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<IsRegistrationCompleteUseCase>(
    () => IsRegistrationCompleteUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<LinkEmailPasswordToPhoneAccountUseCase>(
    () =>
        LinkEmailPasswordToPhoneAccountUseCase(sl<AuthenticationRepository>()),
  );

  // User Use Cases
  sl.registerLazySingleton<GetUserByIdUseCase>(
    () => GetUserByIdUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserStreamUseCase>(
    () => GetCurrentUserStreamUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<CreateUserUseCase>(
    () => CreateUserUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateUserUseCase>(
    () => UpdateUserUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<DeleteUserUseCase>(
    () => DeleteUserUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UploadProfileImageUseCase>(
    () => UploadProfileImageUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileImageUseCase>(
    () => UpdateProfileImageUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateNotificationSettingsUseCase>(
    () => UpdateNotificationSettingsUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<MarkUserAsVerifiedUseCase>(
    () => MarkUserAsVerifiedUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<CheckUserExistsUseCase>(
    () => CheckUserExistsUseCase(sl<UserRepository>()),
  );
}
