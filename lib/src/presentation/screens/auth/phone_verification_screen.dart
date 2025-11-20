import 'dart:async';
import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/phone_validator.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/auth/phone_authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  Timer? _cooldownTimer;
  int _resendCooldown = 60;
  bool _canResend = false;
  String _currentCode = '';

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
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

  Future<void> _handleVerifyCode(String code) async {
    final provider = context.read<PhoneAuthenticationProvider>();

    await provider.verifyCode(code);

    if (!mounted) return;

    if (provider.state == PhoneAuthState.phoneVerified) {
      if (provider.needsRegistration) {
        context.go('/user-registration');
      } else {
        final user = provider.currentUser;

        if (user?.emailVerified ?? false) {
          context.go('/home');
        } else {
          context.go('/email-verification');
        }
      }
    } else if (provider.state == PhoneAuthState.error) {
      _showToast(
        title: 'Error',
        description: provider.errorMessage ?? 'Código incorrecto',
        type: ToastNotificationType.error,
      );
    }
  }

  Future<void> _handleResendCode() async {
    if (!_canResend) return;

    final provider = context.read<PhoneAuthenticationProvider>();

    await provider.resendCode();

    if (!mounted) return;

    if (provider.state == PhoneAuthState.codeSent) {
      _showToast(
        title: 'Código reenviado',
        description: 'Te hemos enviado un nuevo código',
        type: ToastNotificationType.success,
      );
      _startResendCooldown();
    } else if (provider.state == PhoneAuthState.error) {
      _showToast(
        title: 'Error',
        description: provider.errorMessage ?? 'Error al reenviar código',
        type: ToastNotificationType.error,
      );
    }
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
      body: Consumer<PhoneAuthenticationProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          final phoneNumber = provider.phoneNumber;

          return LoadingOverlay(
            isLoading: state == PhoneAuthState.loading,
            message: 'Verificando código...',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(theme),
                    const SizedBox(height: 20),
                    _buildIcon(theme),
                    const SizedBox(height: 20),
                    _buildTitle(theme),
                    const SizedBox(height: 20),
                    _buildPhoneInfo(theme, phoneNumber: phoneNumber!),
                    const SizedBox(height: 20),
                    _buildPinCodeField(theme, state),
                    const SizedBox(height: 20),
                    _buildVerifyButton(state),
                    const SizedBox(height: 20),
                    _buildResendButton(state),
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
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
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
        Icons.sms_rounded,
        size: 60,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Verifica tu número',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Ingresa el código de 6 dígitos enviado a',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneInfo(ThemeData theme, {required String phoneNumber}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phone_android, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            PhoneValidators.formatPhoneNumberForDisplay(phoneNumber),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinCodeField(ThemeData theme, PhoneAuthState state) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      enabled: state != PhoneAuthState.loading,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12),
        fieldHeight: 56,
        fieldWidth: 48,
        activeFillColor: theme.colorScheme.surface,
        selectedFillColor: theme.colorScheme.surface,
        inactiveFillColor: theme.colorScheme.surface,
        activeColor: theme.colorScheme.primary,
        selectedColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.outline.withAlpha(50),
        errorBorderColor: theme.colorScheme.error,
      ),
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      onCompleted: (code) {
        _currentCode = code;
        _handleVerifyCode(code);
      },
      onChanged: (value) {
        setState(() => _currentCode = value);
      },
      beforeTextPaste: (text) {
        return text?.length == 6 && FormValidators.isValidOTPCode(text!);
      },
    );
  }

  Widget _buildVerifyButton(PhoneAuthState state) {
    return CustomButton(
      text: 'Verificar',
      onPressed:
          (state == PhoneAuthState.loading || _currentCode.length != 6)
              ? null
              : () => _handleVerifyCode(_currentCode),
      isLoading: state == PhoneAuthState.loading,
      width: double.infinity,
      height: 56,
      icon: const Icon(Icons.check, size: 20),
    );
  }

  Widget _buildResendButton(PhoneAuthState state) {
    return CustomButton(
      text: _canResend ? 'Reenviar Código' : 'Reenviar en ${_resendCooldown}s',
      onPressed:
          (_canResend && state != PhoneAuthState.loading)
              ? _handleResendCode
              : null,
      variant: ButtonVariant.outline,
      width: double.infinity,
      height: 56,
      icon: const Icon(Icons.refresh, size: 20),
    );
  }
}
