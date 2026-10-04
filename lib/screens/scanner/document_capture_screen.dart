import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/local_document.dart';
import '../../services/document_repository.dart';
import '../../theme/app_colors.dart';

/// Capture/pick a document for one asset, preview it, and let the user
/// retake or confirm before it's saved -- never uploads a bad capture
/// automatically. Offers both a real camera capture and file/gallery
/// picking, per the app's documented requirement that both be available.
class DocumentCaptureScreen extends StatefulWidget {
  final String assetId;
  const DocumentCaptureScreen({super.key, required this.assetId});

  @override
  State<DocumentCaptureScreen> createState() => _DocumentCaptureScreenState();
}

class _DocumentCaptureScreenState extends State<DocumentCaptureScreen> {
  File? _pickedFile;
  String? _mimeType;
  bool _isSaving = false;

  Future<void> _fromCamera() => _pickImage(ImageSource.camera);
  Future<void> _fromGallery() => _pickImage(ImageSource.gallery);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? shot = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (shot == null) return; // user cancelled -- not an error
      setState(() {
        _pickedFile = File(shot.path);
        _mimeType = 'image/jpeg';
      });
    } catch (e) {
      if (!mounted) return;
      // Covers permission denied, permission permanently denied, and
      // camera-unavailable -- image_picker surfaces all of these as
      // exceptions rather than distinct states, so one message covers all
      // three without the app crashing.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Could not open the camera. Check that camera permission is granted in Settings.'
                : 'Could not open the gallery. Check that photo access is granted in Settings.',
          ),
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      final path = result?.files.single.path;
      if (path == null) return; // cancelled
      setState(() {
        _pickedFile = File(path);
        _mimeType = _mimeTypeForPath(path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the file picker.')));
    }
  }

  String _mimeTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }

  void _retake() => setState(() {
    _pickedFile = null;
    _mimeType = null;
  });

  Future<void> _confirm() async {
    if (_pickedFile == null || _mimeType == null) return;
    setState(() => _isSaving = true);
    try {
      const maxSize = 10 * 1024 * 1024;
      final size = await _pickedFile!.length();
      if (size > maxSize) {
        throw Exception('File is too large (max 10MB)');
      }

      final LocalDocument doc = await DocumentRepository.captureDocument(
        assetId: widget.assetId,
        pickedFile: _pickedFile!,
        mimeType: _mimeType!,
      );
      if (!mounted) return;
      Navigator.pop(context, doc);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save document: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('ADD DOCUMENT', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _pickedFile == null ? _buildPickerOptions() : _buildPreview(),
        ),
      ),
    );
  }

  Widget _buildPickerOptions() {
    return Column(
      children: [
        const Spacer(),
        const Icon(Icons.description_outlined, color: AppColors.textSecondary, size: 60),
        const SizedBox(height: 16),
        const Text(
          'Scan a bill, warranty card, or insurance paper',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _fromCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('TAKE PHOTO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _fromGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('CHOOSE FROM GALLERY'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.attach_file),
            label: const Text('CHOOSE FILE (PDF)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: Color(0xFF383838)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final isImage = _mimeType?.startsWith('image/') ?? false;

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: isImage
                ? Image.file(_pickedFile!, fit: BoxFit.contain)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary, size: 60),
                        const SizedBox(height: 12),
                        Text(
                          _pickedFile!.path.split('/').last,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _retake,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFF383838)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('RETAKE'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CANCEL'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSaving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('CONFIRM & SAVE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }
}
