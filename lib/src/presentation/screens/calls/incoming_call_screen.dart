import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/config/themes/color_palette.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/call_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/calls/index.dart';
import 'package:provider/provider.dart';

class IncomingCallScreen extends StatelessWidget {
  final CallEntity call;
  final UserEntity? caller;

  const IncomingCallScreen({super.key, required this.call, this.caller});

  Future<void> _handleAnswer(BuildContext context, bool withVideo) async {
    final callProvider = context.read<CallProvider>();
    final success = await callProvider.answerCall(withVideo: withVideo);

    if (success && context.mounted) {
      // Navegar a la pantalla de llamada
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call, otherUser: caller),
        ),
      );
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    final callProvider = context.read<CallProvider>();
    await callProvider.rejectCall();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVideoCall = call.type == CallType.video;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Consumer<CallProvider>(
          builder: (_, callProvider, __) {
            if (callProvider.state == CallProviderState.ended) {
              // Cerrar pantalla automáticamente
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
            }

            return Column(
              children: [
                const SizedBox(height: 60),

                // Avatar y nombre del llamante
                CircleAvatar(
                  radius: 80,
                  backgroundColor: theme.colorScheme.surface.withAlpha(50),
                  backgroundImage:
                      caller?.photoUrl != null && caller!.photoUrl!.isNotEmpty
                          ? NetworkImage(caller!.photoUrl!)
                          : null,
                  child:
                      caller?.photoUrl == null || caller!.photoUrl!.isEmpty
                          ? Text(
                            caller?.initials ?? '?',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                          : null,
                ),
                const SizedBox(height: 24),
                Text(
                  caller?.name ?? 'Usuario',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isVideoCall
                      ? 'Videollamada entrante...'
                      : 'Llamada entrante...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),

                const Spacer(),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Rechazar
                    _buildActionButton(
                      theme,
                      icon: Icons.call_end,
                      label: 'Rechazar',
                      color: theme.colorScheme.error,
                      onPressed: () => _handleReject(context),
                    ),

                    // Responder solo con audio (si es videollamada)
                    if (isVideoCall)
                      _buildActionButton(
                        theme,
                        icon: Icons.phone,
                        label: 'Audio',
                        color: ColorPalette.success,
                        onPressed: () => _handleAnswer(context, false),
                      ),

                    // Responder (con video si es videollamada)
                    _buildActionButton(
                      theme,
                      icon: isVideoCall ? Icons.videocam : Icons.phone,
                      label: isVideoCall ? 'Video' : 'Responder',
                      color: ColorPalette.success,
                      onPressed: () => _handleAnswer(context, isVideoCall),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              child: Icon(icon, color: theme.colorScheme.onPrimary, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
