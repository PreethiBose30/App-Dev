import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../hive_registrar.g.dart';
import '../models/local_asset.dart';
import '../models/local_document.dart';

/// Bootstraps Hive CE and owns the three boxes the app persists locally:
/// - assets: offline read cache of the vault (see AssetRepository)
/// - documents: captured documents + their sync state (see SyncService)
/// - settings: small non-sensitive key/value bits (e.g. last sync time).
///   Auth tokens/session data are NOT here -- those stay in
///   flutter_secure_storage, which is what they're actually meant for.
class HiveService {
  static const String assetsBoxName = 'local_assets';
  static const String documentsBoxName = 'local_documents';
  static const String settingsBoxName = 'settings';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    Hive.registerAdapters();

    await Hive.openBox<LocalAsset>(assetsBoxName);
    await Hive.openBox<LocalDocument>(documentsBoxName);
    await Hive.openBox(settingsBoxName);

    _initialized = true;
  }

  static Box<LocalAsset> get assetsBox => Hive.box<LocalAsset>(assetsBoxName);
  static Box<LocalDocument> get documentsBox => Hive.box<LocalDocument>(documentsBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);

  /// Called on logout. Only clears the asset cache -- a pure read cache,
  /// safe to discard unconditionally. The documents box is deliberately
  /// left alone: it can hold captures that were made offline and never
  /// finished syncing, and wiping it on logout would silently lose data
  /// the user thinks is safe. Every document/asset read already filters by
  /// ownerUserId, so nothing leaks to a different account logging in on
  /// the same device either way.
  static Future<void> clearAssetCache() async {
    await assetsBox.clear();
  }
}
