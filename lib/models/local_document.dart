import 'package:hive_ce/hive.dart';

part 'local_document.g.dart';

@HiveType(typeId: 2)
enum DocumentSyncStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  uploading,
  @HiveField(2)
  synced,
  @HiveField(3)
  failed,
  @HiveField(4)
  deleted,
}

/// A captured/picked document, OR a stub for a document that exists on the
/// server but hasn't been downloaded to this device yet (e.g. uploaded
/// from a different device -- see DocumentRepository.mergeRemoteDocuments).
///
/// [localId] (a real UUID, generated on-device) is both the Hive box key
/// and the idempotency key the backend uses to guarantee a retried upload
/// never creates a duplicate -- see backend/src/controllers/documentController.js.
///
/// The actual file bytes live in the app's own documents directory
/// (path_provider), not inline in Hive -- Hive only ever holds this
/// metadata record. That keeps the box small and fast regardless of how
/// many/how large the captured documents are, while still satisfying "the
/// document must remain available offline": once [localFilePath] is set,
/// it points at a real file that exists independent of any network state.
/// It's null only for a not-yet-downloaded remote stub; DocumentRepository.
/// ensureLocalFile fetches and fills it in the first time the document is
/// opened.
@HiveType(typeId: 1)
class LocalDocument extends HiveObject {
  @HiveField(0)
  final String localId;
  @HiveField(1)
  final String assetId;
  @HiveField(2)
  String? serverId;
  @HiveField(3)
  final String filename;
  @HiveField(4)
  final String mimeType;
  @HiveField(5)
  final int fileSizeBytes;
  @HiveField(6)
  String? localFilePath;
  @HiveField(7)
  final String checksum;
  @HiveField(8)
  DocumentSyncStatus syncStatus;
  @HiveField(9)
  final DateTime createdAt;
  @HiveField(10)
  DateTime updatedAt;
  @HiveField(11)
  final String ownerUserId;

  LocalDocument({
    required this.localId,
    required this.assetId,
    this.serverId,
    required this.filename,
    required this.mimeType,
    required this.fileSizeBytes,
    this.localFilePath,
    required this.checksum,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerUserId,
  });
}
