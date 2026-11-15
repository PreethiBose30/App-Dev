import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
import '../dashboard/add_product_screen.dart';

class ResultScreen extends StatelessWidget {
  final String extractedText;

  const ResultScreen({
    super.key,
    required this.extractedText,
  });

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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddProductScreen(initialNotes: extractedText)),
                    );
                  },
                ),
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
