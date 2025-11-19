import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/password_reset_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/email_authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/presentation/config/themes/color_palette.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_text_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ResetPasswordUseCase _resetPasswordUseCase = sl<ResetPasswordUseCase>();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  bool _canResend = true;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _resetPasswordUseCase(
      PasswordResetEntity(email: _emailController.text.trim()),
    );

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (failure) => _showErrorToastification(
        title: 'Error al enviar el correo',
        description: _mapFailureToMessage(failure),
        type: ToastNotificationType.error,
      ),
      (_) {
        setState(() {
          _emailSent = true;
        });
        _startResendCooldown();
        _showErrorToastification(
          title: 'Correo enviado',
          description:
              'Revisa tu bandeja de entrada para restablecer tu contraseña.',
          type: ToastNotificationType.success,
        );
      },
    );
  }

  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCooldown--;
        });

        if (_resendCooldown <= 0) {
          setState(() {
            _canResend = true;
          });
          return false;
        }
        return true;
      }
      return false;
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (UserNotFoundFailure):
        return 'No existe una cuenta con este correo electrónico';
      case const (TooManyRequestsFailure):
        return ErrorMessages.tooManyRequests;
      default:
        return ErrorMessages.serverError;
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
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Enviando correo...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(theme),
                const SizedBox(height: 20),
                _emailSent
                    ? _buildSuccessContent(theme)
                    : _buildFormContent(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        const Spacer(),
        if (_emailSent)
          TextButton(
            onPressed: () {
              setState(() {
                _emailSent = false;
                _emailController.clear();
              });
            },
            child: Text(
              'Cambiar Email',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Blob.random(
          size: 130,
          minGrowth: 10,
          styles: BlobStyles(color: theme.primaryColorLight.withAlpha(100)),
          child: Icon(
            Icons.lock_reset,
            size: 60,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¿Olvidaste tu contraseña?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'No te preocupes, te enviaremos un enlace para restablecer tu contraseña a tu correo electrónico.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: CustomTextField(
            label: 'Correo electrónico',
            hint: 'Ingresa tu correo registrado',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: FormValidators.validateEmail,
          ),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: 'Enviar Enlace',
          onPressed: _isLoading ? null : _handleResetPassword,
          isLoading: _isLoading,
          width: double.infinity,
          icon: const Icon(Icons.send_outlined, size: 20),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Blob.random(
          size: 130,
          minGrowth: 10,
          styles: BlobStyles(color: ColorPalette.successLight),
          child: const Icon(
            Icons.lock_reset,
            size: 60,
            color: ColorPalette.success,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¡Correo Enviado!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Te hemos enviado un enlace para restablecer tu contraseña. Revisa tu bandeja de entrada y sigue las instrucciones.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correo enviado a:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _emailController.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text:
              _canResend
                  ? 'Reenviar Correo'
                  : 'Reenviar en ${_resendCooldown}s',
          onPressed: (_canResend && !_isLoading) ? _handleResetPassword : null,
          isLoading: _isLoading,
          variant: ButtonVariant.outline,
          width: double.infinity,
          icon: const Icon(Icons.refresh, size: 20),
        ),
        const SizedBox(height: 20),
        Text(
          '¿No recibiste el correo? Revisa tu carpeta de spam',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
