import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/auth/authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/theme_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
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
      context.go('/phone-sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/edit-profile');
            },
          ),
        ],
      ),
      body: Consumer2<UserProvider, ThemeProvider>(
        builder: (context, userProvider, themeProvider, _) {
          if (userProvider.currentUserState == UserState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.currentUserState == UserState.error) {
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
                    userProvider.currentUserError ?? 'Error al cargar perfil',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final user = userProvider.currentUser;

          if (user == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildProfileHeader(theme, user.name, user.photoUrl),
                const SizedBox(height: 32),
                _buildInfoSection(
                  theme,
                  user.email,
                  user.phoneNumber,
                  user.bio,
                ),
                const SizedBox(height: 24),
                _buildSettingsSection(theme, themeProvider),
                const SizedBox(height: 24),
                _buildSignOutButton(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, String name, String? photoUrl) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: theme.colorScheme.primary.withAlpha(50),
          backgroundImage:
              photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
          child:
              photoUrl == null || photoUrl.isEmpty
                  ? Icon(
                    Icons.person,
                    size: 60,
                    color: theme.colorScheme.primary,
                  )
                  : null,
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    String email,
    String? phoneNumber,
    String? bio,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(theme, Icons.email_outlined, 'Email', email),
          if (phoneNumber != null) ...[
            const SizedBox(height: 16),
            _buildInfoItem(
              theme,
              Icons.phone_outlined,
              'Teléfono',
              phoneNumber,
            ),
          ],
          if (bio != null && bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoItem(theme, Icons.info_outline, 'Bio', bio),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(ThemeData theme, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tema Oscuro'),
            secondary: Icon(
              themeProvider.currentThemeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            value: themeProvider.currentThemeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomButton(
        text: 'Cerrar Sesión',
        variant: ButtonVariant.outline,
        onPressed: _handleSignOut,
        width: double.infinity,
        icon: const Icon(Icons.logout, size: 20),
      ),
    );
  }
}
