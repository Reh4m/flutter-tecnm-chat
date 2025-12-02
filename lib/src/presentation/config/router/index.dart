// lib/src/presentation/config/router/index.dart
import 'package:flutter_whatsapp_clon/src/presentation/config/router/auth_guard.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/auth/email_verification_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/auth/phone_sign_in_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/auth/phone_verification_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/auth/user_registration_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/add_group_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/chat_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/edit_group_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/group_chat_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/group_details_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/contacts/add_contact_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/contacts/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/onboarding/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/profile/edit_profile_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/profile/index.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    redirect: authGuard,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/phone-sign-in',
        builder: (context, state) => const PhoneSignInScreen(),
      ),
      GoRoute(
        path: '/phone-verification',
        builder: (context, state) => const PhoneVerificationScreen(),
      ),
      GoRoute(
        path: '/user-registration',
        builder: (context, state) => const UserRegistrationScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ConversationsListScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsScreen(),
      ),
      GoRoute(
        path: '/add-contact',
        builder: (context, state) => const AddContactScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ChatScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: '/group-chat/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupChatScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/group-details/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupDetailsScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/create-group',
        builder: (context, state) => const AddGroupScreen(),
      ),
      GoRoute(
        path: '/edit-group',
        builder: (context, state) => const EditGroupScreen(),
      ),
    ],
  );
}
