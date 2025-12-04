import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/direct_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/group_chat_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/message_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/direct_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/group_chat_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConversationListItem extends StatelessWidget {
  final DirectChatEntity? directChat;
  final GroupEntity? group;
  final String currentUserId;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    this.directChat,
    this.group,
    required this.currentUserId,
    required this.onTap,
  });

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(time);
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'es').format(time);
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }

  String _lastGroupMessageSender(BuildContext context) {
    final lastMessage = group!.lastMessage;
    final lastMessageType = group!.lastMessageType;

    if (lastMessage == null || lastMessage.isEmpty && lastMessageType == null) {
      return '';
    }

    final groupParticpants = context
        .select<GroupChatProvider, Map<String, UserEntity>>(
          (p) => p.groupParticipants[group!.id] ?? {},
        );

    final sender = groupParticpants[group!.lastMessageSenderId];

    if (sender == null) {
      return group!.lastMessage!;
    }

    return sender.id == currentUserId ? 'Tú' : sender.name;
  }

  String _lastGroupMessagePreview(BuildContext context) {
    final lastMessage = group!.lastMessage;
    final lastMessageType = group!.lastMessageType;

    if (lastMessage == null || lastMessage.isEmpty && lastMessageType == null) {
      return 'Sin mensajes';
    }

    switch (lastMessageType) {
      case MessageType.text:
        return lastMessage;
      case MessageType.image:
        return 'Foto';
      case MessageType.video:
        return 'Video';
      case MessageType.audio:
        return 'Audio';
      case MessageType.document:
        return 'Documento';
      case MessageType.emoji:
        return lastMessage;
      default:
        return lastMessage;
    }
  }

  String _lastDirectMessagePreview() {
    final lastMessage = directChat!.lastMessage;
    final lastMessageType = directChat!.lastMessageType;

    if (lastMessage == null || lastMessage.isEmpty && lastMessageType == null) {
      return 'Sin mensajes';
    }

    switch (lastMessageType) {
      case MessageType.text:
        return lastMessage;
      case MessageType.image:
        return 'Foto';
      case MessageType.video:
        return 'Video';
      case MessageType.audio:
        return 'Audio';
      case MessageType.document:
        return 'Documento';
      case MessageType.emoji:
        return lastMessage;
      default:
        return lastMessage;
    }
  }

  UserEntity? _getDirectChatUserInfo(BuildContext context) {
    final directChatProvider = context.read<DirectChatProvider>();

    final otherUserId = directChatProvider.getParticipantId(
      directChat!,
      currentUserId,
    );

    return otherUserId != null
        ? directChatProvider.getParticipantInfo(otherUserId)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (group != null) {
      return _buildGroupItem(context, theme);
    } else if (directChat != null) {
      return _buildConversationItem(context, theme);
    }

    return const SizedBox.shrink();
  }

  Widget _buildGroupItem(BuildContext context, ThemeData theme) {
    final unreadCount = group!.getUnreadCount(currentUserId);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: theme.colorScheme.secondary.withAlpha(50),
        backgroundImage:
            group!.avatarUrl != null && group!.avatarUrl!.isNotEmpty
                ? NetworkImage(group!.avatarUrl!)
                : null,
        child:
            group!.avatarUrl == null || group!.avatarUrl!.isEmpty
                ? Icon(
                  Icons.group,
                  color: theme.colorScheme.secondary,
                  size: 28,
                )
                : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              group!.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (group!.lastMessageSenderId != null &&
              group!.lastMessageSenderId!.isNotEmpty)
            Text(
              '${_lastGroupMessageSender(context)}: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    unreadCount > 0
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withAlpha(150),
                fontWeight:
                    unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (group!.lastMessageType != null &&
              group!.lastMessageType != MessageType.text) ...[
            _buildMessageTypeIcon(group!.lastMessageType),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              _lastGroupMessagePreview(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    unreadCount > 0
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withAlpha(150),
                fontWeight:
                    unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(group!.lastMessageTime ?? group!.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  unreadCount > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withAlpha(150),
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildConversationItem(BuildContext context, ThemeData theme) {
    final unreadCount = directChat!.getUnreadCount(currentUserId);
    final otherUser = _getDirectChatUserInfo(context);

    final otherUserName = otherUser?.name ?? 'Desconocido';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: theme.colorScheme.primary.withAlpha(50),
        backgroundImage:
            otherUser?.photoUrl != null && otherUser!.photoUrl!.isNotEmpty
                ? NetworkImage(otherUser.photoUrl!)
                : null,
        child:
            otherUser?.photoUrl == null || otherUser!.photoUrl!.isEmpty
                ? Text(
                  otherUser?.initials ?? '?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : null,
      ),
      title: Text(
        otherUserName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (directChat!.lastMessageType != null &&
              directChat!.lastMessageType != MessageType.text) ...[
            _buildMessageTypeIcon(directChat!.lastMessageType),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              _lastDirectMessagePreview(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    unreadCount > 0
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withAlpha(150),
                fontWeight:
                    unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(directChat!.lastMessageTime),
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  unreadCount > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withAlpha(150),
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildMessageTypeIcon(MessageType? type) {
    if (type == null) return const SizedBox.shrink();

    switch (type) {
      case MessageType.text:
        return const SizedBox.shrink();
      case MessageType.image:
        return const Icon(Icons.image, size: 16);
      case MessageType.video:
        return const Icon(Icons.videocam, size: 16);
      case MessageType.audio:
        return const Icon(Icons.audiotrack, size: 16);
      case MessageType.document:
        return const Icon(Icons.insert_drive_file, size: 16);
      case MessageType.emoji:
        return const Icon(Icons.emoji_emotions, size: 16);
    }
  }
}
