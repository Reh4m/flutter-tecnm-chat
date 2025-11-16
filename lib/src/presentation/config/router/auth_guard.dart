import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/onboarding_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

FutureOr<String?> authGuard(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  final onboardingProvider = context.read<OnboardingProvider>();

  final isAuthenticated = user != null;
  final isEmailVerified = user?.emailVerified ?? false;
  final hasSeenOnboarding = onboardingProvider.hasSeenOnboarding;

  final publicRoutes = [
    '/onboarding',
    '/login',
    '/register',
    '/forgot-password',
  ];
  final isPublicRoute = publicRoutes.contains(state.uri.path);

  if (!hasSeenOnboarding && state.uri.path != '/onboarding') {
    return '/onboarding';
  }

  if (!isAuthenticated && !isPublicRoute) {
    return '/login';
  }

  if (isAuthenticated &&
      !isEmailVerified &&
      state.uri.path != '/email-verification') {
    return '/email-verification';
  }

  if (isAuthenticated && isEmailVerified && isPublicRoute) {
    return '/home';
  }

  return null;
}
