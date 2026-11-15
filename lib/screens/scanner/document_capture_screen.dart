import 'package:flutter/material.dart';
import '../../models/local_document.dart';
import '../../services/document_picker.dart';
import '../../services/document_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
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
      appBar: swissAppBar(context, 'Add document'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: _picked == null ? _buildPickerOptions() : _buildPreview(),
        ),
      ),
    );
  }

  Widget _buildPickerOptions() {
    return ListView(
      children: [
        Text(
          'Add a bill or warranty card.',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 34, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.6),
        ),
        const SizedBox(height: 12),
        Text(
          'Take a photo, pick one from your gallery, or choose a PDF. It is saved on this phone and uploaded when you are online.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 32),
        SwissButton('Take photo', icon: Icons.camera_alt_outlined, onPressed: () => _pick(DocumentPicker.fromCamera)),
        const SizedBox(height: 12),
        SwissButton('Choose from gallery', icon: Icons.photo_library_outlined, outlined: true, onPressed: () => _pick(DocumentPicker.fromGallery)),
        const SizedBox(height: 12),
        SwissButton('Choose file (PDF)', icon: Icons.attach_file, outlined: true, onPressed: () => _pick(DocumentPicker.fromFile)),
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
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.ruleSoft, width: 0.8)),
            clipBehavior: Clip.antiAlias,
            child: doc.isImage
                ? Image.file(doc.file, fit: BoxFit.contain)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf_outlined, color: AppColors.textPrimary, size: 56),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            doc.filename,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        SwissButton('Confirm and save', onPressed: _confirm, loading: _isSaving),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SwissButton('Retake', outlined: true, onPressed: _isSaving ? null : _retake)),
            const SizedBox(width: 12),
            Expanded(child: SwissButton('Cancel', outlined: true, onPressed: _isSaving ? null : () => Navigator.pop(context))),
          ],
        ),
      ],
    );
  }
}
