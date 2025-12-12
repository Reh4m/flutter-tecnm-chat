import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/call_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/calls/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:provider/provider.dart';

class CallButtons extends StatelessWidget {
  final String receiverId;
  final String? conversationId;
  final bool isGroup;
  final List<String>? groupParticipants;

  const CallButtons({
    super.key,
    required this.receiverId,
    this.conversationId,
    this.isGroup = false,
    this.groupParticipants,
  });

  Future<void> _startCall(BuildContext context, CallType type) async {
    final callProvider = context.read<CallProvider>();
    final userProvider = context.read<UserProvider>();

    // Verificar si ya hay una llamada activa
    if (callProvider.isInCall) {
      _showToast(
        context,
        title: 'Llamada activa',
        description: 'Ya tienes una llamada en curso',
        type: ToastNotificationType.warning,
      );
      return;
    }

    bool success;

    if (isGroup && groupParticipants != null) {
      // Llamada grupal
      success = await callProvider.createGroupCall(
        groupId: receiverId,
        participants: groupParticipants!,
        type: type,
      );
    } else {
      // Llamada directa
      success = await callProvider.createCall(
        receiverId: receiverId,
        type: type,
        conversationId: conversationId,
      );
    }

    if (!context.mounted) return;

    if (!success) {
      _showToast(
        context,
        title: 'Error',
        description:
            callProvider.callErrorMessage ?? 'No se pudo iniciar la llamada',
        type: ToastNotificationType.error,
      );
    }

    if (callProvider.currentCall == null) {
      _showToast(
        context,
        title: 'Error',
        description: 'No se pudo iniciar la llamada',
        type: ToastNotificationType.error,
      );
      return;
    }

    // Obtener info del receptor (para mostrar en la pantalla de llamada)
    final receiverUser =
        receiverId != userProvider.currentUser?.id
            ? await userProvider.getUserById(receiverId)
            : null;

    if (!context.mounted) return;

    // Navegar a la pantalla de llamada
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CallScreen(
              call: callProvider.currentCall!,
              otherUser: receiverUser,
            ),
      ),
    );
  }

  void _showToast(
    BuildContext context, {
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón de videollamada
        IconButton(
          icon: const Icon(Icons.videocam),
          tooltip: 'Videollamada',
          onPressed: () => _startCall(context, CallType.video),
        ),
        // Botón de llamada de audio
        IconButton(
          icon: const Icon(Icons.call),
          tooltip: 'Llamada de voz',
          onPressed: () => _startCall(context, CallType.audio),
        ),
      ],
    );
  }
}
