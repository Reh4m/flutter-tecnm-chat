import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/notification_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NotificationHandler extends StatefulWidget {
  final Widget child;

  const NotificationHandler({super.key, required this.child});

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  @override
  void initState() {
    super.initState();
    _setupNotificationHandler();
  }

  void _setupNotificationHandler() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = context.read<NotificationProvider>();

      // Configurar callback para navegación
      notificationProvider.onNotificationTapped = _navigateToChat;
    });
  }

  void _navigateToChat(String conversationId, bool isGroup) {
    if (!mounted) return;

    if (isGroup) {
      context.push('/group-chat/$conversationId');
    } else {
      context.push('/chat/$conversationId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
