import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/media/messages/audio_message_widget.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/media/messages/document_message_widget.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/media/messages/image_message_widget.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/media/messages/video_message_widget.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/media/viewers/full_screen_image_viewer.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/media/viewers/full_screen_video_viewer.dart';
import 'package:intl/intl.dart';

class DirectMessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final VoidCallback? onRetry;

  const DirectMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onRetry,
  });

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  void _openImageViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenImageViewer(
              imageUrl: message.mediaUrl!,
              caption: message.content.isNotEmpty ? message.content : null,
            ),
      ),
    );
  }

  void _openVideoViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenVideoViewer(
              videoUrl: message.mediaUrl!,
              caption: message.content.isNotEmpty ? message.content : null,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: _getMessagePadding(),
              constraints: BoxConstraints(maxWidth: screenSize.width * 0.75),
              decoration: BoxDecoration(
                color: _getBackgroundColor(theme),
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : null,
                  bottomLeft: !isMe ? const Radius.circular(4) : null,
                ),
              ),
              child: _buildMessageContent(context, theme),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.status == MessageStatus.failed && isMe) ...[
                  InkWell(
                    onTap: onRetry,
                    child: Icon(
                      Icons.error_outline,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  _formatTime(message.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getTimeColor(theme),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(theme),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _getMessagePadding() {
    if (message.type == MessageType.text || message.type == MessageType.emoji) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }
    return EdgeInsets.zero;
  }

  Widget _buildMessageContent(BuildContext context, ThemeData theme) {
    switch (message.type) {
      case MessageType.text:
      case MessageType.emoji:
        return Text(
          message.content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _getTextColor(theme),
            fontSize: message.type == MessageType.emoji ? 32 : null,
          ),
        );

      case MessageType.image:
        return ImageMessageWidget(
          imageUrl: message.mediaUrl!,
          caption: message.content.isNotEmpty ? message.content : null,
          isMe: isMe,
          onTap: () => _openImageViewer(context),
        );

      case MessageType.video:
        return VideoMessageWidget(
          videoUrl: message.mediaUrl!,
          thumbnailUrl: message.thumbnailUrl,
          caption: message.content.isNotEmpty ? message.content : null,
          isMe: isMe,
          onTap: () => _openVideoViewer(context),
        );

      case MessageType.audio:
        return AudioMessageWidget(
          audioUrl: message.mediaUrl!,
          caption: message.content.isNotEmpty ? message.content : null,
          isMe: isMe,
        );

      case MessageType.document:
        return DocumentMessageWidget(
          documentUrl: message.mediaUrl!,
          fileName: message.content,
          caption: null,
          isMe: isMe,
        );
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (message.status == MessageStatus.failed && isMe) {
      return theme.colorScheme.error.withAlpha(30);
    }

    // Para multimedia, usar fondo transparente o más sutil
    if (message.type != MessageType.text && message.type != MessageType.emoji) {
      return Colors.transparent;
    }

    return isMe ? theme.colorScheme.primary : theme.colorScheme.surface;
  }

  Color _getTextColor(ThemeData theme) {
    if (message.status == MessageStatus.failed && isMe) {
      return theme.colorScheme.error;
    }
    return isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
  }

  Color _getTimeColor(ThemeData theme) {
    if (message.status == MessageStatus.failed && isMe) {
      return theme.colorScheme.error.withAlpha(180);
    }

    return theme.colorScheme.onSurface.withAlpha(150);
  }

  Widget _buildStatusIcon(ThemeData theme) {
    Color iconColor =
        message.status == MessageStatus.failed
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface.withAlpha(150);

    switch (message.status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 16, color: iconColor);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 16, color: iconColor);
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 16,
          color: theme.colorScheme.secondary,
        );
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 16, color: iconColor);
    }
  }
}
