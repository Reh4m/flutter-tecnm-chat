import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/group_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/contacts_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/direct_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/group_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/widgets/conversation_list_item.dart';
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
    _initializeListeners();
  }

  void _initializeListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();

      if (userProvider.currentUser != null) {
        _startAllListeners(userProvider.currentUser!.id);
      } else {
        userProvider.addListener(_onUserLoaded);
      }
    });
  }

  void _startAllListeners(String userId) {
    context.read<DirectChatProvider>().startChatsListener(userId);
    context.read<ContactsProvider>().startContactsListener(userId);
    context.read<GroupChatProvider>().startGroupsListener(userId);
  }

  void _onUserLoaded() {
    final userProvider = context.read<UserProvider>();

    if (userProvider.currentUser != null) {
      userProvider.removeListener(_onUserLoaded);
      _startAllListeners(userProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userProvider = context.read<UserProvider>();

        userProvider.removeListener(_onUserLoaded);
      }
    });
    super.dispose();
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
              if (value == 'profile') {
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
                ],
          ),
        ],
      ),
      body: Consumer3<DirectChatProvider, UserProvider, GroupChatProvider>(
        builder: (
          context,
          directChatProvider,
          userProvider,
          groupChatProvider,
          _,
        ) {
          final isLoadingConversations =
              directChatProvider.directChatState == DirectChatState.loading &&
              directChatProvider.chats.isEmpty;
          final isLoadingGroups =
              groupChatProvider.groupsState == GroupChatState.loading &&
              groupChatProvider.groups.isEmpty;

          if (isLoadingConversations || isLoadingGroups) {
            return const Center(child: CircularProgressIndicator());
          }

          if (directChatProvider.directChatState == DirectChatState.error ||
              groupChatProvider.groupsState == GroupChatState.error) {
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
                  if (directChatProvider.directChatState ==
                      DirectChatState.error)
                    Text(
                      directChatProvider.chatsError ?? 'Error desconocido',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  if (groupChatProvider.groupsState == GroupChatState.error)
                    Text(
                      groupChatProvider.groupsError ?? 'Error desconocido',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          }

          final directChats = directChatProvider.chats;
          final groupChats = groupChatProvider.groups;

          // Combinar conversaciones directas y grupos
          final conversations = <dynamic>[...directChats, ...groupChats];

          // Ordenar por última actividad (último mensaje o actualización del grupo)
          conversations.sort((a, b) {
            final aTime =
                a is DirectChatEntity
                    ? a.lastMessageTime
                    : (a as GroupEntity).lastMessageTime == null
                    ? a.updatedAt
                    : a.lastMessageTime;
            final bTime =
                b is DirectChatEntity
                    ? b.lastMessageTime
                    : (b as GroupEntity).lastMessageTime == null
                    ? b.updatedAt
                    : b.lastMessageTime;

            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;

            return bTime.compareTo(aTime); // Más reciente primero
          });

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
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final item = conversations[index];
                final currentUserId = userProvider.currentUser?.id ?? '';

                return ConversationListItem(
                  directChat: item is DirectChatEntity ? item : null,
                  group: item is GroupEntity ? item : null,
                  currentUserId: currentUserId,
                  onTap: () {
                    if (item is DirectChatEntity) {
                      context.push('/chat/${item.id}');
                    } else if (item is GroupEntity) {
                      context.push('/group-chat/${item.id}');
                    }
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
}
