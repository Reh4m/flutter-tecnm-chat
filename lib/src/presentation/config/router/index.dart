import 'package:flutter_whatsapp_clon/src/presentation/config/router/auth_guard.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/auth/email_verification_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/auth/phone_sign_in_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/auth/phone_verification_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/auth/user_registration_screen.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/onboarding/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/home_screen.dart';
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
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
}
