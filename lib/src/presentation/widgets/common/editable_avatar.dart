import 'dart:io';
import 'package:flutter/material.dart';

class EditableAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final String initials;
  final double radius;
  final VoidCallback onTap;
  final bool showEditIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const EditableAvatar({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.initials,
    this.radius = 60,
    required this.onTap,
    this.showEditIcon = true,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: CircleAvatar(
              radius: radius,
              backgroundColor:
                  backgroundColor ?? theme.colorScheme.primary.withAlpha(50),
              backgroundImage: _getBackgroundImage(),
              child: _getChild(theme),
            ),
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor ?? theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }
    return null;
  }

  Widget? _getChild(ThemeData theme) {
    if (imageFile == null && (imageUrl == null || imageUrl!.isEmpty)) {
      return Text(
        initials,
        style: theme.textTheme.headlineLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return null;
  }
}
