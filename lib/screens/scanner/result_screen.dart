import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
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

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
        ),

        title: Text(
          'OCR RESULT',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'EXTRACTED TEXT',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Review the text detected from your document.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: AppColors.surface,

                  borderRadius: BorderRadius.zero,

                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),

                child: SingleChildScrollView(
                  child: Text(
                    extractedText.isEmpty
                        ? 'No text was detected.'
                        : extractedText,

                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (extractedText.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(initialNotes: extractedText),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.textSecondary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    'USE AS NEW PRODUCT NOTES',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,

                  foregroundColor: AppColors.background,

                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),

                child: const Text(
                  'DONE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
