import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_sign_up_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/auth/phone_authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/image_picker_service.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_text_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/editable_avatar.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _profileImage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSelectImage() async {
    await ImagePickerService.showImageSourceDialog(
      context,
      onImageSelected: (file) {
        if (file != null) {
          setState(() {
            _profileImage = file;
          });
        }
      },
    );
  }

  Future<void> _handleCompleteRegistration() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<PhoneAuthenticationProvider>();

    await provider.completeRegistration(
      userRegistrationData: UserSignUpEntity(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
      profileImageFile: _profileImage,
    );

    if (!mounted) return;

    if (provider.state == PhoneAuthState.registrationComplete) {
      _showToast(
        title: '¡Registro exitoso!',
        description: 'Te hemos enviado un email de verificación',
        type: ToastNotificationType.success,
      );
      context.go('/email-verification');
    } else if (provider.state == PhoneAuthState.error) {
      _showToast(
        title: 'Error',
        description: provider.errorMessage ?? 'Error al completar registro',
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Selector<PhoneAuthenticationProvider, PhoneAuthState>(
          selector: (_, provider) => provider.state,
          builder: (_, state, __) {
            final isLoading = state == PhoneAuthState.loading;

            return LoadingOverlay(
              isLoading: isLoading,
              message: 'Completando registro...',
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatar(theme),
                        const SizedBox(height: 20),
                        _buildTitle(theme),
                        const SizedBox(height: 20),
                        _buildForm(theme, isLoading),
                        const SizedBox(height: 20),
                        _buildContinueButton(isLoading),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return Center(
      child: EditableAvatar(
        imageFile: _profileImage,
        radius: 60,
        onTap: _handleSelectImage,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completa tu perfil',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Ingresa tus datos para completar el registro.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Nombre completo',
            hint: 'Juan Pérez',
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            validator: FormValidators.validateName,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Email institucional',
            hint: 'ejemplo@itcelaya.edu.mx',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            validator: FormValidators.validateEmail,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Contraseña',
            hint: 'Mínimo 8 caracteres',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            validator: FormValidators.validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Confirmar contraseña',
            hint: 'Repite tu contraseña',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
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
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              onPressed:
                  () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(bool isLoading) {
    return CustomButton(
      text: 'Continuar',
      onPressed: _handleCompleteRegistration,
      isLoading: isLoading,
      width: double.infinity,
      height: 56,
    );
  }
}
