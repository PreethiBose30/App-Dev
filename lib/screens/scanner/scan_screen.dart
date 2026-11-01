import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'result_screen.dart';
import '../dashboard/add_product_screen.dart';
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image;
    try {
      image = await _picker.pickImage(source: source);
    } catch (e) {
      // Covers permission denied/permanently denied and camera-unavailable
      // -- image_picker surfaces all of these as exceptions, so this is
      // what keeps a denied permission from crashing the app.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Could not open the camera. Check that camera permission is granted in Settings.'
                : 'Could not open the gallery. Check that photo access is granted in Settings.',
          ),
        ),
      );
      return;
    }

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

  Future<void> _openAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _mlKitService.dispose();
    super.dispose();
  }

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
          'ADD PRODUCT',
          style: TextStyle(
            color: AppColors.textPrimary,
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
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 70,
                    color: AppColors.textPrimary,
                  ),

                  SizedBox(height: 20),

                  Text(
                    'ADD A PRODUCT',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Scan a document or enter details manually',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),

                icon: const Icon(
                  Icons.camera_alt_outlined,
                ),

                label: Text(
                  _isProcessing
                      ? 'PROCESSING...'
                      : 'SCAN WITH CAMERA',
                ),

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
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),

                icon: const Icon(
                  Icons.photo_library_outlined,
                ),

                label: const Text(
                  'SCAN FROM GALLERY',
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,

                  side: BorderSide(
                    color: AppColors.textSecondary,
                  ),

                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: _openAddProduct,

                icon: const Icon(
                  Icons.edit_outlined,
                ),

                label: const Text(
                  'ADD MANUALLY',
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,

                  side: BorderSide(
                    color: AppColors.textSecondary,
                  ),

                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),

            const Spacer(),

            Text(
              'Scan bills, warranty cards, insurance papers, '
                  'or add product information manually.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}