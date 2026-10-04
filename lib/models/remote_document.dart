/// The server's view of a document (see backend/src/models/Document.js).
/// Distinct from LocalDocument (the on-device Hive record with sync state
/// and a local file path) -- this is just what GET /assets/:id/documents
/// and GET /documents/:id return.
class RemoteDocument {
  final String id;
  final String assetId;
  final String localId;
  final String filename;
  final String mimeType;
  final int size;
  final String checksum;
  final DateTime createdAt;

  RemoteDocument({
    required this.id,
    required this.assetId,
    required this.localId,
    required this.filename,
    required this.mimeType,
    required this.size,
    required this.checksum,
    required this.createdAt,
  });

  factory RemoteDocument.fromJson(Map<String, dynamic> json) {
    return RemoteDocument(
      id: json['_id'] as String,
      assetId: json['asset'] as String,
      localId: json['localId'] as String,
      filename: json['filename'] as String,
      mimeType: json['mimeType'] as String,
      size: (json['size'] as num).toInt(),
      checksum: json['checksum'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'].toString())?.toLocal() ?? DateTime.now(),
    );
  }
}
