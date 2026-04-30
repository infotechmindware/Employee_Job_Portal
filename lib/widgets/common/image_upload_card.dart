import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ImageUploadCard extends StatefulWidget {
  final String label;
  final String? subLabel;
  final Function(File?) onImageSelected;
  final File? initialImage;

  const ImageUploadCard({
    super.key,
    required this.label,
    this.subLabel,
    required this.onImageSelected,
    this.initialImage,
  });

  @override
  State<ImageUploadCard> createState() => _ImageUploadCardState();
}

class _ImageUploadCardState extends State<ImageUploadCard> {
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() => _selectedImage = file);
        widget.onImageSelected(file);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromFile() async {
    try {
      setState(() => _isLoading = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        setState(() => _selectedImage = file);
        widget.onImageSelected(file);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
    widget.onImageSelected(null);
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionItem(
                  icon: LucideIcons.camera,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildOptionItem(
                  icon: LucideIcons.image,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildOptionItem(
                  icon: LucideIcons.folder,
                  label: 'Files',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromFile();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectedImage == null ? _showOptions : null,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedImage != null
                    ? const Color(0xFF6366F1).withOpacity(0.2)
                    : const Color(0xFFE2E8F0),
                style: _selectedImage != null ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)))
                : _selectedImage != null
                    ? _buildPreview()
                    : _buildPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.uploadCloud, size: 24, color: Color(0xFF6366F1)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Upload Image',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6366F1),
          ),
        ),
        if (widget.subLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.subLabel!,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ],
    );
  }

  Widget _buildPreview() {
    return Stack(
      children: [
        // Layered preview: Background blurred (to fill space) + Foreground crisp (to show full image)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Blurred Background (fills card)
              Image.file(
                _selectedImage!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              // Blur Effect
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              // Foreground Image (contains full image, no crop)
              Center(
                child: Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: [
              _buildSmallActionBtn(
                icon: LucideIcons.refreshCcw,
                onTap: _showOptions,
                tooltip: 'Change',
              ),
              const SizedBox(width: 8),
              _buildSmallActionBtn(
                icon: LucideIcons.trash2,
                onTap: _removeImage,
                tooltip: 'Remove',
                isDestructive: true,
              ),
            ],
          ),
        ),
        const Positioned(
          bottom: 12,
          left: 12,
          child: Row(
            children: [
              Icon(LucideIcons.checkCircle2, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Selected',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallActionBtn({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFEF4444).withOpacity(0.9) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
          ],
        ),
        child: Icon(
          icon,
          size: 14,
          color: isDestructive ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }
}
