import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
import 'dart:io';
import '../../services/document_picker.dart';
import '../dashboard/add_product_screen.dart';

class ResultScreen extends StatelessWidget {
  final String extractedText;

  /// The photo that was scanned. Passed on to the new-product form as its
  /// invoice, so the bill itself is kept and not just the text read off it.
  final String? imagePath;

  const ResultScreen({
    super.key,
    required this.extractedText,
    this.imagePath,
  });

  Future<void> _useForNewProduct(BuildContext context) async {
    PickedDocument? invoice;
    final path = imagePath;
    if (path != null) {
      final candidate = PickedDocument(file: File(path), mimeType: DocumentPicker.mimeTypeForPath(path));
      try {
        await DocumentPicker.validate(candidate);
        invoice = candidate;
      } catch (_) {
        // Too large or unreadable: carry on with the text only.
      }
    }
    if (!context.mounted) return;
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          initialNotes: extractedText.isEmpty ? null : extractedText,
          initialInvoice: invoice,
        ),
      ),
    );
    if (saved == true && context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(context, 'Scan result'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SwissLabel('Text found in your document'),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    extractedText.isEmpty ? 'No text was detected.' : extractedText,
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (extractedText.isNotEmpty) ...[
                SwissButton(
                  'Use as notes for a new product',
                  onPressed: () => _useForNewProduct(context),
                ),
                const SizedBox(height: 12),
              ],
              if (extractedText.isEmpty && imagePath != null) ...[
                SwissButton('Add a product with this photo', onPressed: () => _useForNewProduct(context)),
                const SizedBox(height: 12),
              ],
              SwissButton('Done', outlined: true, onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}
