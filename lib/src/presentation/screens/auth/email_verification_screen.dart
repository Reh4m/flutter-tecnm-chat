import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart' as di;
import 'package:flutter_whatsapp_clon/src/presentation/providers/auth/email_verification_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final firebaseAuth = di.sl<FirebaseAuth>();

  Timer? _verificationTimer;
  Timer? _cooldownTimer;
  bool _canResend = false;
  int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    final provider = context.read<EmailVerificationProvider>();

    if (provider.state == EmailVerificationState.loading) return;

    final isVerified = await provider.checkEmailVerification();

    if (!mounted) return;

    if (provider.state == EmailVerificationState.error &&
        provider.errorMessage != null) {
      _showToast(
        title: 'Error de verificación',
        description: provider.errorMessage!,
        type: ToastNotificationType.error,
      );
      return;
    }

    if (isVerified) {
      _verificationTimer?.cancel();

      final created = await provider.createUserAfterEmailVerification();

      if (!mounted) return;

      if (created) {
        _showSuccessDialog();
      } else if (provider.errorMessage != null) {
        _showToast(
          title: 'Error al crear usuario',
          description: provider.errorMessage!,
          type: ToastNotificationType.error,
        );
      }
    }
  }

  Future<void> _manualCheckVerification() async {
    final provider = context.read<EmailVerificationProvider>();

    final isVerified = await provider.checkEmailVerification();

    if (!mounted) return;

    if (isVerified) {
      final created = await provider.createUserAfterEmailVerification();

      if (created) {
        _showSuccessDialog();
      } else if (provider.errorMessage != null) {
        _showToast(
          title: 'Error',
          description: provider.errorMessage!,
          type: ToastNotificationType.error,
        );
      }
    } else {
      _showToast(
        title: 'Email no verificado',
        description:
            'Tu correo aún no ha sido verificado. Revisa tu bandeja de entrada.',
        type: ToastNotificationType.warning,
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    final provider = context.read<EmailVerificationProvider>();
    await provider.sendEmailVerification();

    if (!mounted) return;

    if (provider.state != EmailVerificationState.error) {
      _showToast(
        title: 'Correo reenviado',
        description: 'Te hemos enviado un nuevo correo de verificación.',
        type: ToastNotificationType.success,
      );
      _startResendCooldown();
    } else if (provider.errorMessage != null) {
      _showToast(
        title: 'Error',
        description: provider.errorMessage!,
        type: ToastNotificationType.error,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.success,
            title: '¡Registro Completo!',
            description:
                'Tu cuenta ha sido verificada exitosamente. Ahora puedes acceder a todas las funciones.',
            primaryButtonVariant: ButtonVariant.primary,
            primaryButtonText: 'Continuar',
            primaryButtonIcon: Icons.arrow_forward_rounded,
            onPrimaryPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
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
      body: Selector<EmailVerificationProvider, EmailVerificationState>(
        selector: (_, provider) => provider.state,
        builder: (_, state, __) {
          final isLoading = state == EmailVerificationState.loading;
          final currentUser = firebaseAuth.currentUser;

          if (currentUser == null) {
            return Center(
              child: Text(
                'No se encontró un usuario autenticado.',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Verificando...',
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(theme, userEmail: currentUser.email ?? ''),
                      const SizedBox(height: 20),
                      _buildActionButtons(isLoading),
                      const SizedBox(height: 20),
                      _buildFooter(theme),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, {required String userEmail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verifica tu Email',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              const TextSpan(
                text: 'Te hemos enviado un enlace de verificación al correo ',
              ),
              TextSpan(
                text: userEmail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.primaryColorDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(
                text: '. Haz clic en el enlace para completar tu registro.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Column(
      children: [
        CustomButton(
          text: 'Ya Verifiqué mi Email',
          onPressed: _manualCheckVerification,
          isLoading: isLoading,
          width: double.infinity,
          height: 56,
        ),
        const SizedBox(height: 20),
        CustomButton(
          text:
              _canResend
                  ? 'Reenviar Correo'
                  : 'Reenviar en ${_resendCooldown}s',
          onPressed: _canResend ? _resendVerificationEmail : null,
          isLoading: isLoading,
          variant: ButtonVariant.outline,
          width: double.infinity,
          height: 56,
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Text(
      '¿No recibiste el correo? Revisa tu carpeta de spam',
      style: theme.textTheme.bodySmall,
    );
  }
}
