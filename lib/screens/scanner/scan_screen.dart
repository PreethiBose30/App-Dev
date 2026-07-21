import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'result_screen.dart';

import '../../services/mlkit_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final MlKitService _mlKitService = MlKitService();

  bool _isProcessing = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final String extractedText =
      await _mlKitService.recognizeText(image.path);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            extractedText: extractedText,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OCR failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mlKitService.dispose();
    super.dispose();
  }

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
          'SCAN DOCUMENT',
          style: TextStyle(
            color: Color(0xFFF4F4F0),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 70,
                    color: Color(0xFFF4F4F0),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'DOCUMENT SCANNER',
                    style: TextStyle(
                      color: Color(0xFFF4F4F0),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Extract text from your documents',
                    style: TextStyle(
                      color: Color(0xFF7A7A7A),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Upload an image of a document and let OCR extract the text automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7A7A7A),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickImage,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _isProcessing
                      ? 'PROCESSING...'
                      : 'SELECT DOCUMENT',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4F4F0),
                  foregroundColor: const Color(0xFF0D0D0D),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}