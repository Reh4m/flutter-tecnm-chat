import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart' as di;
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/contacts_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_phone_number_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_text_field.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _searchByPhone = true;

  PhoneNumber? _currentNumber;

  FirebaseAuth get _firebaseAuth => di.sl<FirebaseAuth>();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_searchByPhone && _currentNumber == null) {
      _showToast(
        title: 'Error',
        description: 'Por favor, ingresa un número de teléfono válido',
        type: ToastNotificationType.error,
      );
      return;
    }

    final provider = context.read<ContactsProvider>();
    provider.clearSearch();

    if (_searchByPhone) {
      await provider.searchUserByPhone(_currentNumber!.phoneNumber!);
    } else {
      await provider.searchUserByEmail(_emailController.text.trim());
    }

    if (!mounted) return;

    if (provider.searchState == ContactsState.error) {
      _showToast(
        title: 'Error',
        description: provider.searchError ?? 'Usuario no encontrado',
        type: ToastNotificationType.error,
      );
    } else if (provider.searchedUser == null) {
      _showToast(
        title: 'No encontrado',
        description: 'No se encontró ningún usuario con esos datos',
        type: ToastNotificationType.warning,
      );
    }
  }

  Future<void> _handleAddContact() async {
    final provider = context.read<ContactsProvider>();
    final user = provider.searchedUser;

    if (user == null) return;

    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return;

    final success = await provider.addContact(
      userId: currentUserId,
      contactUserId: user.id,
    );

    if (!mounted) return;

    if (success) {
      _showToast(
        title: 'Contacto agregado',
        description: '${user.name} ha sido agregado a tus contactos',
        type: ToastNotificationType.success,
      );
      context.pop();
    } else {
      _showToast(
        title: 'Error',
        description:
            provider.operationError ?? 'No se pudo agregar el contacto',
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
          'Agregar Contacto',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ContactsProvider>(
        builder: (context, provider, _) {
          final isLoading =
              provider.searchState == ContactsState.loading ||
              provider.operationState == ContactsState.loading;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Buscando...',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchTypeToggle(theme),
                  const SizedBox(height: 20),
                  _buildSearchForm(),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Buscar',
                    onPressed: isLoading ? null : _handleSearch,
                    width: double.infinity,
                    icon: const Icon(Icons.search, size: 20),
                  ),
                  if (provider.searchedUser != null) ...[
                    const SizedBox(height: 30),
                    _buildUserCard(theme, provider),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchTypeToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              theme: theme,
              text: 'Teléfono',
              isSelected: _searchByPhone,
              onTap: () => setState(() => _searchByPhone = true),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              theme: theme,
              text: 'Email',
              isSelected: !_searchByPhone,
              onTap: () => setState(() => _searchByPhone = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required ThemeData theme,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color:
                isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Form(
      key: _formKey,
      child:
          _searchByPhone
              ? CustomPhoneNumberField(
                label: 'Número de teléfono',
                controller: _phoneController,
                initialValue: PhoneNumber(isoCode: 'MX'),
                hint: '123 456 7890',
                onInputChanged: (PhoneNumber number) {
                  _currentNumber = number;
                },
              )
              : CustomTextField(
                label: 'Email institucional',
                hint: 'ejemplo@itcelaya.edu.mx',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.validateEmail,
              ),
    );
  }

  Widget _buildUserCard(ThemeData theme, ContactsProvider provider) {
    final user = provider.searchedUser!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary.withAlpha(50),
              backgroundImage:
                  user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? NetworkImage(user.photoUrl!)
                      : null,
              child:
                  user.photoUrl == null || user.photoUrl!.isEmpty
                      ? Text(
                        user.initials,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              variant: ButtonVariant.outline,
              text: 'Agregar Contacto',
              onPressed: _handleAddContact,
              width: double.infinity,
              icon: const Icon(Icons.person_add, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
