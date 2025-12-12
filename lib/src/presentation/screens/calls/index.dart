import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/call_provider.dart';
import 'package:provider/provider.dart';

class CallScreen extends StatefulWidget {
  final CallEntity call;
  final UserEntity? otherUser;

  const CallScreen({super.key, required this.call, this.otherUser});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _renderersInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      if (mounted) {
        setState(() {
          _renderersInitialized = true;
        });

        // Asignar streams después de inicializar
        final callProvider = context.read<CallProvider>();
        _updateRenderers(callProvider);
      }
    } catch (e) {
      print('Error initializing renderers: $e');
    }
  }

  void _updateRenderers(CallProvider callProvider) {
    if (!_renderersInitialized) return;

    try {
      if (callProvider.localStream != null &&
          _localRenderer.srcObject != callProvider.localStream) {
        _localRenderer.srcObject = callProvider.localStream;
      }
      if (callProvider.remoteStream != null &&
          _remoteRenderer.srcObject != callProvider.remoteStream) {
        _remoteRenderer.srcObject = callProvider.remoteStream;
      }
    } catch (e) {
      print('Error updating renderers: $e');
    }
  }

  Future<void> _handleEndCall() async {
    final callProvider = context.read<CallProvider>();
    await callProvider.endCall();
  }

  @override
  void dispose() {
    _renderersInitialized = false;
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CallProvider>(
        builder: (_, callProvider, __) {
          if (callProvider.state == CallProviderState.ended) {
            // Cerrar pantalla automáticamente
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            });
          }

          // Actualizar renderers cuando cambien los streams
          if (_renderersInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateRenderers(callProvider);
            });
          }

          final isVideoCalling = widget.call.type == CallType.video;

          return Stack(
            children: [
              if (isVideoCalling && callProvider.remoteStream != null)
                Positioned.fill(
                  child: RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                )
              else
                _buildAudioCallBackground(theme, callProvider.state),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(child: _buildUserInfo(theme)),
              ),

              if (callProvider.state == CallProviderState.calling &&
                  isVideoCalling &&
                  callProvider.isVideoEnable &&
                  callProvider.localStream != null)
                Positioned(
                  top: 100,
                  right: 16,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.onPrimary,
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: RTCVideoView(
                      _localRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      mirror: true,
                    ),
                  ),
                ),

              // Controles en la parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildControls(theme, callProvider, isVideoCalling),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAudioCallBackground(
    ThemeData theme,
    CallProviderState callState,
  ) {
    return Container(
      color: theme.colorScheme.primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: theme.colorScheme.surface.withAlpha(50),
              backgroundImage:
                  widget.otherUser?.photoUrl != null &&
                          widget.otherUser!.photoUrl!.isNotEmpty
                      ? NetworkImage(widget.otherUser!.photoUrl!)
                      : null,
              child:
                  widget.otherUser?.photoUrl == null ||
                          widget.otherUser!.photoUrl!.isEmpty
                      ? Text(
                        widget.otherUser?.initials ?? '?',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 24),
            Text(
              widget.otherUser?.name ?? 'Usuario',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getCallStateText(callState),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.surface.withAlpha(50),
                backgroundImage:
                    widget.otherUser?.photoUrl != null &&
                            widget.otherUser!.photoUrl!.isNotEmpty
                        ? NetworkImage(widget.otherUser!.photoUrl!)
                        : null,
                child:
                    widget.otherUser?.photoUrl == null ||
                            widget.otherUser!.photoUrl!.isEmpty
                        ? Text(
                          widget.otherUser?.initials ?? '?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.otherUser?.name ?? 'Usuario',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
    ThemeData theme,
    CallProvider callProvider,
    bool isVideoCalling,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute
          _buildControlButton(
            theme,
            icon: callProvider.isMuted ? Icons.mic_off : Icons.mic,
            label: callProvider.isMuted ? 'Desmuteado' : 'Muteado',
            onPressed: callProvider.toggleMute,
            backgroundColor: theme.colorScheme.surface.withAlpha(50),
          ),

          // Video (solo en videollamadas)
          if (isVideoCalling)
            _buildControlButton(
              theme,
              icon:
                  callProvider.isVideoEnable
                      ? Icons.videocam
                      : Icons.videocam_off,
              label: callProvider.isVideoEnable ? 'Cámara On' : 'Cámara Off',
              onPressed: callProvider.toggleVideo,
              backgroundColor: theme.colorScheme.surface.withAlpha(50),
            ),

          // Colgar
          _buildControlButton(
            theme,
            icon: Icons.call_end,
            label: 'Colgar',
            onPressed: _handleEndCall,
            backgroundColor: theme.colorScheme.error,
            size: 64,
          ),

          // Altavoz
          _buildControlButton(
            theme,
            icon:
                callProvider.isSpeakerEnabled
                    ? Icons.volume_up
                    : Icons.volume_down,
            label: callProvider.isSpeakerEnabled ? 'Altavoz On' : 'Altavoz Off',
            onPressed: callProvider.toggleSpeaker,
            backgroundColor: theme.colorScheme.surface.withAlpha(50),
          ),

          // Cambiar cámara (solo en videollamadas)
          if (isVideoCalling)
            _buildControlButton(
              theme,
              icon: Icons.flip_camera_ios,
              label: 'Girar',
              onPressed: callProvider.switchCamera,
              backgroundColor: theme.colorScheme.surface.withAlpha(50),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    double size = 56,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimary,
                size: size * 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12),
        ),
      ],
    );
  }

  String _getCallStateText(CallProviderState state) {
    switch (state) {
      case CallProviderState.loading:
        return 'Iniciando...';
      case CallProviderState.calling:
        return 'Llamando...';
      case CallProviderState.inCall:
        return 'En llamada...';
      case CallProviderState.ended:
        return 'Llamada finalizada';
      default:
        return '';
    }
  }
}
