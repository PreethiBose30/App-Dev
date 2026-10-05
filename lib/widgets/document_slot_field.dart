import 'package:flutter/material.dart';
import '../services/document_picker.dart';
import '../theme/app_colors.dart';

/// One optional document slot on the add-product form (e.g. "Warranty
/// card", "Invoice"). Picks/validates via the shared DocumentPicker and
/// just holds the result in memory -- nothing is saved until the parent
/// form actually creates the product (there's no asset id to attach to
/// yet).
class DocumentSlotField extends StatelessWidget {
  final String label;
  final PickedDocument? value;
  final ValueChanged<PickedDocument?> onChanged;
  final bool enabled;

  const DocumentSlotField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  Future<void> _pick(BuildContext context, Future<PickedDocument?> Function() picker) async {
    try {
      final doc = await picker();
      if (doc == null) return; // user cancelled
      await DocumentPicker.validate(doc);
      onChanged(doc);
    } on DocumentPickException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          if (value == null) _buildPickRow(context) else _buildPicked(context),
        ],
      ),
    );
  }

  Widget _buildPickRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _pickButton(
            context,
            icon: Icons.camera_alt_outlined,
            label: 'Photo',
            onTap: () => _pick(context, DocumentPicker.fromCamera),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _pickButton(
            context,
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            onTap: () => _pick(context, DocumentPicker.fromGallery),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _pickButton(
            context,
            icon: Icons.attach_file,
            label: 'File',
            onTap: () => _pick(context, DocumentPicker.fromFile),
          ),
        ),
      ],
    );
  }

  Widget _pickButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: Color(0xFF383838)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPicked(BuildContext context) {
    final doc = value!;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: doc.isImage
              ? Image.file(doc.file, fit: BoxFit.cover)
              : Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            doc.filename,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        IconButton(
          tooltip: 'Replace',
          icon: Icon(Icons.swap_horiz, color: AppColors.textSecondary, size: 20),
          onPressed: enabled ? () => _showReplaceOptions(context) : null,
        ),
        IconButton(
          tooltip: 'Remove',
          icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
          onPressed: enabled ? () => onChanged(null) : null,
        ),
      ],
    );
  }

  void _showReplaceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: AppColors.textPrimary),
              title: Text('Take photo', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, DocumentPicker.fromCamera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.textPrimary),
              title: Text('Choose from gallery', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, DocumentPicker.fromGallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_file, color: AppColors.textPrimary),
              title: Text('Choose file (PDF)', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, DocumentPicker.fromFile);
              },
            ),
          ],
        ),
      ),
    );
  }
}
