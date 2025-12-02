import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:intl/intl.dart';

class GroupMessageBubble extends StatelessWidget {
  final MessageEntity message;
  final UserEntity? sender;
  final bool isMe;
  final VoidCallback? onRetry;

  const GroupMessageBubble({
    super.key,
    required this.message,
    this.sender,
    required this.isMe,
    this.onRetry,
  });

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.secondary.withAlpha(50),
              backgroundImage:
                  sender?.photoUrl != null && sender!.photoUrl!.isNotEmpty
                      ? NetworkImage(sender!.photoUrl!)
                      : null,
              child:
                  sender?.photoUrl == null || sender!.photoUrl!.isEmpty
                      ? Text(
                        sender?.initials ?? '?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 8),
          ],
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(theme),
                    borderRadius: BorderRadius.circular(12).copyWith(
                      bottomRight: isMe ? const Radius.circular(4) : null,
                      bottomLeft: !isMe ? const Radius.circular(4) : null,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        Text(
                          sender?.name ?? 'Unknown',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        message.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getTextColor(theme),
                        ),
                      ),
                    ],
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
        ],
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
