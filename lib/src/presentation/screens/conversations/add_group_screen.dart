import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/group_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/contacts_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/group_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_text_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final Set<String> _selectedContactIds = {};
  bool _hidePhoneNumbers = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateGroup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedContactIds.isEmpty) {
      _showToast(
        title: 'Error',
        description: 'Selecciona al menos un contacto',
        type: ToastNotificationType.warning,
      );
      return;
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final memberIds = [currentUserId, ..._selectedContactIds];

    final group = GroupEntity(
      id: '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy: currentUserId,
      memberIds: memberIds,
      adminIds: [currentUserId],
      hidePhoneNumbers: _hidePhoneNumbers,
      createdAt: DateTime.now(),
    );

    final groupProvider = context.read<GroupProvider>();
    final createdGroup = await groupProvider.createGroup(group);

    if (!mounted) return;

    if (createdGroup != null) {
      _showToast(
        title: 'Grupo creado',
        description: 'El grupo se creó correctamente',
        type: ToastNotificationType.success,
      );
      context.pop();
    } else {
      _showToast(
        title: 'Error',
        description:
            groupProvider.operationError ?? 'No se pudo crear el grupo',
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
      appBar: AppBar(
        title: Text(
          'Crear Grupo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer2<GroupProvider, ContactsProvider>(
        builder: (context, groupProvider, contactsProvider, _) {
          final isLoading = groupProvider.operationState == GroupState.loading;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Creando grupo...',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroupIcon(theme),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 20),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ocultar números telefónicos'),
                      subtitle: const Text(
                        'Los miembros no verán los números de teléfono',
                      ),
                      value: _hidePhoneNumbers,
                      onChanged: (value) {
                        setState(() => _hidePhoneNumbers = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Seleccionar contactos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactsList(contactsProvider),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Crear Grupo',
                      onPressed: isLoading ? null : _handleCreateGroup,
                      width: double.infinity,
                      icon: const Icon(Icons.group_add, size: 20),
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

  Widget _buildGroupIcon(ThemeData theme) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.secondary.withAlpha(50),
            child: Icon(
              Icons.group,
              size: 50,
              color: theme.colorScheme.secondary,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 20,
                color: theme.colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(ContactsProvider contactsProvider) {
    final contacts = contactsProvider.contacts;

    if (contacts.isEmpty) {
      return const Text('No tienes contactos para agregar');
    }

    return Column(
      children:
          contacts.map((contact) {
            final contactUser = contactsProvider.getContactUser(
              contact.contactUserId,
            );
            final isSelected = _selectedContactIds.contains(
              contact.contactUserId,
            );

            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(contactUser?.name ?? 'Usuario'),
              subtitle: Text(contactUser?.email ?? ''),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedContactIds.add(contact.contactUserId);
                  } else {
                    _selectedContactIds.remove(contact.contactUserId);
                  }
                });
              },
            );
          }).toList(),
    );
  }
}
