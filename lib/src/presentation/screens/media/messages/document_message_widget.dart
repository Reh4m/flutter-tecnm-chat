import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentMessageWidget extends StatelessWidget {
  final String documentUrl;
  final String fileName;
  final String? caption;
  final bool isMe;

  const DocumentMessageWidget({
    super.key,
    required this.documentUrl,
    required this.fileName,
    this.caption,
    required this.isMe,
  });

  String _getFileExtension() {
    return fileName.split('.').last.toLowerCase();
  }

  IconData _getDocumentIcon() {
    final fileExtension = _getFileExtension();

    switch (fileExtension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getDocumentColor(ThemeData theme) {
    final fileExtension = _getFileExtension();

    switch (fileExtension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'txt':
        return Colors.grey;
      default:
        return theme.colorScheme.primary;
    }
  }

  Future<void> _openDocument() async {
    final uri = Uri.parse(documentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final documentColor = _getDocumentColor(theme);

    return InkWell(
      onTap: _openDocument,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isMe
                  ? theme.colorScheme.primary.withAlpha(30)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: documentColor.withAlpha(100), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: documentColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getDocumentIcon(),
                    color: documentColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color:
                              isMe
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFileExtension().toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isMe
                                  ? theme.colorScheme.onPrimary.withAlpha(180)
                                  : theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.download, color: documentColor, size: 20),
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
      ),
    );
  }
}
