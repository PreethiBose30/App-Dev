import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Color(0xFFF4F4F0),
        ),

        title: const Text(
          'OCR RESULT',
          style: TextStyle(
            color: Color(0xFFF4F4F0),
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
            const Text(
              'EXTRACTED TEXT',
              style: TextStyle(
                color: Color(0xFFF4F4F0),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Review the text detected from your document.',
              style: TextStyle(
                color: Color(0xFF7A7A7A),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),

                child: SingleChildScrollView(
                  child: Text(
                    extractedText.isEmpty
                        ? 'No text was detected.'
                        : extractedText,

                    style: const TextStyle(
                      color: Color(0xFFF4F4F0),
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
                    foregroundColor: const Color(0xFFF4F4F0),
                    side: const BorderSide(color: Color(0xFF555555)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  backgroundColor: const Color(0xFFF4F4F0),

                  foregroundColor: const Color(0xFF0D0D0D),

                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
