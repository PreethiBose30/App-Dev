import 'dart:typed_data';
import '../models/remote_document.dart';
import 'api_client.dart';

/// Thin wrapper over the /assets/:id/documents and /documents/:id API --
/// SyncService is the thing that actually decides *when* to call these
/// (offline-first: this layer never touches Hive itself).
class DocumentService {
  static Future<List<RemoteDocument>> listForAsset(String assetId) async {
    final data = await ApiClient.get('/assets/$assetId/documents');
    return (data as List).map((json) => RemoteDocument.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Idempotent: the backend keys on (user, localId), so calling this
  /// again with the same [localId] after a network failure is always safe
  /// and never creates a duplicate document.
  static Future<RemoteDocument> upload({
    required String assetId,
    required String localId,
    required String filePath,
    required String mimeType,
    String? checksum,
  }) async {
    final data = await ApiClient.uploadFile(
      '/assets/$assetId/documents',
      filePath: filePath,
      fieldName: 'document',
      fields: {'localId': localId, if (checksum != null) 'checksum': checksum},
      contentType: mimeType,
    );
    return RemoteDocument.fromJson(data['document'] as Map<String, dynamic>);
  }

  static Future<Uint8List> download(String documentId) {
    return ApiClient.getBytes('/documents/$documentId/download');
  }

  static Future<void> delete(String documentId) {
    return ApiClient.delete('/documents/$documentId');
  }
}
