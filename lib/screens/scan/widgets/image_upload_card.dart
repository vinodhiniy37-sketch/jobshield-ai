import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';

class ImageUploadCard extends StatefulWidget {
  final XFile? selectedFile;
  final Uint8List? selectedImageBytes;
  final Function(XFile? file, Uint8List? bytes) onImageChanged;

  const ImageUploadCard({
    Key? key,
    required this.selectedFile,
    required this.selectedImageBytes,
    required this.onImageChanged,
  }) : super(key: key);

  @override
  State<ImageUploadCard> createState() => _ImageUploadCardState();
}

class _ImageUploadCardState extends State<ImageUploadCard> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file != null) {
        // Validation: Verify if the file is an image by checking the extension
        final nameLower = file.name.toLowerCase();
        final isImage = nameLower.endsWith('.png') ||
                        nameLower.endsWith('.jpg') ||
                        nameLower.endsWith('.jpeg') ||
                        nameLower.endsWith('.gif') ||
                        nameLower.endsWith('.webp') ||
                        nameLower.endsWith('.bmp');
        
        if (!isImage) {
          _showError('Invalid file type. Please select an image (PNG, JPG, JPEG, WEBP).');
          return;
        }

        final bytes = await file.readAsBytes();
        
        // Validation: Limit to 10MB
        if (bytes.length > 10 * 1024 * 1024) {
          _showError('File is too large. Limit is 10MB.');
          return;
        }

        widget.onImageChanged(file, bytes);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (e.toString().contains('permission') || e.toString().contains('access')) {
        _showError('Permission denied. Unable to access the camera or gallery.');
      } else {
        _showError('Unable to capture or select image. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Image Source',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                  title: const Text('Select from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  title: const Text('Capture with Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.selectedFile != null && widget.selectedImageBytes != null) {
      // Display actual selected image preview
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rounded Image Preview Container
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Container(
                height: 200,
                width: double.infinity,
                color: isDark ? Colors.black26 : Colors.grey[100],
                child: Image.memory(
                  widget.selectedImageBytes!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black26,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image_rounded, size: 40, color: AppColors.danger),
                          const SizedBox(height: 8),
                          const Text(
                            'Unable to preview file',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Invalid or corrupted image format.',
                            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Actions Toolbar (Change / Remove)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedFile!.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _showSourcePicker,
                    icon: const Icon(Icons.sync_rounded, size: 16, color: AppColors.primary),
                    label: const Text(
                      'Change',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => widget.onImageChanged(null, null),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                    label: const Text(
                      'Remove',
                      style: TextStyle(fontSize: 12, color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Empty display: Dashed Card "Upload Job Screenshot"
    return InkWell(
      onTap: _showSourcePicker,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
            style: BorderStyle.solid, // Simple M3 solid border with primary tint
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload Job Screenshot',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select from Gallery or capture with Camera',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
