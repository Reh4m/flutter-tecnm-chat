import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/auth/authentication_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/conversations/call_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/conversations/notification_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/user/contact_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/conversations/direct_chat_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/auth/email_auth_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/conversations/group_chat_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/media_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/conversations/message_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/auth/phone_auth_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/implements/user/user_repository_impl.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/auth/authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/call_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/notification_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/storage/chat_media_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user/contact_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/direct_chat_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/auth/email_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/group_chat_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/message_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/auth/phone_authentication_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/storage/storage_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user/user_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/webrtc/webrtc_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/auth/authentication_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/call_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/notification_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/user/contact_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/direct_chat_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/auth/email_authentication_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/group_chat_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/media_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/message_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/auth/phone_authentication_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/user/user_repository.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/auth/authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/call_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/notification_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user/contact_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/direct_chat_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/auth/email_authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/group_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/media_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/message_use_cases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/auth/phone_authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user/user_usecases.dart';
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
  sl.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  // Flutter Local Notifications
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  /* Core */
  // Network
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl<InternetConnection>()),
  );

  /* Data Sources */
  // WebRTC
  sl.registerLazySingleton<WebRTCService>(
    () => WebRTCService(firebaseDatabase: sl<FirebaseDatabase>()),
  );

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

  // Firebase Group Chat Service
  sl.registerLazySingleton<FirebaseGroupChatService>(
    () => FirebaseGroupChatService(
      firestore: sl<FirebaseFirestore>(),
      storageService: sl<FirebaseStorageService>(),
    ),
  );

  // Firebase Message Service
  sl.registerLazySingleton<FirebaseMessageService>(
    () => FirebaseMessageService(firestore: sl<FirebaseFirestore>()),
  );

  // Firebase Call Service
  sl.registerLazySingleton<FirebaseCallService>(
    () => FirebaseCallService(firestore: sl<FirebaseFirestore>()),
  );

  // Firebase Notification Service
  sl.registerLazySingleton<FirebaseNotificationService>(
    () => FirebaseNotificationService(
      firebaseMessaging: sl<FirebaseMessaging>(),
      firestore: sl<FirebaseFirestore>(),
      localNotifications: sl<FlutterLocalNotificationsPlugin>(),
    ),
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
      firebaseAuth: sl<FirebaseAuth>(),
      firebaseAuthentication: sl<FirebaseAuthenticationService>(),
      firebaseEmailAuthentication: sl<FirebaseEmailAuthenticationService>(),
      firebaseUserService: sl<FirebaseUserService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Email Authentication Repository
  sl.registerLazySingleton<EmailAuthenticationRepository>(
    () => EmailAuthRepositoryImpl(
      firebaseAuth: sl<FirebaseAuth>(),
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
      directChatService: sl<FirebaseDirectChatService>(),
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

  // Group Chat Repository
  sl.registerLazySingleton<GroupChatRepository>(
    () => GroupChatRepositoryImpl(
      groupService: sl<FirebaseGroupChatService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Message Repository
  sl.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(
      messageService: sl<FirebaseMessageService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Message Repository
  sl.registerLazySingleton<CallRepository>(
    () => CallRepositoryImpl(
      webrtcService: sl<WebRTCService>(),
      callService: sl<FirebaseCallService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Notification Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      notificationService: sl<FirebaseNotificationService>(),
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
  sl.registerLazySingleton<UploadUserProfileImageUseCase>(
    () => UploadUserProfileImageUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateUserProfileImageUseCase>(
    () => UpdateUserProfileImageUseCase(sl<UserRepository>()),
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
  sl.registerLazySingleton<CreateDirectChatUseCase>(
    () => CreateDirectChatUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<GetOrCreateDirectChatUseCase>(
    () => GetOrCreateDirectChatUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<GetUserDirectChatsStreamUseCase>(
    () => GetUserDirectChatsStreamUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<GetDirectChatByIdUseCase>(
    () => GetDirectChatByIdUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<UpdateDirectChatUseCase>(
    () => UpdateDirectChatUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<DeleteDirectChatUseCase>(
    () => DeleteDirectChatUseCase(sl<DirectChatRepository>()),
  );
  sl.registerLazySingleton<UpdateDirectChatLastMessageUseCase>(
    () => UpdateDirectChatLastMessageUseCase(sl<DirectChatRepository>()),
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

  // Group Chat Use Cases
  sl.registerLazySingleton<CreateGroupUseCase>(
    () => CreateGroupUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<GetGroupByIdUseCase>(
    () => GetGroupByIdUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<GetUserGroupsStreamUseCase>(
    () => GetUserGroupsStreamUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<GetUserGroupsUseCase>(
    () => GetUserGroupsUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<UpdateGroupUseCase>(
    () => UpdateGroupUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<DeleteGroupUseCase>(
    () => DeleteGroupUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<AddGroupMemberUseCase>(
    () => AddGroupMemberUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<RemoveGroupMemberUseCase>(
    () => RemoveGroupMemberUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<UploadGroupProfileImageUseCase>(
    () => UploadGroupProfileImageUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<UpdateGroupProfileImageUseCase>(
    () => UpdateGroupProfileImageUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<AddGroupAdminUseCase>(
    () => AddGroupAdminUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<RemoveGroupAdminUseCase>(
    () => RemoveGroupAdminUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<UpdateGroupPrivacyUseCase>(
    () => UpdateGroupPrivacyUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<UpdateGroupInfoUseCase>(
    () => UpdateGroupInfoUseCase(sl<GroupChatRepository>()),
  );
  sl.registerLazySingleton<UpdateGroupChatLastMessageUseCase>(
    () => UpdateGroupChatLastMessageUseCase(sl<GroupChatRepository>()),
  );

  // Message Use Cases
  sl.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(sl<MessageRepository>()),
  );
  sl.registerLazySingleton<UpdateMessageStatusUseCase>(
    () => UpdateMessageStatusUseCase(sl<MessageRepository>()),
  );
  sl.registerLazySingleton<MarkMessageAsReadUseCase>(
    () => MarkMessageAsReadUseCase(sl<MessageRepository>()),
  );
  sl.registerLazySingleton<MarkAllMessagesAsDeliveredUseCase>(
    () => MarkAllMessagesAsDeliveredUseCase(sl<MessageRepository>()),
  );
  sl.registerLazySingleton<DeleteMessageUseCase>(
    () => DeleteMessageUseCase(sl<MessageRepository>()),
  );
  sl.registerLazySingleton<MarkConversationAsReadUseCase>(
    () => MarkConversationAsReadUseCase(sl<MessageRepository>()),
  );
  sl.registerLazySingleton<GetMessageByIdUseCase>(
    () => GetMessageByIdUseCase(sl<MessageRepository>()),
  );
  sl.registerLazySingleton<GetConversationMessagesUseCase>(
    () => GetConversationMessagesUseCase(sl<MessageRepository>()),
  );
  sl.registerLazySingleton<GetConversationMessagesStreamUseCase>(
    () => GetConversationMessagesStreamUseCase(sl<MessageRepository>()),
  );

  // Call usecases
  sl.registerLazySingleton<InitializePeerConnectionUseCase>(
    () => InitializePeerConnectionUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<GetUserMediaUseCase>(
    () => GetUserMediaUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<CreateCallUseCase>(
    () => CreateCallUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<CreateGroupCallUseCase>(
    () => CreateGroupCallUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<AnswerCallUseCase>(
    () => AnswerCallUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<RejectCallUseCase>(
    () => RejectCallUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<EndCallUseCase>(
    () => EndCallUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<GetRemoteStreamUseCase>(
    () => GetRemoteStreamUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<GetLocalStreamUseCase>(
    () => GetLocalStreamUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<GetCallStateStreamUseCase>(
    () => GetCallStateStreamUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<ListenForIncomingCallsUseCase>(
    () => ListenForIncomingCallsUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<ListenToCallUseCase>(
    () => ListenToCallUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<ToggleMuteUseCase>(
    () => ToggleMuteUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<ToggleVideoUseCase>(
    () => ToggleVideoUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<SwitchCameraUseCase>(
    () => SwitchCameraUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<ToggleSpeakerUseCase>(
    () => ToggleSpeakerUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<GetCallByIdUseCase>(
    () => GetCallByIdUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<GetCallHistoryUseCase>(
    () => GetCallHistoryUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<GetCallHistoryStreamUseCase>(
    () => GetCallHistoryStreamUseCase(sl<CallRepository>()),
  );

  sl.registerLazySingleton<DisposeWebRTCUseCase>(
    () => DisposeWebRTCUseCase(sl<CallRepository>()),
  );

  // Notification Use Cases
  sl.registerLazySingleton<InitializeNotificationsUseCase>(
    () => InitializeNotificationsUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<RequestNotificationPermissionUseCase>(
    () => RequestNotificationPermissionUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<GetAndSaveTokenUseCase>(
    () => GetAndSaveTokenUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<RemoveNotificationTokenUseCase>(
    () => RemoveNotificationTokenUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<GetInitialMessageUseCase>(
    () => GetInitialMessageUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<ShowLocalNotificationUseCase>(
    () => ShowLocalNotificationUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<SubscribeToGroupNotificationsUseCase>(
    () => SubscribeToGroupNotificationsUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<UnsubscribeFromGroupNotificationsUseCase>(
    () =>
        UnsubscribeFromGroupNotificationsUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<GetTokenRefreshStreamUseCase>(
    () => GetTokenRefreshStreamUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<GetForegroundMessageStreamUseCase>(
    () => GetForegroundMessageStreamUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<GetMessageOpenedAppStreamUseCase>(
    () => GetMessageOpenedAppStreamUseCase(sl<NotificationRepository>()),
  );
}
