import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/widgets/message_bubble.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/widgets/chat_input.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.startMessagesListener(widget.conversationId);

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        context.read<ConversationsProvider>().markConversationAsRead(
          conversationId: widget.conversationId,
          userId: currentUserId,
        );

        chatProvider.markMessagesAsReadInConversation(widget.conversationId);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final message = MessageEntity(
      id: '',
      conversationId: widget.conversationId,
      senderId: currentUserId,
      type: MessageType.text,
      content: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    _messageController.clear();

    final chatProvider = context.read<ChatProvider>();
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
    final chatProvider = context.read<ChatProvider>();
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
        title: Consumer2<ConversationsProvider, ChatProvider>(
          builder: (context, conversationsProvider, chatProvider, _) {
            final conversation =
                conversationsProvider.conversations
                    .where((c) => c.id == widget.conversationId)
                    .firstOrNull;

            if (conversation == null) {
              return const Text('Chat');
            }

            final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
            final unreadCount = conversation.getUnreadCount(currentUserId);

            if (conversation.isDirect) {
              final otherUserId = conversationsProvider.getOtherUserId(
                conversation,
                currentUserId,
              );
              final otherUser =
                  otherUserId != null
                      ? conversationsProvider.getConversationUser(otherUserId)
                      : null;

              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary.withAlpha(50),
                    backgroundImage:
                        otherUser?.photoUrl != null &&
                                otherUser!.photoUrl!.isNotEmpty
                            ? NetworkImage(otherUser.photoUrl!)
                            : null,
                    child:
                        otherUser?.photoUrl == null ||
                                otherUser!.photoUrl!.isEmpty
                            ? Text(
                              otherUser?.initials ?? '?',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      otherUser?.name ?? 'Usuario',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.secondary.withAlpha(50),
                    backgroundImage:
                        conversation.groupAvatarUrl != null
                            ? NetworkImage(conversation.groupAvatarUrl!)
                            : null,
                    child:
                        conversation.groupAvatarUrl == null
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
                          conversation.groupName ?? 'Grupo',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (unreadCount > 0)
                          Text(
                            '$unreadCount mensaje${unreadCount > 1 ? 's' : ''} no leído${unreadCount > 1 ? 's' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implementar videollamada
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implementar menú
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.messagesState == ChatState.loading &&
                    chatProvider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatProvider.messagesState == ChatState.error) {
                  return Center(
                    child: Text(
                      chatProvider.messagesError ?? 'Error al cargar mensajes',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                final messages = chatProvider.messages;

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
                          'Envía un mensaje para comenzar',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    final isMe = message.senderId == currentUserId;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
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
        context.read<ChatProvider>().stopMessagesListener();
      }
    });
    super.dispose();
  }
}
