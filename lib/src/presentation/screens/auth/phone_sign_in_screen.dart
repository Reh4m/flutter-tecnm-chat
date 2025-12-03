import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/auth/phone_authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_phone_number_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  PhoneNumber? _currentNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhoneAuthenticationProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_currentNumber == null) {
      _showToast(
        title: 'Error',
        description: 'Por favor, ingresa un número de teléfono válido',
        type: ToastNotificationType.success,
      );
      return;
    }

    final provider = context.read<PhoneAuthenticationProvider>();

    await provider.sendVerificationCode(_currentNumber!.phoneNumber!);

    if (!mounted) return;

    if (provider.state == PhoneAuthState.codeSent) {
      context.push('/phone-verification');
    } else if (provider.state == PhoneAuthState.error) {
      _showToast(
        title: 'Error',
        description: provider.errorMessage ?? 'Error al enviar código',
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
      body: Selector<PhoneAuthenticationProvider, PhoneAuthState>(
        selector: (_, provider) => provider.state,
        builder: (_, state, __) {
          return LoadingOverlay(
            isLoading: state == PhoneAuthState.loading,
            message: 'Enviando código...',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(theme),
                    const SizedBox(height: 20),
                    _buildForm(theme),
                    const SizedBox(height: 20),
                    _buildSendButton(state),
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
        Blob.random(
          size: 130,
          minGrowth: 10,
          styles: BlobStyles(color: theme.primaryColorLight),
          child: Icon(
            Icons.phone_android_rounded,
            size: 60,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¡Bienvenido!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Inicia sesión o registrate con tu número de teléfono',
          style: theme.textTheme.bodyMedium?.copyWith(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomPhoneNumberField(
            label: 'Número de Teléfono',
            controller: _phoneController,
            initialValue: PhoneNumber(isoCode: 'MX'),
            hint: '123 456 7890',
            onInputChanged: (PhoneNumber number) {
              _currentNumber = number;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(PhoneAuthState state) {
    return CustomButton(
      text: 'Continuar',
      onPressed: state == PhoneAuthState.loading ? null : _handleSendCode,
      isLoading: state == PhoneAuthState.loading,
      width: double.infinity,
      height: 56,
    );
  }
}
