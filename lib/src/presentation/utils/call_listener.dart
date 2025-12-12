import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart' as di;
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/call_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/calls/incoming_call_screen.dart';
import 'package:provider/provider.dart';

class CallListener extends StatefulWidget {
  final Widget child;

  const CallListener({super.key, required this.child});

  @override
  State<CallListener> createState() => _CallListenerState();
}

class _CallListenerState extends State<CallListener> {
  final _firebaseAuth = di.sl<FirebaseAuth>();
  late final CallProvider _callProvider;

  @override
  void initState() {
    super.initState();
    _callProvider = context.read<CallProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _callProvider.initialize();
        // Escuchar cambios en el estado de las llamadas
        _callProvider.addListener(_onCallStateChanged);
      }
    });
  }

  void _onCallStateChanged() {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return;

    final currentCall = _callProvider.currentCall;
    if (currentCall == null) return;

    final callDirection = currentCall.getCallDirection(currentUserId);

    // Si hay una llamada entrante y no estamos ya en una llamada
    if (_callProvider.state == CallProviderState.calling &&
        callDirection == CallDirection.incoming) {
      _showIncomingCallScreen();
    }
  }

  Future<void> _showIncomingCallScreen() async {
    final call = _callProvider.currentCall;

    if (call == null) return;

    // Obtener información del llamante
    final userProvider = context.read<UserProvider>();
    final caller = await userProvider.getUserById(call.callerId);

    if (!mounted) return;

    // Mostrar pantalla de llamada entrante
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(call: call, caller: caller),
      ),
    );
  }

  @override
  void dispose() {
    _callProvider.removeListener(_onCallStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
