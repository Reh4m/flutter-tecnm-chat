import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/image_picker_service.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_text_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/editable_avatar.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  late final UserProvider _userProvider;

  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    _userProvider = context.read<UserProvider>();

    _loadUserInfo();
  }

  void _loadUserInfo() {
    final currentUser = _userProvider.currentUser;

    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _bioController.text = currentUser.bio ?? '';
    }
  }

  Future<void> _handleSelectImage() async {
    await ImagePickerService.showImageSourceDialog(
      context,
      onImageSelected: (file) {
        if (file != null) {
          setState(() {
            _newProfileImage = file;
          });
        }
      },
    );
  }

  Future<void> _handleSaveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final currentUser = _userProvider.currentUser;

    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final success = await _userProvider.updateCurrentUserWithImage(
      updatedUser: updatedUser,
      profileImageFile: _newProfileImage,
    );

    if (!mounted) return;

    if (success) {
      _showToast(
        title: 'Perfil actualizado',
        description: 'Tu perfil se actualizó correctamente',
        type: ToastNotificationType.success,
      );
      context.pop();
    } else {
      _showToast(
        title: 'Error',
        description:
            _userProvider.operationError ?? 'No se pudo actualizar el perfil',
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
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final isLoading = userProvider.operationState == UserState.loading;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Actualizando...',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImage(theme, userProvider),
                    const SizedBox(height: 32),
                    CustomTextField(
                      label: 'Nombre',
                      hint: 'Tu nombre completo',
                      controller: _nameController,
                      validator: FormValidators.validateName,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Bio',
                      hint: 'Cuéntanos sobre ti',
                      controller: _bioController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Guardar Cambios',
                      onPressed: isLoading ? null : _handleSaveProfile,
                      width: double.infinity,
                      icon: const Icon(Icons.save, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(ThemeData theme, UserProvider userProvider) {
    final user = _userProvider.currentUser;
    final isLoading = _userProvider.currentUserState == UserState.loading;

    return EditableAvatar(
      imageUrl: _newProfileImage == null ? user?.photoUrl : null,
      imageFile: _newProfileImage,
      initials: user?.initials ?? '?',
      radius: 60,
      onTap: isLoading ? () {} : _handleSelectImage,
      showEditIcon: !isLoading,
    );
  }
}
