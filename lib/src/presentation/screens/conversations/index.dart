import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/auth/authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/contacts_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/widgets/conversation_list_item.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/common/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final conversationsProvider = context.read<ConversationsProvider>();
      final contactsProvider = context.read<ContactsProvider>();

      if (userProvider.currentUser == null) {
        userProvider.loadCurrentUser();
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        conversationsProvider.startConversationsListener(currentUser.uid);
        contactsProvider.startContactsListener(currentUser.uid);
      }
    });
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.warning,
            title: 'Cerrar Sesión',
            description: '¿Estás seguro de que quieres cerrar sesión?',
            primaryButtonVariant: ButtonVariant.primary,
            primaryButtonText: 'Cerrar Sesión',
            primaryButtonIcon: Icons.logout,
            onPrimaryPressed: () async {
              Navigator.pop(context);
              await _signOut();
            },
            isSecondaryButtonEnabled: true,
            secondaryButtonVariant: ButtonVariant.outline,
            onSecondaryPressed: () => Navigator.pop(context),
          ),
    );
  }

  Future<void> _signOut() async {
    final authProvider = context.read<AuthenticationProvider>();
    final userProvider = context.read<UserProvider>();
    final conversationsProvider = context.read<ConversationsProvider>();
    final contactsProvider = context.read<ContactsProvider>();

    conversationsProvider.stopConversationsListener();
    contactsProvider.stopContactsListener();

    await authProvider.signOut();
    userProvider.clearCurrentUser();

    if (mounted) {
      context.go('/phone-sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleSignOut();
              } else if (value == 'profile') {
                context.push('/profile');
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 10),
                        Text('Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 10),
                        Text('Ajustes'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 10),
                        Text('Cerrar Sesión'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Consumer3<ConversationsProvider, UserProvider, ContactsProvider>(
        builder: (
          context,
          conversationsProvider,
          userProvider,
          contactsProvider,
          _,
        ) {
          if (conversationsProvider.conversationsState ==
                  ConversationsState.loading &&
              conversationsProvider.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (conversationsProvider.conversationsState ==
              ConversationsState.error) {
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
                    conversationsProvider.conversationsError ??
                        'Error desconocido',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final conversations = conversationsProvider.conversations;

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: theme.colorScheme.primary.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay conversaciones',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia un chat con tus contactos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // El stream se actualiza automáticamente
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final currentUserId = userProvider.currentUser?.id ?? '';

                return ConversationListItem(
                  conversation: conversation,
                  currentUserId: currentUserId,
                  onTap: () {
                    context.push('/chat/${conversation.id}');
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'create_group',
            mini: true,
            onPressed: () {
              context.push('/create-group');
            },
            child: const Icon(Icons.group_add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'new_chat',
            onPressed: () {
              context.push('/contacts');
            },
            child: const Icon(Icons.chat),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final conversationsProvider = context.read<ConversationsProvider>();
        final contactsProvider = context.read<ContactsProvider>();

        conversationsProvider.stopConversationsListener();
        contactsProvider.stopContactsListener();
      }
    });

    super.dispose();
  }
}
