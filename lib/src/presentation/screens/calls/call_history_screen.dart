import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/call_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/calls/widgets/call_history_tile.dart';
import 'package:provider/provider.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<CallProvider>(
          builder: (_, callProvider, __) {
            if (callProvider.callHistoryState == CallHistoryState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (callProvider.callHistoryState == CallHistoryState.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar llamadas',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      callProvider.callHistoryErrorMessage ??
                          'Error desconocido',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final calls = callProvider.callHistory;

            // Lista vacía
            if (calls.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.call_outlined,
                      size: 80,
                      color: theme.colorScheme.primary.withAlpha(100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay llamadas recientes',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tus llamadas aparecerán aquí',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              );
            }

            final callHistoryUsers = callProvider.callHistoryUsers;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 20),
                  _buildTitle(theme),
                  const SizedBox(height: 5),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: calls.length,
                    itemBuilder: (context, index) {
                      final call = calls[index];

                      return CallHistoryTile(
                        call: call,
                        otherUser: callHistoryUsers[call.id],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        'Llamadas',
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
