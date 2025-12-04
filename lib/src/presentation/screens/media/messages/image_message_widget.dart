import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageMessageWidget extends StatelessWidget {
  final String imageUrl;
  final String? caption;
  final bool isMe;
  final VoidCallback? onTap;

  const ImageMessageWidget({
    super.key,
    required this.imageUrl,
    this.caption,
    required this.isMe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 250,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    width: 250,
                    height: 250,
                    color: theme.colorScheme.surface.withAlpha(50),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    width: 250,
                    height: 250,
                    color: theme.colorScheme.error.withAlpha(30),
                    child: const Icon(Icons.error_outline),
                  ),
            ),
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              caption!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
