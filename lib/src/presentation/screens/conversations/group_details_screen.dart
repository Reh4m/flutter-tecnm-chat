import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/group_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/contacts_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/group_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  Future<void> _togglePrivacy(bool value) async {
    final currentUserId = context.read<UserProvider>().currentUser?.id;
    if (currentUserId == null) return;

    final groupChatProvider = context.read<GroupChatProvider>();
    final success = await groupChatProvider.updatePrivacy(
      groupId: widget.groupId,
      hidePhoneNumbers: value,
      requestingUserId: currentUserId,
    );

    if (!mounted) return;

    if (!success) {
      _showToast(
        title: 'Error',
        description:
            groupChatProvider.operationError ??
            'No se pudo actualizar la privacidad',
        type: ToastNotificationType.error,
      );
    }
  }

  Future<void> _removeMember(String userId) async {
    final currentUserId = context.read<UserProvider>().currentUser?.id;
    if (currentUserId == null) return;

    final groupChatProvider = context.read<GroupChatProvider>();
    final success = await groupChatProvider.removeMember(
      groupId: widget.groupId,
      userId: userId,
      requestingUserId: currentUserId,
    );

    if (!mounted) return;

    if (success) {
      _showToast(
        title: 'Miembro eliminado',
        description: 'El miembro ha sido eliminado del grupo',
        type: ToastNotificationType.success,
      );
    } else {
      _showToast(
        title: 'Error',
        description:
            groupChatProvider.operationError ??
            'No se pudo eliminar al miembro',
        type: ToastNotificationType.error,
      );
    }
  }

  void _showAddMemberDialog() {
    final contactsProvider = context.read<ContactsProvider>();
    final groupChatProvider = context.read<GroupChatProvider>();
    final group = groupChatProvider.currentGroup;

    if (group == null) return;

    final availableContacts =
        contactsProvider.contacts
            .where(
              (contact) =>
                  !group.participantIds.contains(contact.contactUserId),
            )
            .toList();

    if (availableContacts.isEmpty) {
      _showToast(
        title: 'Sin contactos',
        description: 'Todos tus contactos ya están en el grupo',
        type: ToastNotificationType.info,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Agregar miembro',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableContacts.length,
                  itemBuilder: (context, index) {
                    final contact = availableContacts[index];
                    final contactUser = contactsProvider.getContactUser(
                      contact.contactUserId,
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(50),
                        backgroundImage:
                            contactUser?.photoUrl != null &&
                                    contactUser!.photoUrl!.isNotEmpty
                                ? NetworkImage(contactUser.photoUrl!)
                                : null,
                        child:
                            contactUser?.photoUrl == null ||
                                    contactUser!.photoUrl!.isEmpty
                                ? Text(
                                  contactUser?.initials ?? '?',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : null,
                      ),
                      title: Text(contactUser?.name ?? 'Usuario'),
                      subtitle: Text(contactUser?.email ?? ''),
                      onTap: () async {
                        Navigator.pop(context);
                        await _addMember(contact.contactUserId);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addMember(String userId) async {
    final currentUserId = context.read<UserProvider>().currentUser?.id;
    if (currentUserId == null) return;

    final groupChatProvider = context.read<GroupChatProvider>();
    final success = await groupChatProvider.addMember(
      groupId: widget.groupId,
      userId: userId,
      requestingUserId: currentUserId,
    );

    if (!mounted) return;

    if (success) {
      _showToast(
        title: 'Miembro agregado',
        description: 'El miembro ha sido agregado al grupo',
        type: ToastNotificationType.success,
      );
    } else {
      _showToast(
        title: 'Error',
        description:
            groupChatProvider.operationError ?? 'No se pudo agregar al miembro',
        type: ToastNotificationType.error,
      );
    }
  }

  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          status: AlertDialogStatus.warning,
          title: 'Salir del grupo',
          description: '¿Estás seguro de que quieres salir de este grupo?',
          primaryButtonVariant: ButtonVariant.primary,
          primaryButtonText: 'Salir',
          onPrimaryPressed: () {
            Navigator.pop(context);
            _leaveGroup();
          },
          isSecondaryButtonEnabled: true,
          secondaryButtonVariant: ButtonVariant.outline,
          onSecondaryPressed: () => Navigator.pop(context),
        );
      },
    );
  }

  Future<void> _leaveGroup() async {
    final currentUserId = context.read<UserProvider>().currentUser?.id;
    if (currentUserId == null) return;

    final groupChatProvider = context.read<GroupChatProvider>();
    final success = await groupChatProvider.removeMember(
      groupId: widget.groupId,
      userId: currentUserId,
      requestingUserId: currentUserId,
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
      _showToast(
        title: 'Grupo abandonado',
        description: 'Has salido del grupo',
        type: ToastNotificationType.success,
      );
    } else {
      _showToast(
        title: 'Error',
        description:
            groupChatProvider.operationError ?? 'No se pudo salir del grupo',
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
          'Detalles del grupo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer3<GroupChatProvider, UserProvider, ContactsProvider>(
        builder: (
          context,
          groupChatProvider,
          userProvider,
          contactsProvider,
          _,
        ) {
          final isLoading =
              groupChatProvider.groupDetailState == GroupChatState.loading ||
              groupChatProvider.operationState == GroupChatState.loading;

          if (groupChatProvider.groupDetailState == GroupChatState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupChatProvider.groupDetailState == GroupChatState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    groupChatProvider.groupDetailError ??
                        'Error al cargar grupo',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final group = groupChatProvider.currentGroup;

          if (group == null) {
            return const Center(child: Text('Grupo no encontrado'));
          }

          final currentUserId = userProvider.currentUser?.id ?? '';
          final isAdmin = group.isAdmin(currentUserId);
          final isCreator = group.isCreator(currentUserId);

          final groupParticipants =
              groupChatProvider.groupParticipants[widget.groupId] ?? {};

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Actualizando...',
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildGroupHeader(theme, group, isAdmin),
                  const SizedBox(height: 24),
                  _buildGroupInfo(theme, group),
                  const SizedBox(height: 24),
                  if (isAdmin) ...[
                    _buildPrivacySection(theme, group),
                    const SizedBox(height: 24),
                  ],
                  _buildMembersSection(
                    theme,
                    group,
                    isAdmin,
                    groupParticipants,
                  ),
                  const SizedBox(height: 24),
                  if (!isCreator) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomButton(
                        text: 'Salir del grupo',
                        variant: ButtonVariant.outline,
                        onPressed: _showLeaveGroupDialog,
                        width: double.infinity,
                        icon: const Icon(Icons.exit_to_app, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupHeader(ThemeData theme, GroupEntity group, bool isAdmin) {
    return Column(
      children: [
        InkWell(
          onTap:
              isAdmin
                  ? () {
                    context.push('/edit-group');
                  }
                  : null,
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.secondary.withAlpha(50),
                backgroundImage:
                    group.avatarUrl != null && group.avatarUrl!.isNotEmpty
                        ? NetworkImage(group.avatarUrl!)
                        : null,
                child:
                    group.avatarUrl == null || group.avatarUrl!.isEmpty
                        ? Icon(
                          Icons.group,
                          size: 60,
                          color: theme.colorScheme.secondary,
                        )
                        : null,
              ),
              if (isAdmin)
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
                      Icons.edit,
                      size: 20,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          group.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupInfo(ThemeData theme, GroupEntity group) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.description?.isNotEmpty == true
                          ? group.description!
                          : 'Sin descripción',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.people_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Miembros',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.memberCount} miembros',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(ThemeData theme, GroupEntity group) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Ocultar números telefónicos'),
        subtitle: const Text('Los miembros no verán los números de teléfono'),
        value: group.hidePhoneNumbers,
        onChanged: _togglePrivacy,
      ),
    );
  }

  Widget _buildMembersSection(
    ThemeData theme,
    GroupEntity group,
    bool isAdmin,
    Map<String, UserEntity> participants,
  ) {
    final currentUserId = context.read<UserProvider>().currentUser?.id;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    bool canSeePhoneNumbers = false;

    if (group.hidePhoneNumbers) {
      canSeePhoneNumbers =
          group.isAdmin(currentUserId) || group.isCreator(currentUserId);
    } else {
      canSeePhoneNumbers = true;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Miembros (${group.memberCount})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: _showAddMemberDialog,
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...group.participantIds.map<Widget>((memberId) {
            final member = participants[memberId];
            final isMemberAdmin = group.isAdmin(memberId);
            final isMemberCreator = group.isCreator(memberId);

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withAlpha(50),
                backgroundImage:
                    member?.photoUrl != null && member!.photoUrl!.isNotEmpty
                        ? NetworkImage(member.photoUrl!)
                        : null,
                child:
                    member?.photoUrl == null || member!.photoUrl!.isEmpty
                        ? Text(
                          member?.initials ?? '?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
              title: Row(
                children: [
                  Expanded(child: Text(member?.name ?? 'Usuario')),
                  if (isMemberCreator)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Creador',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isMemberAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Admin',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle:
                  canSeePhoneNumbers ? Text(member?.phoneNumber ?? '') : null,
              trailing:
                  isAdmin && memberId != currentUserId && !isMemberCreator
                      ? IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          _showMemberOptions(memberId, member?.name);
                        },
                      )
                      : null,
            );
          }),
        ],
      ),
    );
  }

  void _showMemberOptions(String memberId, String? memberName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  memberName ?? 'Usuario',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.remove_circle_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Eliminar del grupo',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showRemoveMemberDialog(memberId, memberName);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showRemoveMemberDialog(String memberId, String? memberName) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          status: AlertDialogStatus.warning,
          title: 'Eliminar miembro',
          description:
              '¿Estás seguro de que quieres eliminar a ${memberName ?? 'este miembro'} del grupo?',
          primaryButtonVariant: ButtonVariant.primary,
          primaryButtonText: 'Eliminar',
          onPrimaryPressed: () {
            Navigator.pop(context);
            _removeMember(memberId);
          },
          isSecondaryButtonEnabled: true,
          secondaryButtonVariant: ButtonVariant.outline,
          onSecondaryPressed: () => Navigator.pop(context),
        );
      },
    );
  }
}
