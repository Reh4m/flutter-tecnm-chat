import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/contacts_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/direct_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/contacts/widgets/contact_list_item.dart';
import 'package:flutter_whatsapp_clon/src/presentation/utils/toast_notification.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  void _showToast({
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contactos',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
        ],
      ),
      body: Consumer2<ContactsProvider, DirectChatProvider>(
        builder: (context, contactsProvider, directChatProvider, _) {
          if (contactsProvider.contactsState == ContactsState.loading &&
              contactsProvider.contacts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (contactsProvider.contactsState == ContactsState.error) {
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
                    contactsProvider.contactsError ?? 'Error desconocido',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final contacts = contactsProvider.contacts;

          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes contactos',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Agrega contactos para empezar a chatear',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final contactUser = contactsProvider.getContactUser(
                  contact.contactUserId,
                );

                return ContactListItem(
                  contact: contact,
                  contactUser: contactUser,
                  onTap: () async {
                    final currentUserId =
                        context.read<UserProvider>().currentUser?.id;
                    if (currentUserId == null) return;

                    final conversation = await directChatProvider
                        .getOrCreateDirectConversation(
                          userId1: currentUserId,
                          userId2: contact.contactUserId,
                        );

                    if (conversation != null && mounted) {
                      context.push('/chat/${conversation.id}');
                    } else if (mounted) {
                      _showToast(
                        title: 'Error',
                        description: 'No se pudo crear la conversación',
                        type: ToastNotificationType.error,
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-contact');
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
