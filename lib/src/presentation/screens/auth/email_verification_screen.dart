import 'dart:async';
import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/authentication_usecases.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final SendEmailVerificationUseCase _sendEmailVerification =
      sl<SendEmailVerificationUseCase>();
  final CheckEmailVerificationUseCase _checkEmailVerificationUseCase =
      sl<CheckEmailVerificationUseCase>();

  Timer? _verificationTimer;
  Timer? _cooldownTimer;
  bool _isLoading = false;
  bool _isResendingEmail = false;
  bool _canResend = true;
  int _resendCooldown = 0;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _initializeScreen() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _userEmail = user.email;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    }
  }

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    final result = await _checkEmailVerificationUseCase();

    result.fold(
      (failure) {
        _showToast(
          title: 'Error',
          description: 'Ocurrió un error al verificar el correo.',
          type: ToastNotificationType.error,
        );
      },
      (isVerified) {
        if (isVerified) {
          _verificationTimer?.cancel();

          if (mounted) {
            _showSuccessDialog();
          }
        }
      },
    );
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend || _isResendingEmail) return;

    setState(() {
      _isResendingEmail = true;
    });

    final result = await _sendEmailVerification();

    result.fold(
      (failure) {
        _showToast(
          title: 'Error al reenviar correo',
          description:
              'No se pudo enviar el correo de verificación. Por favor, inténtalo de nuevo más tarde.',
          type: ToastNotificationType.error,
        );
      },
      (_) {
        _showToast(
          title: 'Correo reenviado',
          description:
              'Te hemos enviado un nuevo correo de verificación. Por favor, revisa tu bandeja de entrada.',
          type: ToastNotificationType.success,
        );
        _startResendCooldown();
      },
    );

    setState(() {
      _isResendingEmail = false;
    });
  }

  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.success,
            title: '¡Email Verificado!',
            description:
                'Tu correo electrónico ha sido verificado exitosamente. Ya puedes acceder a todos nuestros servicios.',
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

  Future<void> _manualCheckVerification() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _checkEmailVerificationUseCase();

    result.fold(
      (failure) {
        _showToast(
          title: 'Error',
          description: 'Ocurrió un error al verificar el correo.',
          type: ToastNotificationType.error,
        );
      },
      (isVerified) {
        if (isVerified) {
          _showSuccessDialog();
        } else {
          _showToast(
            title: 'Email no verificado',
            description:
                'Tu correo electrónico aún no ha sido verificado. Por favor, revisa tu bandeja de entrada.',
            type: ToastNotificationType.warning,
          );
        }
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _backToLogin() {
    showDialog(
      context: context,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.warning,
            title: 'Volver al Login',
            description:
                '¿Estás seguro de que quieres volver a la pantalla de inicio de sesión?',
            primaryButtonVariant: ButtonVariant.outline,
            primaryButtonText: 'Sí, Volver',
            onPrimaryPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // ignore: use_build_context_synchronously
                context.go('/login');
              }
            },
            isSecondaryButtonEnabled: true,
            secondaryButtonVariant: ButtonVariant.primary,
            onSecondaryPressed: () => Navigator.of(context).pop(),
          ),
    );
  }

  void _changeEmail() {
    showDialog(
      context: context,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.warning,
            title: 'Cambiar Email',
            description:
                'Para cambiar tu correo electrónico necesitas cerrar sesión y crear una nueva cuenta.',
            primaryButtonVariant: ButtonVariant.outline,
            primaryButtonText: 'Cerrar Sesión',
            onPrimaryPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // ignore: use_build_context_synchronously
                context.go('/login');
              }
            },
            isSecondaryButtonEnabled: true,
            secondaryButtonVariant: ButtonVariant.primary,
            onSecondaryPressed: () => Navigator.of(context).pop(),
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
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Verificando...',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(theme),
                const SizedBox(height: 20),
                _buildEmailIcon(theme),
                const SizedBox(height: 20),
                _buildTitle(theme),
                const SizedBox(height: 5),
                _buildDescription(theme),
                const SizedBox(height: 20),
                _buildEmailInfo(theme),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 20),
                _buildFooter(theme),
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
          onPressed: _backToLogin,
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        const Spacer(),
        TextButton(
          onPressed: _changeEmail,
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

  Widget _buildEmailIcon(ThemeData theme) {
    return Blob.random(
      size: 130,
      minGrowth: 10,
      styles: BlobStyles(color: theme.primaryColorLight.withAlpha(100)),
      child: Icon(
        Icons.mark_email_read_outlined,
        size: 60,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      'Verifica tu Email',
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      'Te hemos enviado un enlace de verificación a tu correo electrónico. Haz clic en el enlace para activar tu cuenta.',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailInfo(ThemeData theme) {
    return Container(
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
          const SizedBox(width: 12),
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
                  _userEmail ?? 'No disponible',
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Ya Verifiqué mi Email',
          onPressed: _isLoading ? null : _manualCheckVerification,
          isLoading: _isLoading,
          width: double.infinity,
          icon: const Icon(Icons.refresh, size: 20),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text:
              _canResend
                  ? 'Reenviar Correo'
                  : 'Reenviar en ${_resendCooldown}s',
          onPressed:
              (_canResend && !_isResendingEmail)
                  ? _resendVerificationEmail
                  : null,
          isLoading: _isResendingEmail,
          variant: ButtonVariant.outline,
          width: double.infinity,
          icon: const Icon(Icons.send, size: 20),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verificando automáticamente...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Ayuda adicional
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
