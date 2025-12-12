import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:provider/provider.dart';

class CallHistoryTile extends StatelessWidget {
  final CallEntity call;
  final UserEntity? otherUser;

  const CallHistoryTile({
    super.key,
    required this.call,
    required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentUser = context.read<UserProvider>().currentUser;

    final callDirection = call.getCallDirection(currentUser!.id);

    final callIcon = _getCallIcon(callDirection);
    final callColor = _getCallColor(callDirection);

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withAlpha(50),
            backgroundImage:
                otherUser?.photoUrl != null && otherUser!.photoUrl!.isNotEmpty
                    ? NetworkImage(otherUser!.photoUrl!)
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
          if (call.type == CallType.video)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam,
                  size: 12,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        otherUser?.name ?? 'Usuario desconocido',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Icon(callIcon, size: 16, color: callColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _getSubtitleText(callDirection),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.info_outline,
          color: theme.colorScheme.primary.withAlpha(200),
        ),
      ),
    );
  }

  IconData _getCallIcon(CallDirection callDirection) {
    if (call.status == CallStatus.missed) {
      return callDirection == CallDirection.incoming
          ? Icons.call_missed
          : Icons.call_missed_outgoing;
    }

    if (callDirection == CallDirection.incoming) {
      return Icons.call_received;
    }

    return Icons.call_made;
  }

  Color _getCallColor(CallDirection callDirection) {
    if (call.status == CallStatus.missed &&
        callDirection == CallDirection.incoming) {
      return Colors.red;
    }

    if (call.status == CallStatus.rejected) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String _getSubtitleText(CallDirection callDirection) {
    final buffer = StringBuffer();

    // Estado de la llamada
    if (call.status == CallStatus.missed) {
      if (callDirection == CallDirection.incoming) {
        buffer.write('Llamada perdida');
      } else {
        buffer.write('No contestó');
      }
    } else if (call.status == CallStatus.rejected) {
      if (callDirection == CallDirection.incoming) {
        buffer.write('Rechazada');
      } else {
        buffer.write('Rechazó la llamada');
      }
    } else if (call.status == CallStatus.failed) {
      buffer.write('Llamada fallida');
    } else {
      if (call.duration != null) {
        buffer.write(
          '${callDirection == CallDirection.incoming ? 'Entrante' : 'Saliente'} • ${_formatDuration(call.duration!)}',
        );
      }
    }

    // Agregar fecha/hora
    if (buffer.isNotEmpty) {
      buffer.write(' • ');
    }
    buffer.write(_formatDateTime(call.createdAt));

    return buffer.toString();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds}s';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
