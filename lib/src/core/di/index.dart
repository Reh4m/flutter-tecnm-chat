import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/authentication_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/contact_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/direct_chat_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/email_auth_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/group_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/media_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/phone_auth_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/user_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/chat_media_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/contact_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/direct_chat_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/email_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/group_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/phone_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/storage_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/authentication_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/contact_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/direct_chat_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/email_authentication_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/group_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/media_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/phone_authentication_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/user_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/contact_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/direct_chat_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/email_authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/group_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/media_usecases.dart';
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
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  /* Core */
  // Network
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl<InternetConnection>()),
  );

  /* Data Sources */
  // Firebase Authentication
  sl.registerLazySingleton<FirebaseAuthenticationService>(
    () => FirebaseAuthenticationService(firebaseAuth: sl<FirebaseAuth>()),
  );

  // Firebase Email Authentication
  sl.registerLazySingleton<FirebaseEmailAuthenticationService>(
    () => FirebaseEmailAuthenticationService(firebaseAuth: sl<FirebaseAuth>()),
  );

  // Firebase Phone Authentication
  sl.registerLazySingleton<FirebasePhoneAuthenticationService>(
    () => FirebasePhoneAuthenticationService(firebaseAuth: sl<FirebaseAuth>()),
  );

  // Firebase Storage Service
  sl.registerLazySingleton<FirebaseStorageService>(
    () => FirebaseStorageService(storage: sl<FirebaseStorage>()),
  );

  // Firebase Users Service
  sl.registerLazySingleton<FirebaseUserService>(
    () => FirebaseUserService(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
      storageService: sl<FirebaseStorageService>(),
    ),
  );

  // Firebase Contact Service
  sl.registerLazySingleton<FirebaseContactService>(
    () => FirebaseContactService(firestore: sl<FirebaseFirestore>()),
  );

  // Firebase Direct Chat Service
  sl.registerLazySingleton<FirebaseDirectChatService>(
    () => FirebaseDirectChatService(firestore: sl<FirebaseFirestore>()),
  );

  // Firebase Chat Media Service
  sl.registerLazySingleton<FirebaseChatMediaService>(
    () => FirebaseChatMediaService(storage: sl<FirebaseStorage>()),
  );

  // Firebase Group Service
  sl.registerLazySingleton<FirebaseGroupService>(
    () => FirebaseGroupService(firestore: sl<FirebaseFirestore>()),
  );

  /* Repositories */
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
      firebaseAuthentication: sl<FirebaseAuthenticationService>(),
      firebaseEmailAuthentication: sl<FirebaseEmailAuthenticationService>(),
      firebaseUserService: sl<FirebaseUserService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Email Authentication Repository
  sl.registerLazySingleton<EmailAuthenticationRepository>(
    () => EmailAuthRepositoryImpl(
      firebaseEmailAuthentication: sl<FirebaseEmailAuthenticationService>(),
      firebaseUserService: sl<FirebaseUserService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Phone Authentication Repository
  sl.registerLazySingleton<PhoneAuthenticationRepository>(
    () => PhoneAuthRepositoryImpl(
      firebasePhoneAuthentication: sl<FirebasePhoneAuthenticationService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Contact Repository
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(
      contactService: sl<FirebaseContactService>(),
      userService: sl<FirebaseUserService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Direct Chat Repository
  sl.registerLazySingleton<DirectChatRepository>(
    () => DirectChatRepositoryImpl(
      conversationService: sl<FirebaseDirectChatService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Media Repository
  sl.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(
      mediaService: sl<FirebaseChatMediaService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Group Repository
  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(
      groupService: sl<FirebaseGroupService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  /* Use Cases */
  // Authentication Use Cases
  sl.registerLazySingleton<LinkEmailCredentialsAndVerifyUseCase>(
    () => LinkEmailCredentialsAndVerifyUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SaveUserDataToFirestoreUseCase>(
    () => SaveUserDataToFirestoreUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<IsRegistrationCompleteUseCase>(
    () => IsRegistrationCompleteUseCase(sl<AuthenticationRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthenticationRepository>()),
  );

  // Email Authentication Use Cases
  sl.registerLazySingleton<SendEmailVerificationUseCase>(
    () => SendEmailVerificationUseCase(sl<EmailAuthenticationRepository>()),
  );
  sl.registerLazySingleton<CheckEmailVerificationUseCase>(
    () => CheckEmailVerificationUseCase(sl<EmailAuthenticationRepository>()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<EmailAuthenticationRepository>()),
  );

  // Phone Authentication Use Cases
  sl.registerLazySingleton<SendPhoneVerificationCodeUseCase>(
    () => SendPhoneVerificationCodeUseCase(sl<PhoneAuthenticationRepository>()),
  );
  sl.registerLazySingleton<VerifyPhoneCodeUseCase>(
    () => VerifyPhoneCodeUseCase(sl<PhoneAuthenticationRepository>()),
  );
  sl.registerLazySingleton<ResendPhoneVerificationCodeUseCase>(
    () =>
        ResendPhoneVerificationCodeUseCase(sl<PhoneAuthenticationRepository>()),
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

  // Contact Use Cases
  sl.registerLazySingleton<AddContactUseCase>(
    () => AddContactUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<GetUserContactsUseCase>(
    () => GetUserContactsUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<GetUserContactsStreamUseCase>(
    () => GetUserContactsStreamUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<GetContactByUserIdUseCase>(
    () => GetContactByUserIdUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<RemoveContactUseCase>(
    () => RemoveContactUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<UpdateContactUseCase>(
    () => UpdateContactUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<ToggleFavoriteContactUseCase>(
    () => ToggleFavoriteContactUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<ToggleBlockContactUseCase>(
    () => ToggleBlockContactUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<CheckContactExistsUseCase>(
    () => CheckContactExistsUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<SearchUserByPhoneNumberUseCase>(
    () => SearchUserByPhoneNumberUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<SearchUserByEmailUseCase>(
    () => SearchUserByEmailUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<GetFavoriteContactsUseCase>(
    () => GetFavoriteContactsUseCase(sl<ContactRepository>()),
  );
  sl.registerLazySingleton<GetBlockedContactsUseCase>(
    () => GetBlockedContactsUseCase(sl<ContactRepository>()),
  );

  // Direct Chat Use Cases
  sl.registerLazySingleton<CreateConversationUseCase>(
    () => CreateConversationUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<GetOrCreateDirectConversationUseCase>(
    () => GetOrCreateDirectConversationUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<GetUserConversationsStreamUseCase>(
    () => GetUserConversationsStreamUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<GetConversationByIdUseCase>(
    () => GetConversationByIdUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<UpdateConversationUseCase>(
    () => UpdateConversationUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<DeleteConversationUseCase>(
    () => DeleteConversationUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<GetConversationMessagesStreamUseCase>(
    () => GetConversationMessagesStreamUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<GetConversationMessagesUseCase>(
    () => GetConversationMessagesUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<MarkMessageAsReadUseCase>(
    () => MarkMessageAsReadUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<MarkConversationAsReadUseCase>(
    () => MarkConversationAsReadUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<DeleteMessageUseCase>(
    () => DeleteMessageUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<GetMessageByIdUseCase>(
    () => GetMessageByIdUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<UpdateMessageStatusUseCase>(
    () => UpdateMessageStatusUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<MarkAllMessagesAsDeliveredUseCase>(
    () => MarkAllMessagesAsDeliveredUseCase(sl<DirectChatRepository>()),
  );

  // Media Use Cases
  sl.registerLazySingleton<UploadChatImageUseCase>(
    () => UploadChatImageUseCase(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<UploadChatVideoUseCase>(
    () => UploadChatVideoUseCase(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<UploadChatAudioUseCase>(
    () => UploadChatAudioUseCase(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<UploadChatDocumentUseCase>(
    () => UploadChatDocumentUseCase(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<UploadVideoThumbnailUseCase>(
    () => UploadVideoThumbnailUseCase(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<DeleteMediaUseCase>(
    () => DeleteMediaUseCase(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<UploadFileWithProgressUseCase>(
    () => UploadFileWithProgressUseCase(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<ValidateImageSizeUseCase>(
    () => ValidateImageSizeUseCase(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<ValidateVideoSizeUseCase>(
    () => ValidateVideoSizeUseCase(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<ValidateAudioSizeUseCase>(
    () => ValidateAudioSizeUseCase(sl<MediaRepository>()),
  );

  // Group Use Cases
  sl.registerLazySingleton<CreateGroupUseCase>(
    () => CreateGroupUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<GetGroupByIdUseCase>(
    () => GetGroupByIdUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<GetUserGroupsStreamUseCase>(
    () => GetUserGroupsStreamUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<GetUserGroupsUseCase>(
    () => GetUserGroupsUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<UpdateGroupUseCase>(
    () => UpdateGroupUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<DeleteGroupUseCase>(
    () => DeleteGroupUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<AddGroupMemberUseCase>(
    () => AddGroupMemberUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<RemoveGroupMemberUseCase>(
    () => RemoveGroupMemberUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<AddGroupAdminUseCase>(
    () => AddGroupAdminUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<RemoveGroupAdminUseCase>(
    () => RemoveGroupAdminUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<UpdateGroupPrivacyUseCase>(
    () => UpdateGroupPrivacyUseCase(sl<GroupRepository>()),
  );
  sl.registerLazySingleton<UpdateGroupInfoUseCase>(
    () => UpdateGroupInfoUseCase(sl<GroupRepository>()),
  );
}
