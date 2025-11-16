import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_text_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthenticationProvider>();
      authProvider.clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthenticationProvider>();

      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!context.mounted) return;

      switch (authProvider.state) {
        case AuthState.success:
          context.go('/home');
          break;
        case AuthState.error:
          _showErrorToastification(
            title: authProvider.errorMessage ?? 'Error al iniciar sesión',
            description:
                'Por favor, verifica tus credenciales e intenta nuevamente.',
            type: ToastNotificationType.error,
          );
          break;
        default:
          break;
      }
    }
  }

  void _showErrorToastification({
    required String title,
    required String description,
    required ToastNotificationType type,
  }) {
    ToastNotification.show(
      context,
      title: title,
      description: description,
      type: type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Selector<AuthenticationProvider, AuthState>(
        selector: (_, authProvider) => authProvider.state,
        builder: (_, authState, child) {
          return LoadingOverlay(
            isLoading: authState == AuthState.loading,
            message: 'Iniciando sesión...',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(theme),
                    const SizedBox(height: 20),
                    _buildForm(theme),
                    const SizedBox(height: 20),
                    _buildSignInButton(authState),
                    const SizedBox(height: 20),
                    _buildForgotPasswordLink(theme),
                    const SizedBox(height: 20),
                    _buildSignUpPrompt(theme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.chat_bubble,
            size: 40,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Bienvenido de nuevo',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Inicia sesión para continuar',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Correo electrónico',
            hint: 'ejemplo@correo.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: FormValidators.validateEmail,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Contraseña',
            hint: 'Ingresa tu contraseña',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es obligatoria';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
              Text(
                'Recordarme',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(AuthState authState) {
    return CustomButton(
      text: 'Iniciar Sesión',
      onPressed: authState == AuthState.loading ? null : _handleSignIn,
      isLoading: authState == AuthState.loading,
      width: double.infinity,
      height: 56,
    );
  }

  Widget _buildForgotPasswordLink(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: () {
          context.push('/forgot-password');
        },
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: () {
            context.push('/register');
          },
          child: Text(
            'Regístrate',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
