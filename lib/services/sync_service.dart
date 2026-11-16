import 'dart:async';
import 'dart:io';
import '../models/local_document.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';
import 'document_service.dart';
import 'hive_service.dart';

/// Pushes pending uploads and pending deletions to the backend. A failed
/// upload/delete never touches the local file or Hive record beyond
/// marking its status -- the local copy stays available regardless of how
/// many times a sync attempt fails, and retrying it later (automatically
/// on reconnect, or manually) is always safe because the backend's
/// (user, localId) uniqueness makes every upload idempotent.
class SyncService {
  static bool _running = false;
  static StreamSubscription<bool>? _connectivitySub;
  static final _eventsController = StreamController<void>.broadcast();

  /// Fires after every sync pass (success or partial failure) so UI can
  /// refresh its sync-status badges without polling.
  static Stream<void> get onSyncEvent => _eventsController.stream;

  static void startAutoSync() {
    _recoverInterruptedUploads();
    _connectivitySub ??= ConnectivityService.onStatusChange.listen((online) {
      if (online) syncAll();
    });
  }

  /// An upload that was in flight when the app was closed or killed is left
  /// marked "uploading" with nothing actually uploading it. Called once at
  /// startup (nothing can be in flight yet) to put those back in the queue;
  /// re-sending is safe because uploads are idempotent on localId.
  static void _recoverInterruptedUploads() {
    for (final doc in HiveService.documentsBox.values.toList()) {
      if (doc.syncStatus == DocumentSyncStatus.uploading) {
        doc.syncStatus = DocumentSyncStatus.pending;
        doc.save();
      }
    }
  }

  static void stopAutoSync() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Syncs every pending upload/deletion for the current user. Safe to
  /// call repeatedly (e.g. a "Sync Now" button) -- re-entrant calls are
  /// ignored while one is already running.
  static Future<void> syncAll() async {
    if (_running) return;
    if (!await ConnectivityService.refresh()) return;

    _running = true;
    try {
      final userId = AuthService.cachedUser?.id;
      if (userId == null) return;

      final docs = HiveService.documentsBox.values.where((d) => d.ownerUserId == userId).toList();
      for (final doc in docs) {
        // One document failing in an unexpected way must not stop the rest
        // of the queue from syncing.
        try {
          if (doc.syncStatus == DocumentSyncStatus.deleted) {
            await _syncDeletion(doc);
          } else if (doc.syncStatus == DocumentSyncStatus.pending || doc.syncStatus == DocumentSyncStatus.failed) {
            await _syncUpload(doc);
          }
        } catch (_) {}
      }
      await HiveService.settingsBox.put('lastSyncTime', DateTime.now().toIso8601String());
    } finally {
      _running = false;
      _eventsController.add(null);
    }
  }

  /// Syncs a single document right away (used right after a capture, or a
  /// delete, when the app already knows it's online) without waiting for
  /// the next full pass.
  static Future<void> syncOne(LocalDocument doc) async {
    if (!ConnectivityService.isOnline) return;
    try {
      if (doc.syncStatus == DocumentSyncStatus.deleted) {
        await _syncDeletion(doc);
      } else {
        await _syncUpload(doc);
      }
    } catch (_) {
      // Left as it is; the next full pass retries it.
    }
    _eventsController.add(null);
  }

  static Future<void> _syncUpload(LocalDocument doc) async {
    final path = doc.localFilePath;
    final file = path == null ? null : File(path);
    if (file == null || !await file.exists()) {
      // The local copy is gone (shouldn't normally happen -- deleteDocument
      // is the only thing that removes it, and that also flips the status
      // away from pending/failed). Nothing left to upload; drop the record
      // rather than retry forever against a file that no longer exists.
      await doc.delete();
      return;
    }

    doc.syncStatus = DocumentSyncStatus.uploading;
    await doc.save();

    try {
      final remote = await DocumentService.upload(
        assetId: doc.assetId,
        localId: doc.localId,
        filePath: file.path,
        mimeType: doc.mimeType,
        checksum: doc.checksum,
        filename: doc.filename,
      );
      doc.serverId = remote.id;
      doc.syncStatus = DocumentSyncStatus.synced;
      doc.updatedAt = DateTime.now();
      await doc.save();
    } catch (e) {
      if (e is ApiException && e.statusCode == 404 && e.message == 'Asset not found') {
        // The product this document belongs to no longer exists on the
        // server (deleted from another phone). There is nowhere to upload
        // it to and no screen that would show it, so stop retrying. The
        // exact message is checked so that a wrong server address (which
        // also answers 404) can never cause local files to be removed.
        if (await file.exists()) await file.delete();
        await doc.delete();
        return;
      }
      // Anything else (no network, server error, a file read error): keep
      // the local file and Hive record exactly as they are and mark it
      // failed, so it is retried on the next sync pass instead of silently
      // disappearing or staying stuck on "uploading".
      doc.syncStatus = DocumentSyncStatus.failed;
      doc.updatedAt = DateTime.now();
      await doc.save();
    }
  }

  static Future<void> _syncDeletion(LocalDocument doc) async {
    if (doc.serverId == null) {
      await doc.delete();
      return;
    }
    try {
      await DocumentService.delete(doc.serverId!);
      await doc.delete();
    } on ApiException catch (e) {
      // Already gone on the server: the delete has effectively happened.
      if (e.statusCode == 404) {
        await doc.delete();
        return;
      }
      // Otherwise leave it marked deleted (already hidden from the UI list)
      // and retry the server-side delete on the next pass.
    }
  }
}
