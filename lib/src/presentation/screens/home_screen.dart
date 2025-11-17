import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  void _initializeProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();

      // Cargar datos del usuario actual si no están cargados
      if (userProvider.currentUser == null) {
        userProvider.loadCurrentUser();
      }
    });
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.warning,
            title: 'Cerrar Sesión',
            description: '¿Estás seguro de que quieres cerrar sesión?',
            primaryButtonVariant: ButtonVariant.primary,
            primaryButtonText: 'Cerrar Sesión',
            primaryButtonIcon: Icons.logout,
            onPrimaryPressed: () async {
              Navigator.pop(context);
              await _signOut();
            },
            isSecondaryButtonEnabled: true,
            secondaryButtonVariant: ButtonVariant.outline,
            onSecondaryPressed: () => Navigator.pop(context),
          ),
    );
  }

  Future<void> _signOut() async {
    final authProvider = context.read<AuthenticationProvider>();
    final userProvider = context.read<UserProvider>();

    await authProvider.signOut();
    userProvider.clearCurrentUser();

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final currentUser = userProvider.currentUser;
          final isLoading = userProvider.currentUserState == UserState.loading;
          final hasError = userProvider.currentUserState == UserState.error;

          if (isLoading && currentUser == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando perfil...'),
                ],
              ),
            );
          }

          if (hasError && currentUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar perfil',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProvider.currentUserError ?? 'Error desconocido',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Reintentar',
                    onPressed: () => userProvider.loadCurrentUser(),
                  ),
                ],
              ),
            );
          }

          if (currentUser == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          return LoadingOverlay(
            isLoading: userProvider.operationState == UserState.loading,
            message: 'Actualizando perfil...',
            child: RefreshIndicator(
              onRefresh: () async {
                await userProvider.loadCurrentUser();
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentUser.name,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    Text(currentUser.email, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Cerrar Sesión',
                      variant: ButtonVariant.outline,
                      onPressed: _handleSignOut,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
