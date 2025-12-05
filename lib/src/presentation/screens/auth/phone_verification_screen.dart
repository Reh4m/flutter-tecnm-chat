import 'dart:async';
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

    return Consumer<PhoneAuthenticationProvider>(
      builder: (_, provider, __) {
        final isLoading = provider.state == PhoneAuthState.loading;
        final phoneNumber = provider.phoneNumber;

        if (phoneNumber == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Número de teléfono no proporcionado.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        return LoadingOverlay(
          isLoading: isLoading,
          message: 'Verificando...',
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(theme, phoneNumber: phoneNumber),
                      const SizedBox(height: 20),
                      _buildPinCodeField(theme, isLoading),
                      const SizedBox(height: 20),
                      _buildVerifyButton(isLoading),
                      const SizedBox(height: 20),
                      _buildResendButton(isLoading),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(ThemeData theme, {required String phoneNumber}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verifica tu número',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Ingresa el código de 6 dígitos enviado a '),
              TextSpan(
                text: PhoneValidators.formatPhoneNumberForDisplay(phoneNumber),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.primaryColorDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinCodeField(ThemeData theme, bool isLoading) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      enabled: !isLoading,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12),
        fieldHeight: 56,
        fieldWidth: 48,
        inactiveBorderWidth: 0,
        inactiveFillColor: theme.colorScheme.surface,
        inactiveColor: theme.colorScheme.surface,
        selectedFillColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary,
        activeFillColor: theme.colorScheme.surface,
        activeColor: theme.colorScheme.primary,
        disabledColor: theme.disabledColor,
        errorBorderColor: theme.colorScheme.error,
      ),
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      boxShadows: null,
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

  Widget _buildVerifyButton(bool isLoading) {
    return CustomButton(
      text: 'Verificar',
      onPressed:
          _currentCode.length != 6
              ? null
              : () => _handleVerifyCode(_currentCode),
      isLoading: isLoading,
      width: double.infinity,
      height: 56,
    );
  }

  Widget _buildResendButton(bool isLoading) {
    return CustomButton(
      text: _canResend ? 'Reenviar Código' : 'Reenviar en ${_resendCooldown}s',
      onPressed: _canResend ? _handleResendCode : null,
      isLoading: isLoading,
      variant: ButtonVariant.outline,
      width: double.infinity,
      height: 56,
    );
  }
}
