import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onRetry,
  });

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(theme),
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomRight: isMe ? const Radius.circular(4) : null,
            bottomLeft: !isMe ? const Radius.circular(4) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getTextColor(theme),
              ),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getTimeColor(theme),
                    fontSize: 11,
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

  Color _getBackgroundColor(ThemeData theme) {
    if (message.status == MessageStatus.failed && isMe) {
      return theme.colorScheme.error.withAlpha(30);
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
    return isMe
        ? theme.colorScheme.onPrimary.withAlpha(180)
        : theme.colorScheme.onSurface.withAlpha(150);
  }

  Widget _buildStatusIcon(ThemeData theme) {
    Color iconColor =
        message.status == MessageStatus.failed
            ? theme.colorScheme.error
            : theme.colorScheme.onPrimary.withAlpha(180);

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
