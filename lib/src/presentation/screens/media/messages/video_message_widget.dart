import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoMessageWidget extends StatelessWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final String? caption;
  final bool isMe;
  final VoidCallback? onTap;

  const VideoMessageWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
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
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    thumbnailUrl != null
                        ? CachedNetworkImage(
                          imageUrl: thumbnailUrl!,
                          width: 250,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                width: 250,
                                height: 200,
                                color: theme.colorScheme.surface.withAlpha(50),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                width: 250,
                                height: 200,
                                color: theme.colorScheme.surface.withAlpha(100),
                                child: const Icon(Icons.videocam, size: 48),
                              ),
                        )
                        : Container(
                          width: 250,
                          height: 200,
                          color: theme.colorScheme.surface.withAlpha(100),
                          child: const Icon(Icons.videocam, size: 48),
                        ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
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
