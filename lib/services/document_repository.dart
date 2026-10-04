import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/local_document.dart';
import '../models/remote_document.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';
import 'document_service.dart';
import 'hive_service.dart';
import 'sync_service.dart';

/// Everything about a document's local lifecycle: capture -> save to the
/// app's own storage -> Hive record -> (best-effort immediate sync), plus
/// reconciling documents that were uploaded from a different device.
/// Mobile-only (uses dart:io for real files) -- this is the local half of
/// the architecture the REST-only parts of the app don't need.
class DocumentRepository {
  static const _uuid = Uuid();

  /// Saves a picked/captured file as a new pending document for [assetId].
  /// Returns immediately once it's safely on disk in Hive -- the actual
  /// upload happens in the background (now, if online; later, once
  /// connectivity returns) so the caller never has to wait on the network
  /// to consider the capture "done".
  static Future<LocalDocument> captureDocument({required String assetId, required File pickedFile, required String mimeType}) async {
    final userId = AuthService.cachedUser!.id;
    final localId = _uuid.v4();
    final bytes = await pickedFile.readAsBytes();
    final checksum = sha256.convert(bytes).toString();

    final docsDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(pickedFile.path).isEmpty ? _extensionForMime(mimeType) : p.extension(pickedFile.path);
    final storedFile = File(p.join(docsDir.path, 'documents', '$localId$ext'));
    await storedFile.create(recursive: true);
    await storedFile.writeAsBytes(bytes);

    final doc = LocalDocument(
      localId: localId,
      assetId: assetId,
      filename: p.basename(pickedFile.path),
      mimeType: mimeType,
      fileSizeBytes: bytes.length,
      localFilePath: storedFile.path,
      checksum: checksum,
      syncStatus: DocumentSyncStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerUserId: userId,
    );
    await HiveService.documentsBox.put(localId, doc);

    if (ConnectivityService.isOnline) {
      // Fire-and-forget: don't make the user wait on the network for a
      // capture that's already safely saved locally.
      SyncService.syncOne(doc);
    }

    return doc;
  }

  static List<LocalDocument> documentsForAsset(String assetId) {
    final userId = AuthService.cachedUser?.id;
    final docs = HiveService.documentsBox.values
        .where((d) => d.assetId == assetId && d.ownerUserId == userId && d.syncStatus != DocumentSyncStatus.deleted)
        .toList();
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs;
  }

  /// Reconciles the server's document list for an asset into Hive: any
  /// document that exists on the server but has no local record yet (it
  /// was uploaded from a different device, or this device never saw it)
  /// gets a stub record with no local file -- see [ensureLocalFile] for
  /// how that file gets fetched the first time it's actually opened.
  static Future<void> mergeRemoteDocuments(String assetId, List<RemoteDocument> remoteDocs) async {
    final userId = AuthService.cachedUser?.id;
    if (userId == null) return;
    final box = HiveService.documentsBox;

    for (final remote in remoteDocs) {
      final alreadyKnown = box.values.any(
        (d) => d.ownerUserId == userId && (d.localId == remote.localId || d.serverId == remote.id),
      );
      if (alreadyKnown) continue;

      await box.put(
        remote.localId,
        LocalDocument(
          localId: remote.localId,
          assetId: assetId,
          serverId: remote.id,
          filename: remote.filename,
          mimeType: remote.mimeType,
          fileSizeBytes: remote.size,
          localFilePath: null,
          checksum: remote.checksum,
          syncStatus: DocumentSyncStatus.synced,
          createdAt: remote.createdAt,
          updatedAt: remote.createdAt,
          ownerUserId: userId,
        ),
      );
    }
  }

  /// Returns the on-device file for [doc], downloading and caching it
  /// first if this device has never fetched it before (a remote-only stub
  /// from [mergeRemoteDocuments]). Once downloaded, it stays available
  /// offline from then on -- this is only ever a network operation the
  /// first time.
  static Future<File?> ensureLocalFile(LocalDocument doc) async {
    if (doc.localFilePath != null) {
      final existing = File(doc.localFilePath!);
      if (await existing.exists()) return existing;
    }
    if (doc.serverId == null) return null;

    final bytes = await DocumentService.download(doc.serverId!);
    final docsDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(doc.filename).isEmpty ? _extensionForMime(doc.mimeType) : p.extension(doc.filename);
    final file = File(p.join(docsDir.path, 'documents', '${doc.localId}$ext'));
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);

    doc.localFilePath = file.path;
    doc.updatedAt = DateTime.now();
    await doc.save();
    return file;
  }

  /// Deletes the local file and hides the document from the UI
  /// immediately -- this never waits on the network. If it was already
  /// synced, the server-side delete is marked pending and sent by
  /// SyncService (now if online, later if not); the Hive record itself
  /// only disappears once that confirms.
  static Future<void> deleteDocument(LocalDocument doc) async {
    if (doc.localFilePath != null) {
      final file = File(doc.localFilePath!);
      if (await file.exists()) await file.delete();
    }

    if (doc.serverId == null) {
      await doc.delete();
      return;
    }

    doc.syncStatus = DocumentSyncStatus.deleted;
    doc.updatedAt = DateTime.now();
    await doc.save();

    if (ConnectivityService.isOnline) {
      SyncService.syncOne(doc);
    }
  }

  static String _extensionForMime(String mimeType) {
    switch (mimeType) {
      case 'image/png':
        return '.png';
      case 'application/pdf':
        return '.pdf';
      default:
        return '.jpg';
    }
  }
}
