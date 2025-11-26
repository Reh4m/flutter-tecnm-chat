import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final hasPermission = await _requestPermission(source);

      if (!hasPermission) {
        if (context.mounted) {
          _showPermissionDeniedDialog(context, source);
        }

        return null;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
      return null;
    }
  }

  static Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          final status = await Permission.photos.request();
          return status.isGranted;
        } else {
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
      return true;
    }
  }

  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+), se usa Permission.photos
      // Para versiones anteriores, Permission.storage
      return 33;
    }
    return 0;
  }

  static void _showPermissionDeniedDialog(
    BuildContext context,
    ImageSource source,
  ) {
    final permissionName = source == ImageSource.camera ? 'cámara' : 'galería';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permiso denegado'),
            content: Text(
              'Necesitas conceder permiso de $permissionName para continuar. '
              '¿Deseas abrir la configuración?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Abrir configuración'),
              ),
            ],
          ),
    );
  }

  static Future<void> showImageSourceDialog(
    BuildContext context, {
    required Function(File?) onImageSelected,
  }) async {
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withAlpha(50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Seleccionar imagen',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(
                      Icons.camera_alt,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Tomar foto'),
                    onTap: () async {
                      Navigator.pop(context);
                      final image = await pickImage(
                        context,
                        source: ImageSource.camera,
                      );
                      onImageSelected(image);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Seleccionar de galería'),
                    onTap: () async {
                      Navigator.pop(context);
                      final image = await pickImage(
                        context,
                        source: ImageSource.gallery,
                      );
                      onImageSelected(image);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
    );
  }
}
