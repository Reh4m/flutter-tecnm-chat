import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/phone_validator.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/phone_authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_text_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

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

    final provider = context.read<PhoneAuthenticationProvider>();

    final formattedPhone = PhoneValidators.formatPhoneNumber(
      _phoneController.text.trim(),
    );

    await provider.sendVerificationCode(formattedPhone);

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
          'Ingresa tu número',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Te enviaremos un código de verificación',
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
      child: CustomTextField(
        label: 'Número de teléfono',
        hint: '+52 123 456 7890',
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        validator: FormValidators.validatePhoneNumber,
        onChanged: (value) {
          if (value.isNotEmpty && !value.startsWith('+')) {
            _phoneController.text = '+$value';
            _phoneController.selection = TextSelection.fromPosition(
              TextPosition(offset: _phoneController.text.length),
            );
          }
        },
      ),
    );
  }

  Widget _buildSendButton(PhoneAuthState state) {
    return CustomButton(
      text: 'Enviar Código',
      onPressed: state == PhoneAuthState.loading ? null : _handleSendCode,
      isLoading: state == PhoneAuthState.loading,
      width: double.infinity,
      height: 56,
      icon: const Icon(Icons.send_rounded),
      iconPosition: ButtonIconPosition.right,
    );
  }
}
