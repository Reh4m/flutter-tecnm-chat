import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/group_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/group_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/image_picker_service.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_text_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/editable_avatar.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditGroupScreen extends StatefulWidget {
  const EditGroupScreen({super.key});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final GroupChatProvider _groupChatProvider;

  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    _groupChatProvider = context.read<GroupChatProvider>();

    _loadGroupInfo();
  }

  void _loadGroupInfo() {
    final currentGroup = _groupChatProvider.currentGroup;

    if (currentGroup != null) {
      _nameController.text = currentGroup.name;
      _descriptionController.text = currentGroup.description ?? '';
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

  Future<void> _handleSaveGroup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final currentUserId = context.read<UserProvider>().currentUser?.id;
    if (currentUserId == null) return;

    final success = await _groupChatProvider.updateGroupInfoWithImage(
      groupId: _groupChatProvider.currentGroup!.id,
      name: _nameController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      requestingUserId: currentUserId,
      profileImageFile: _newProfileImage,
    );

    if (!mounted) return;

    if (success) {
      _showToast(
        title: 'Grupo actualizado',
        description: 'La información del grupo se actualizó correctamente',
        type: ToastNotificationType.success,
      );
      context.pop();
    } else {
      _showToast(
        title: 'Error',
        description:
            _groupChatProvider.operationError ??
            'No se pudo actualizar el grupo',
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
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Grupo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<GroupChatProvider>(
        builder: (context, groupProvider, _) {
          final isLoading = groupProvider.operationState == UserState.loading;
          final currentGroup = groupProvider.currentGroup;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Actualizando...',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(child: _buildAvatar(theme, currentGroup!)),
                    const SizedBox(height: 32),
                    CustomTextField(
                      label: 'Nombre del grupo',
                      hint: 'Ej: Programación Móvil',
                      controller: _nameController,
                      validator: FormValidators.validateName,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Descripción',
                      hint: 'Descripción del grupo',
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Guardar Cambios',
                      onPressed: isLoading ? null : _handleSaveGroup,
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

  Widget _buildAvatar(ThemeData theme, GroupEntity currentGroup) {
    return EditableAvatar(
      imageUrl: _newProfileImage == null ? currentGroup.avatarUrl : null,
      imageFile: _newProfileImage,
      initials:
          _nameController.text.isNotEmpty
              ? _nameController.text[0].toUpperCase()
              : '?',
      radius: 60,
      onTap: _handleSelectImage,
    );
  }
}
