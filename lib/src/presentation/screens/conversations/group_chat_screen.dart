import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart' as di;
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/message_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/group_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/widgets/chat_input.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/widgets/group_message_bubble.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({super.key, required this.groupId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  FirebaseAuth get _firebaseAuth => di.sl<FirebaseAuth>();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupChatProvider = context.read<GroupChatProvider>();

      groupChatProvider.loadGroupById(widget.groupId);

      context.read<MessageProvider>().startMessagesListener(widget.groupId);

      final currentUserId = _firebaseAuth.currentUser?.uid;

      final hasMessages = groupChatProvider.currentGroup?.lastMessage != null;

      if (currentUserId != null && hasMessages) {
        groupChatProvider.markChatAsRead(
          chatId: widget.groupId,
          userId: currentUserId,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return;

    final message = MessageEntity(
      id: '',
      conversationId: widget.groupId,
      senderId: currentUserId,
      type: MessageType.text,
      content: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    _messageController.clear();

    final chatProvider = context.read<GroupChatProvider>();
    final success = await chatProvider.sendMessage(message);

    if (!success && mounted) {
      _showToast(
        title: 'Error',
        description:
            chatProvider.operationError ?? 'No se pudo enviar el mensaje',
        type: ToastNotificationType.error,
      );
    }
  }

  Future<void> _retryMessage(MessageEntity message) async {
    final chatProvider = context.read<GroupChatProvider>();
    final success = await chatProvider.retryFailedMessage(message);

    if (!success && mounted) {
      _showToast(
        title: 'Error',
        description: 'No se pudo reenviar el mensaje',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Consumer2<GroupChatProvider, UserProvider>(
          builder: (context, groupChatProvider, userProvider, _) {
            if (groupChatProvider.groupDetailState == GroupChatState.loading) {
              return const Text('Cargando...');
            }

            final group = groupChatProvider.currentGroup;

            if (group == null) {
              return const Text('Grupo');
            }

            return InkWell(
              onTap: () {
                context.push('/group-details/${widget.groupId}');
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.secondary.withAlpha(50),
                    backgroundImage:
                        group.avatarUrl != null && group.avatarUrl!.isNotEmpty
                            ? NetworkImage(group.avatarUrl!)
                            : null,
                    child:
                        group.avatarUrl == null || group.avatarUrl!.isEmpty
                            ? Icon(
                              Icons.group,
                              color: theme.colorScheme.secondary,
                              size: 20,
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          group.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${group.memberCount} miembros',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implementar videollamada grupal
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              context.push('/group-details/${widget.groupId}');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer2<GroupChatProvider, MessageProvider>(
              builder: (context, groupChatProvider, messageProvider, _) {
                if (messageProvider.messagesState == MessageState.loading &&
                    messageProvider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messageProvider.messagesState == MessageState.error) {
                  return Center(
                    child: Text(
                      messageProvider.messagesError ??
                          'Error al cargar mensajes',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                final messages = messageProvider.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: theme.colorScheme.primary.withAlpha(100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay mensajes',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sé el primero en enviar un mensaje',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final currentUserId = _firebaseAuth.currentUser?.uid ?? '';

                final groupParticipants =
                    groupChatProvider.groupParticipants[widget.groupId] ?? {};

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return GroupMessageBubble(
                      message: message,
                      isMe: isMe,
                      sender: groupParticipants[message.senderId],
                      onRetry:
                          message.status == MessageStatus.failed
                              ? () => _retryMessage(message)
                              : null,
                    );
                  },
                );
              },
            ),
          ),
          ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
            onAttachment: () {
              // TODO: Implementar envío de archivos
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MessageProvider>().stopMessagesListener();
        context.read<GroupChatProvider>().clearCurrentGroup();
      }
    });
    super.dispose();
  }
}
