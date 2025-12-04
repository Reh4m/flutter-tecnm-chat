import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

enum MediaType { image, video, audio, document }

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickDocument() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
        ],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickAudio() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> showImageSourceDialog(
    BuildContext context, {
    required Function(File?) onImageSelected,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await pickImageFromGallery();
                    onImageSelected(image);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Cámara'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await pickImageFromCamera();
                    onImageSelected(image);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showMediaPickerDialog(
    BuildContext context, {
    required Function(File?, MediaType) onMediaSelected,
  }) async {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Seleccionar archivo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.photo, color: theme.colorScheme.primary),
                title: const Text('Foto'),
                subtitle: const Text('Desde galería o cámara'),
                onTap: () {
                  Navigator.pop(context);
                  showImageSourceDialog(
                    context,
                    onImageSelected: (file) {
                      onMediaSelected(file, MediaType.image);
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: theme.colorScheme.primary),
                title: const Text('Video'),
                subtitle: const Text('Desde galería o cámara'),
                onTap: () async {
                  Navigator.pop(context);
                  final video = await pickVideoFromGallery();
                  onMediaSelected(video, MediaType.video);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.insert_drive_file,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Documento'),
                subtitle: const Text('PDF, Word, Excel, etc.'),
                onTap: () async {
                  Navigator.pop(context);
                  final document = await pickDocument();
                  onMediaSelected(document, MediaType.document);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.audiotrack,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Audio'),
                subtitle: const Text('Archivos de audio'),
                onTap: () async {
                  Navigator.pop(context);
                  final audio = await pickAudio();
                  onMediaSelected(audio, MediaType.audio);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  static String getFileName(File file) {
    return file.path.split('/').last;
  }
}
