import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversation_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConversationListItem extends StatelessWidget {
  final ConversationEntity conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'es').format(time);
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = conversation.getUnreadCount(currentUserId);

    return Consumer<ConversationsProvider>(
      builder: (context, conversationsProvider, _) {
        Widget leadingWidget;
        String title;

        if (conversation.isDirect) {
          final otherUserId = conversationsProvider.getOtherUserId(
            conversation,
            currentUserId,
          );
          final otherUser =
              otherUserId != null
                  ? conversationsProvider.getConversationUser(otherUserId)
                  : null;

          title = otherUser?.name ?? 'Usuario';

          leadingWidget = CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withAlpha(50),
            backgroundImage:
                otherUser?.photoUrl != null
                    ? NetworkImage(otherUser!.photoUrl!)
                    : null,
            child:
                otherUser?.photoUrl == null
                    ? Text(
                      otherUser?.initials ?? '?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          );
        } else {
          title = conversation.groupName ?? 'Grupo';

          leadingWidget = CircleAvatar(
            radius: 28,
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
                      size: 28,
                    )
                    : null,
          );
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: leadingWidget,
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            conversation.lastMessage ?? 'Sin mensajes',
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  unreadCount > 0
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withAlpha(150),
              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(conversation.lastMessageTime),
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      unreadCount > 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withAlpha(150),
                  fontWeight:
                      unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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
      },
    );
  }
}
