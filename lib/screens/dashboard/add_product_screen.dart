import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/asset_repository.dart';
import '../../services/api_client.dart';
import '../../services/document_picker.dart';
import '../../services/document_repository.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/format.dart';
import '../../widgets/swiss.dart';
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
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: AppColors.accent,
              onPrimary: AppColors.onAccent,
              surface: AppColors.background,
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
    String? hint,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      decoration: swissInput(label, hint: hint, prefixText: prefixText),
    );
  }

  Widget _dateTile({required String title, required DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.textPrimary, width: 0.8))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(
                    date == null ? 'Not set' : dayMonthYear(date),
                    style: TextStyle(
                      color: date == null ? AppColors.textSecondary : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_month_outlined, color: AppColors.textPrimary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 6),
        child: SwissLabel(label),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(context, _isEditing ? 'Edit product' : 'New product'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Update the details.' : 'What did you buy?',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 34, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.6),
              ),
              _section('Product'),
              _textField(controller: _nameController, label: 'Name'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: AppColors.background,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: swissInput('Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 8),
              _textField(controller: _brandController, label: 'Brand'),
              const SizedBox(height: 8),
              _textField(controller: _modelController, label: 'Model number'),
              const SizedBox(height: 8),
              _textField(controller: _priceController, label: 'Price (optional)', keyboardType: TextInputType.number, prefixText: '₹ '),
              _section('Warranty'),
              _dateTile(
                title: 'Purchase date',
                date: _purchaseDate,
                onTap: () => _pickDate(isPurchaseDate: true),
              ),
              const SizedBox(height: 8),
              _textField(
                controller: _warrantyController,
                label: 'Warranty length (months)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              _dateTile(
                title: 'Next service date (optional)',
                date: _serviceDate,
                onTap: () => _pickDate(isPurchaseDate: false),
              ),
              const SizedBox(height: 8),
              _textField(controller: _notesController, label: 'Notes (optional)'),
              _section('Documents'),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Scanned bills and warranty cards are managed from the Files section of this product.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                )
              else ...[
                DocumentSlotField(
                  label: 'Warranty card (optional)',
                  value: _warrantyCardDoc,
                  enabled: !_isSaving,
                  onChanged: (doc) => setState(() => _warrantyCardDoc = doc),
                ),
                DocumentSlotField(
                  label: 'Invoice (optional)',
                  value: _invoiceDoc,
                  enabled: !_isSaving,
                  onChanged: (doc) => setState(() => _invoiceDoc = doc),
                ),
              ],
              _section('Reminder'),
              SwitchListTile(
                value: _reminderEnabled,
                onChanged: (value) async {
                  setState(() => _reminderEnabled = value);
                  if (!value) return;
                  // Android 13+ needs the user's permission before any
                  // notification can show; ask at the moment they opt in.
                  final granted = await NotificationService.requestPermission();
                  if (!granted && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications are blocked. Allow them in Settings to get reminders.')),
                    );
                  }
                },
                title: Text(
                  'Warranty expiry reminder',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Get notified before the warranty expires',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 28),
              SwissButton(
                _isEditing ? 'Update product' : 'Save product',
                onPressed: _saveProduct,
                loading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
