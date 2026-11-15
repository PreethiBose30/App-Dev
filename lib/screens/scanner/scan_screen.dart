import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
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
      appBar: swissAppBar(context, 'Add product'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          children: [
            Text(
              'Scan a bill or\nenter it yourself.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 38, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.8),
            ),
            const SizedBox(height: 14),
            Text(
              'Scanning reads the text off a bill, warranty card or insurance paper so you can copy details from it.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 36),
            SwissButton(
              'Scan with camera',
              icon: Icons.camera_alt_outlined,
              loading: _isProcessing,
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            SwissButton(
              'Scan from gallery',
              icon: Icons.photo_library_outlined,
              outlined: true,
              onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            SwissButton(
              'Add manually',
              icon: Icons.edit_outlined,
              outlined: true,
              onPressed: _isProcessing ? null : _openAddProduct,
            ),
          ],
        ),
      ),
    );
  }
}
