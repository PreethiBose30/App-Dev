import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/asset_repository.dart';
import '../../services/api_client.dart';
import '../../services/document_picker.dart';
import '../../services/document_repository.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/document_slot_field.dart';

class AddProductScreen extends StatefulWidget {
  /// When non-null, the screen edits this product (PUT) instead of creating
  /// a new one (POST).
  final Product? existing;

  /// Optional prefill for the notes field -- used by the OCR scan flow so
  /// extracted document text isn't just shown once and discarded.
  final String? initialNotes;

  const AddProductScreen({super.key, this.existing, this.initialNotes});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> with ThemeAwareState {
  late final _nameController = TextEditingController(text: widget.existing?.name ?? '');
  late final _brandController = TextEditingController(text: widget.existing?.brand ?? '');
  late final _modelController = TextEditingController(text: widget.existing?.modelNumber ?? '');
  late final _priceController = TextEditingController(text: widget.existing?.price?.toString() ?? '');
  late final _warrantyController = TextEditingController(text: widget.existing?.warrantyDuration?.toString() ?? '');
  late final _notesController = TextEditingController(text: widget.existing?.notes ?? widget.initialNotes ?? '');

  late String _selectedCategory = widget.existing?.category ?? 'Phone';

  late DateTime? _purchaseDate = widget.existing?.purchaseDate;
  late DateTime? _serviceDate = widget.existing?.serviceDate;

  late bool _reminderEnabled = widget.existing?.reminderEnabled ?? false;
  bool _isSaving = false;

  // Optional document slots -- only offered when creating a new product
  // (editing manages documents from the product's Files tab instead).
  PickedDocument? _warrantyCardDoc;
  PickedDocument? _invoiceDoc;

  bool get _isEditing => widget.existing != null;

  final List<String> _categories = [
    'Phone',
    'Laptop',
    'TV',
    'Car',
    'Appliance',
    'Furniture',
    'Other',
  ];

  Future<void> _pickDate({required bool isPurchaseDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.onAccent,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _serviceDate = picked;
        }
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the product name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final int? warrantyMonths = int.tryParse(_warrantyController.text.trim());

      final product = Product(
        id: widget.existing?.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        modelNumber: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        price: double.tryParse(_priceController.text.trim()),
        purchaseDate: _purchaseDate,
        warrantyDuration: (warrantyMonths == null || warrantyMonths == 0) ? null : warrantyMonths,
        serviceDate: _serviceDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        reminderEnabled: _reminderEnabled,
      );

      final Product saved = _isEditing
          ? await AssetRepository.updateAsset(widget.existing!.id!, product)
          : await AssetRepository.createAsset(product);

      // The product has no id until this point, so the optional document
      // slots can only be saved now -- never before create succeeds, and
      // never more than once (there's no retry here on top of this call).
      final failedDocLabels = await _saveOptionalDocuments(saved.id!);

      // warrantyExpiry is server-computed, so the reminder can only be
      // scheduled correctly against the saved copy, not the local one built
      // above.
      await NotificationService.syncReminder(saved);

      if (!mounted) return;

      final baseMessage = _isEditing ? 'Product updated successfully' : 'Product saved successfully';
      final message = failedDocLabels.isEmpty
          ? baseMessage
          : "$baseMessage, but the ${failedDocLabels.join(' and ')} couldn't be saved";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save product: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Saves whichever optional document slots were filled in, against the
  /// now-existing [assetId]. Each slot is independent -- one failing never
  /// stops the other, and never costs the product record itself (it's
  /// already saved by the time this runs). Returns the labels that failed,
  /// so the caller can fold that into one snackbar message.
  Future<List<String>> _saveOptionalDocuments(String assetId) async {
    final failed = <String>[];

    if (_warrantyCardDoc != null) {
      try {
        await DocumentRepository.captureDocument(
          assetId: assetId,
          pickedFile: _warrantyCardDoc!.file,
          mimeType: _warrantyCardDoc!.mimeType,
          label: 'Warranty card',
        );
      } catch (_) {
        failed.add('warranty card');
      }
    }

    if (_invoiceDoc != null) {
      try {
        await DocumentRepository.captureDocument(
          assetId: assetId,
          pickedFile: _invoiceDoc!.file,
          mimeType: _invoiceDoc!.mimeType,
          label: 'Invoice',
        );
      } catch (_) {
        failed.add('invoice');
      }
    }

    return failed;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _warrantyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.8),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF383838))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
      ),
    );
  }

  Widget _dateTile({required String title, required DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                date == null ? title : '$title: ${date.day}/${date.month}/${date.year}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          _isEditing ? 'EDIT PRODUCT' : 'ADD PRODUCT',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'UPDATE ASSET RECORD' : 'NEW ASSET RECORD',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the product details below',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    _textField(controller: _nameController, label: 'PRODUCT NAME'),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      dropdownColor: AppColors.surface,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'CATEGORY',
                        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(value: category, child: Text(category));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    _textField(controller: _brandController, label: 'BRAND'),
                    const SizedBox(height: 18),
                    _textField(controller: _modelController, label: 'MODEL NUMBER'),
                    const SizedBox(height: 18),
                    _textField(controller: _priceController, label: 'PRICE (OPTIONAL)', keyboardType: TextInputType.number),
                    const SizedBox(height: 18),
                    _textField(
                      controller: _warrantyController,
                      label: 'WARRANTY DURATION (MONTHS)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),
                    _textField(controller: _notesController, label: 'NOTES (OPTIONAL)'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _dateTile(
                title: 'CHOOSE PURCHASE DATE',
                date: _purchaseDate,
                onTap: () => _pickDate(isPurchaseDate: true),
              ),
              const SizedBox(height: 14),
              _dateTile(
                title: 'CHOOSE NEXT SERVICE DATE',
                date: _serviceDate,
                onTap: () => _pickDate(isPurchaseDate: false),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined, color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Scanned bills and warranty cards are managed from the Files tab on this product',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 14),
                DocumentSlotField(
                  label: 'Warranty card (optional)',
                  value: _warrantyCardDoc,
                  enabled: !_isSaving,
                  onChanged: (doc) => setState(() => _warrantyCardDoc = doc),
                ),
                const SizedBox(height: 14),
                DocumentSlotField(
                  label: 'Invoice (optional)',
                  value: _invoiceDoc,
                  enabled: !_isSaving,
                  onChanged: (doc) => setState(() => _invoiceDoc = doc),
                ),
              ],
              const SizedBox(height: 14),
              SwitchListTile(
                value: _reminderEnabled,
                onChanged: (value) => setState(() => _reminderEnabled = value),
                activeColor: AppColors.accent,
                title: Text(
                  'WARRANTY EXPIRY REMINDER',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Get notified before the warranty expires',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isSaving ? 'SAVING...' : (_isEditing ? 'UPDATE PRODUCT' : 'SAVE PRODUCT'),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
