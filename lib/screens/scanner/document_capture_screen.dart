import 'package:flutter/material.dart';
import '../../models/local_document.dart';
import '../../services/document_picker.dart';
import '../../services/document_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';

/// Capture/pick a document for one asset, preview it, and let the user
/// retake or confirm before it's saved -- never uploads a bad capture
/// automatically. Offers both a real camera capture and file/gallery
/// picking, per the app's documented requirement that both be available.
/// The actual picking/mime-detection/validation is shared with the
/// optional document slots on the add-product form -- see DocumentPicker.
class DocumentCaptureScreen extends StatefulWidget {
  final String assetId;
  const DocumentCaptureScreen({super.key, required this.assetId});

  @override
  State<DocumentCaptureScreen> createState() => _DocumentCaptureScreenState();
}

class _DocumentCaptureScreenState extends State<DocumentCaptureScreen> with ThemeAwareState {
  PickedDocument? _picked;
  bool _isSaving = false;

  Future<void> _pick(Future<PickedDocument?> Function() picker) async {
    try {
      final doc = await picker();
      if (doc == null) return; // user cancelled
      await DocumentPicker.validate(doc);
      setState(() => _picked = doc);
    } on DocumentPickException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _retake() => setState(() => _picked = null);

  Future<void> _confirm() async {
    if (_picked == null) return;
    setState(() => _isSaving = true);
    try {
      final LocalDocument doc = await DocumentRepository.captureDocument(
        assetId: widget.assetId,
        pickedFile: _picked!.file,
        mimeType: _picked!.mimeType,
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
        title: Text('ADD DOCUMENT', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _picked == null ? _buildPickerOptions() : _buildPreview(),
        ),
      ),
    );
  }

  Widget _buildPickerOptions() {
    return Column(
      children: [
        const Spacer(),
        Icon(Icons.description_outlined, color: AppColors.textSecondary, size: 60),
        const SizedBox(height: 16),
        Text(
          'Scan a bill, warranty card, or insurance paper',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _pick(DocumentPicker.fromCamera),
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
            onPressed: () => _pick(DocumentPicker.fromGallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('CHOOSE FROM GALLERY'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pick(DocumentPicker.fromFile),
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
    final doc = _picked!;

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: doc.isImage
                ? Image.file(doc.file, fit: BoxFit.contain)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary, size: 60),
                        const SizedBox(height: 12),
                        Text(
                          doc.filename,
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
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
