import 'dart:async';
import 'package:blobs/blobs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  Timer? _verificationTimer;
  Timer? _cooldownTimer;
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
        context.go('/phone-auth');
      });
    }
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

  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        setState(() => _canResend = true);
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

  // void _backToLogin() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => CustomAlertDialog(
  //           status: AlertDialogStatus.warning,
  //           title: 'Cerrar Sesión',
  //           description: '¿Estás seguro de que quieres cerrar sesión?',
  //           primaryButtonVariant: ButtonVariant.outline,
  //           primaryButtonText: 'Sí, Cerrar',
  //           onPrimaryPressed: () async {
  //             Navigator.of(context).pop();
  //             await FirebaseAuth.instance.signOut();
  //             if (mounted) {
  //               context.go('/phone-auth');
  //             }
  //           },
  //           isSecondaryButtonEnabled: true,
  //           secondaryButtonVariant: ButtonVariant.primary,
  //           onSecondaryPressed: () => Navigator.of(context).pop(),
  //         ),
  //   );
  // }

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
      body: Consumer<EmailVerificationProvider>(
        builder: (context, provider, child) {
          final isLoading = provider.state == EmailVerificationState.loading;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Verificando...',
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(theme),
                    const SizedBox(height: 20),
                    _buildIcon(theme),
                    const SizedBox(height: 20),
                    _buildTitle(theme),
                    const SizedBox(height: 10),
                    _buildDescription(theme),
                    const SizedBox(height: 20),
                    _buildEmailInfo(theme, provider),
                    const SizedBox(height: 20),
                    _buildActionButtons(isLoading),
                    const SizedBox(height: 20),
                    _buildFooter(theme),
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
    return Row(
      children: [
        Text(
          'Paso 3 de 3',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primaryColorLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 5),
              Text(
                'Datos completos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return Blob.random(
      size: 130,
      minGrowth: 10,
      styles: BlobStyles(color: theme.primaryColorLight),
      child: Icon(
        Icons.email_rounded,
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
      'Te hemos enviado un enlace de verificación a tu correo. Haz clic en el enlace para completar tu registro.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailInfo(ThemeData theme, EmailVerificationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.email_outlined,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 15),
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

  Widget _buildActionButtons(bool isLoading) {
    return Column(
      children: [
        CustomButton(
          text: 'Ya Verifiqué mi Email',
          onPressed: isLoading ? null : _manualCheckVerification,
          isLoading: isLoading,
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
              (_canResend && !isLoading) ? _resendVerificationEmail : null,
          variant: ButtonVariant.outline,
          width: double.infinity,
          icon: const Icon(Icons.send, size: 20),
          iconPosition: ButtonIconPosition.right,
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
