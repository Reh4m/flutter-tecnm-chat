import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/auth/authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/onboarding_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

FutureOr<String?> authGuard(BuildContext context, GoRouterState state) async {
  final user = FirebaseAuth.instance.currentUser;
  final onboardingProvider = context.read<OnboardingProvider>();
  final hasSeenOnboarding = onboardingProvider.hasSeenOnboarding;

  final publicRoutes = [
    '/onboarding',
    '/phone-sign-in',
    '/phone-verification',
    '/user-registration',
    '/email-verification',
  ];
  final isPublicRoute = publicRoutes.contains(state.uri.path);

  // 1. Si no ha visto onboarding
  if (!hasSeenOnboarding && state.uri.path != '/onboarding') {
    return '/onboarding';
  }

  // 2. Si no está autenticado y no es ruta pública
  if (user == null && !isPublicRoute) {
    return '/phone-sign-in';
  }

  // 3. Si está autenticado, verificar estado del registro
  if (user != null) {
    // Recargar datos del usuario
    await user.reload();
    final updatedUser = FirebaseAuth.instance.currentUser;

    if (updatedUser == null) {
      return '/phone-sign-in';
    }

    // Verificar proveedores
    final hasPhoneProvider = updatedUser.providerData.any(
      (provider) => provider.providerId == 'phone',
    );
    final hasEmailProvider = updatedUser.providerData.any(
      (provider) => provider.providerId == 'password',
    );

    // Si solo tiene teléfono, debe completar registro
    if (hasPhoneProvider &&
        !hasEmailProvider &&
        state.uri.path != '/user-registration') {
      return '/user-registration';
    }

    // Si tiene email pero no está verificado
    if (hasEmailProvider &&
        !updatedUser.emailVerified &&
        state.uri.path != '/email-verification') {
      return '/email-verification';
    }

    // Si email está verificado, verificar registro completo en Firestore
    if (hasEmailProvider && updatedUser.emailVerified) {
      final isRegistrationCompleteUseCase = sl<IsRegistrationCompleteUseCase>();
      final result = await isRegistrationCompleteUseCase();

      final isComplete = result.fold((_) => false, (complete) => complete);

      if (!isComplete && state.uri.path != '/email-verification') {
        return '/email-verification';
      }

      // Registro completo, puede acceder a home
      if (isComplete &&
          isPublicRoute &&
          state.uri.path != '/email-verification') {
        return '/home';
      }
    }

    // Si intenta acceder a rutas públicas con registro completo
    if (isPublicRoute &&
        updatedUser.emailVerified &&
        state.uri.path != '/email-verification') {
      return '/home';
    }
  }

  return null;
}
