import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/contact_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user_entity.dart';

class ContactListItem extends StatelessWidget {
  final ContactEntity contact;
  final UserEntity? contactUser;
  final VoidCallback onTap;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.contactUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: theme.colorScheme.primary.withAlpha(50),
        backgroundImage:
            contactUser?.photoUrl != null
                ? NetworkImage(contactUser!.photoUrl!)
                : null,
        child:
            contactUser?.photoUrl == null
                ? Text(
                  contactUser?.initials ?? '?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              contactUser?.name ?? 'Usuario',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (contact.isFavorite)
            Icon(Icons.star, size: 18, color: theme.colorScheme.tertiary),
        ],
      ),
      subtitle: Text(
        contactUser?.email ?? '',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(150),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.chat_bubble_outline,
        color: theme.colorScheme.primary,
      ),
      onTap: onTap,
    );
  }
}
