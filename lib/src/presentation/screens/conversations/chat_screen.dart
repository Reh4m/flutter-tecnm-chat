import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/message_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/direct_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/media_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/widgets/call_buttons.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/widgets/direct_message_bubble.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/widgets/chat_input.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/media/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/image_picker_service.dart';
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

  late final MessageProvider _messageProvider;
  late final DirectChatProvider _directChatProvider;
  late final UserProvider _userProvider;
  late final MediaProvider _mediaProvider;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    _messageProvider = context.read<MessageProvider>();
    _directChatProvider = context.read<DirectChatProvider>();
    _userProvider = context.read<UserProvider>();
    _mediaProvider = context.read<MediaProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _messageProvider.startMessagesListener(widget.conversationId);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = _userProvider.currentUser?.id;
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

    final success = await _directChatProvider.sendMessage(message);

    if (!success && mounted) {
      _showToast(
        title: 'Error',
        description:
            _directChatProvider.operationError ??
            'No se pudo enviar el mensaje',
        type: ToastNotificationType.error,
      );
    }
  }

  Future<void> _handleAttachmentTap() async {
    await ImagePickerService.showMediaPickerDialog(
      context,
      onMediaSelected: (file, mediaType) async {
        if (file == null) return;

        // Mostrar preview
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    MediaPreviewScreen(file: file, mediaType: mediaType),
          ),
        );

        if (result == null) return;

        final File selectedFile = result['file'];
        final String caption = result['caption'] ?? '';

        // Subir archivo según su tipo
        await _uploadAndSendMedia(
          file: selectedFile,
          mediaType: mediaType,
          caption: caption,
        );
      },
    );
  }

  Future<void> _uploadAndSendMedia({
    required File file,
    required MediaType mediaType,
    required String caption,
  }) async {
    final currentUserId = _userProvider.currentUser?.id;
    if (currentUserId == null) return;

    String? mediaUrl;

    // Subir el archivo según su tipo
    switch (mediaType) {
      case MediaType.image:
        mediaUrl = await _mediaProvider.uploadImage(
          image: file,
          conversationId: widget.conversationId,
          senderId: currentUserId,
        );
        break;
      case MediaType.video:
        mediaUrl = await _mediaProvider.uploadVideo(
          video: file,
          conversationId: widget.conversationId,
          senderId: currentUserId,
        );
        break;
      case MediaType.audio:
        mediaUrl = await _mediaProvider.uploadAudio(
          audio: file,
          conversationId: widget.conversationId,
          senderId: currentUserId,
        );
        break;
      case MediaType.document:
        final fileExtension = ImagePickerService.getFileExtension(file);
        mediaUrl = await _mediaProvider.uploadDocument(
          document: file,
          conversationId: widget.conversationId,
          senderId: currentUserId,
          fileExtension: fileExtension,
        );
        break;
    }

    if (mediaUrl == null && mounted) {
      _showToast(
        title: 'Error',
        description: _mediaProvider.error ?? 'No se pudo subir el archivo',
        type: ToastNotificationType.error,
      );
      return;
    }

    // Crear y enviar mensaje
    final messageType = _getMessageType(mediaType);
    final messageContent =
        mediaType == MediaType.document
            ? ImagePickerService.getFileName(file)
            : caption;

    final message = MessageEntity(
      id: '',
      conversationId: widget.conversationId,
      senderId: currentUserId,
      type: messageType,
      content: messageContent,
      mediaUrl: mediaUrl,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    final success = await _directChatProvider.sendMessage(message);

    if (!success && mounted) {
      _showToast(
        title: 'Error',
        description:
            _directChatProvider.operationError ??
            'No se pudo enviar el mensaje',
        type: ToastNotificationType.error,
      );
    }
  }

  MessageType _getMessageType(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return MessageType.image;
      case MediaType.video:
        return MessageType.video;
      case MediaType.audio:
        return MessageType.audio;
      case MediaType.document:
        return MessageType.document;
    }
  }

  Future<void> _retryMessage(MessageEntity message) async {
    final success = await _directChatProvider.retryFailedMessage(message);

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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    _messageProvider.stopMessagesListener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<DirectChatProvider, MessageProvider>(
      builder: (_, directChatProvider, messageProvider, __) {
        if (messageProvider.messagesState == MessageState.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final conversation =
            directChatProvider.chats
                .where((c) => c.id == widget.conversationId)
                .firstOrNull;

        if (conversation == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'No se pudo cargar la conversación',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        final currentUserId = _userProvider.currentUser?.id;

        if (currentUserId == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Usuario no autenticado',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        final otherUserId = directChatProvider.getParticipantId(
          conversation,
          currentUserId,
        );
        final otherUser =
            otherUserId != null
                ? directChatProvider.getParticipantInfo(otherUserId)
                : null;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Row(
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
            ),
            actions: [
              CallButtons(
                receiverId: otherUserId!,
                conversationId: widget.conversationId,
                isGroup: false,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Builder(
                  builder: (_) {
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
                            const SizedBox(height: 5),
                            Text(
                              'Envía un mensaje para comenzar',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(
                                  150,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final currentUserId = _userProvider.currentUser?.id;

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUserId;

                        return DirectMessageBubble(
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
                onAttachment: _handleAttachmentTap,
              ),
            ],
          ),
        );
      },
    );
  }
}
