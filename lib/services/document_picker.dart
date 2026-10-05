import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// A file picked/captured for a document, before it's validated or saved.
class PickedDocument {
  final File file;
  final String mimeType;
  const PickedDocument({required this.file, required this.mimeType});

  String get filename => file.path.split(Platform.pathSeparator).last;
  bool get isImage => mimeType.startsWith('image/');
}

/// Thrown for anything that stops a pick from completing -- permission
/// denied, picker unavailable, unsupported type, too large. Always carries
/// a message that's safe to show directly in a SnackBar.
class DocumentPickException implements Exception {
  final String message;
  DocumentPickException(this.message);
  @override
  String toString() => message;
}

/// Shared camera/gallery/file picking + mime-type detection + validation
/// for documents (warranty cards, invoices, bills). Used by both the
/// dedicated document-capture flow (Files tab) and the optional document
/// slots on the manual add-product form, so there's exactly one place that
/// knows how to open the camera/gallery/file picker and what's an
/// acceptable document.
class DocumentPicker {
  static const int maxSizeBytes = 10 * 1024 * 1024;
  static const List<String> allowedMimeTypes = ['image/jpeg', 'image/png', 'application/pdf'];

  static String mimeTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }

  static Future<PickedDocument?> fromCamera() => _fromImageSource(ImageSource.camera);
  static Future<PickedDocument?> fromGallery() => _fromImageSource(ImageSource.gallery);

  static Future<PickedDocument?> _fromImageSource(ImageSource source) async {
    try {
      final shot = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (shot == null) return null; // user cancelled -- not an error
      return PickedDocument(file: File(shot.path), mimeType: 'image/jpeg');
    } catch (e) {
      // Covers permission denied, permission permanently denied, and
      // camera-unavailable -- image_picker surfaces all of these as
      // exceptions rather than distinct states, so one message covers all
      // three without the app crashing.
      throw DocumentPickException(
        source == ImageSource.camera
            ? 'Could not open the camera. Check that camera permission is granted in Settings.'
            : 'Could not open the gallery. Check that photo access is granted in Settings.',
      );
    }
  }

  static Future<PickedDocument?> fromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      final path = result?.files.single.path;
      if (path == null) return null; // cancelled
      return PickedDocument(file: File(path), mimeType: mimeTypeForPath(path));
    } catch (e) {
      throw DocumentPickException('Could not open the file picker.');
    }
  }

  /// Mirrors the backend's own JPEG/PNG/PDF + 10MB checks, so an obviously
  /// invalid file is caught here instead of bouncing off the server.
  static Future<void> validate(PickedDocument doc) async {
    if (!allowedMimeTypes.contains(doc.mimeType)) {
      throw DocumentPickException('Unsupported file type. Please choose a JPEG, PNG, or PDF file.');
    }
    final size = await doc.file.length();
    if (size > maxSizeBytes) {
      throw DocumentPickException('File is too large (max 10MB).');
    }
  }
}
