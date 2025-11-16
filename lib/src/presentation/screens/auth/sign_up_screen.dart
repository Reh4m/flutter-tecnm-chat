import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_text_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!_validateForm()) return;

    final authProvider = context.read<AuthenticationProvider>();

    await authProvider.signUp(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (!mounted) return;

    switch (authProvider.state) {
      case AuthState.success:
        _showSuccessDialog();
        break;
      case AuthState.error:
        _showToast(
          title: authProvider.errorMessage ?? 'Error al crear cuenta',
          description: 'Por favor, verifica tus datos e intenta nuevamente.',
          type: ToastNotificationType.error,
        );
        break;
      default:
        break;
    }
  }

  bool _validateForm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (!_acceptTerms) {
      _showToast(
        title: 'Términos y condiciones',
        description: 'Debes aceptar los términos y condiciones para continuar.',
        type: ToastNotificationType.warning,
      );
      return false;
    }

    if (!_acceptPrivacy) {
      _showToast(
        title: 'Política de privacidad',
        description: 'Debes aceptar la política de privacidad para continuar.',
        type: ToastNotificationType.warning,
      );
      return false;
    }

    return true;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.success,
            title: '¡Registro Exitoso!',
            description:
                'Tu cuenta ha sido creada exitosamente. Te hemos enviado un correo de verificación. Por favor, verifica tu email antes de continuar.',
            primaryButtonText: 'Continuar',
            primaryButtonVariant: ButtonVariant.primary,
            primaryButtonIcon: Icons.arrow_forward,
            onPrimaryPressed: () {
              Navigator.of(context).pop();
              context.go('/email-verification');
            },
          ),
    );
  }

  void _showToast({
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
            message: 'Creando tu cuenta...',
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
                    _buildTermsAndConditions(theme),
                    const SizedBox(height: 20),
                    _buildSignUpButton(authState),
                    const SizedBox(height: 20),
                    _buildSignInPrompt(theme),
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
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 20),
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
          'Crear Cuenta',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Completa el formulario para registrarte',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
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
            label: 'Nombre completo',
            hint: 'Ingresa tu nombre completo',
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: FormValidators.validateName,
          ),
          const SizedBox(height: 20),
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
            hint: 'Mínimo 8 caracteres',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: FormValidators.validatePassword,
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
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Confirmar contraseña',
            hint: 'Repite tu contraseña',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator:
                (value) => FormValidators.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(ThemeData theme) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
          onTap: () {
            setState(() {
              _acceptTerms = !_acceptTerms;
            });
          },
          title: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              children: [
                const TextSpan(text: 'Acepto los '),
                TextSpan(
                  text: 'términos y condiciones',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' del servicio'),
              ],
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: _acceptPrivacy,
            onChanged: (value) {
              setState(() {
                _acceptPrivacy = value ?? false;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
          onTap: () {
            setState(() {
              _acceptPrivacy = !_acceptPrivacy;
            });
          },
          title: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              children: [
                const TextSpan(text: 'Acepto la '),
                TextSpan(
                  text: 'política de privacidad',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' y manejo de datos'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(AuthState authState) {
    return CustomButton(
      text: 'Crear Cuenta',
      onPressed: authState == AuthState.loading ? null : _handleSignUp,
      isLoading: authState == AuthState.loading,
      width: double.infinity,
      height: 56,
    );
  }

  Widget _buildSignInPrompt(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          child: Text(
            'Inicia Sesión',
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
