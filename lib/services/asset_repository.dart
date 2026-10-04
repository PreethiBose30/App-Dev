import '../models/product.dart';
import '../models/local_asset.dart';
import 'api_client.dart';
import 'asset_service.dart';
import 'auth_service.dart';
import 'hive_service.dart';

/// Offline-first read path for the vault: try the API first and refresh
/// the Hive cache on success; if the API is unreachable, serve the cache
/// instead of an error screen. Writes (create/update/delete) are online-
/// only -- there's no offline edit queue in this app (documents are the
/// thing that genuinely needs to work offline; editing an asset's fields
/// while offline is a much rarer case and was explicitly left out of
/// scope for it) -- but every successful write still updates the cache so
/// the next offline read reflects it.
class AssetRepository {
  static String? get _userId => AuthService.cachedUser?.id;

  static Future<List<Product>> getAssets({String? search, String? category}) async {
    try {
      final products = await AssetService.getAssets(search: search, category: category);
      // Only replace the *whole* cache on an unfiltered fetch -- caching a
      // search/category result would otherwise silently evict everything
      // else the next time the API is unreachable.
      if (search == null && category == null) {
        await _replaceCache(products);
      } else {
        await _upsertCache(products);
      }
      return products;
    } on ApiException {
      return _readCache(search: search, category: category);
    }
  }

  static Future<Product> createAsset(Product product) async {
    final saved = await AssetService.createAsset(product);
    await _upsertCache([saved]);
    return saved;
  }

  static Future<Product> updateAsset(String id, Product product) async {
    final saved = await AssetService.updateAsset(id, product);
    await _upsertCache([saved]);
    return saved;
  }

  static Future<void> deleteAsset(String id) async {
    await AssetService.deleteAsset(id);
    final box = HiveService.assetsBox;
    final key = box.keys.firstWhere((k) => box.get(k)?.id == id, orElse: () => null);
    if (key != null) await box.delete(key);
  }

  static Future<void> _replaceCache(List<Product> products) async {
    final userId = _userId;
    if (userId == null) return;
    final box = HiveService.assetsBox;
    // Only this user's entries -- clear() would also wipe another
    // account's cache if the device is shared/switched between users.
    final staleKeys = box.keys.where((k) => box.get(k)?.ownerUserId == userId).toList();
    await box.deleteAll(staleKeys);
    await _upsertCache(products);
  }

  static Future<void> _upsertCache(List<Product> products) async {
    final userId = _userId;
    if (userId == null) return;
    final box = HiveService.assetsBox;
    for (final product in products) {
      if (product.id == null) continue;
      await box.put(product.id, LocalAsset.fromProduct(product, userId));
    }
  }

  static List<Product> _readCache({String? search, String? category}) {
    final userId = _userId;
    if (userId == null) return [];
    final box = HiveService.assetsBox;

    var items = box.values.where((a) => a.ownerUserId == userId);
    if (category != null && category.isNotEmpty) {
      items = items.where((a) => a.category.toLowerCase() == category.toLowerCase());
    }
    if (search != null && search.isNotEmpty) {
      final term = search.toLowerCase();
      items = items.where(
        (a) =>
            a.name.toLowerCase().contains(term) ||
            (a.brand?.toLowerCase().contains(term) ?? false) ||
            (a.modelNumber?.toLowerCase().contains(term) ?? false),
      );
    }
    return items.map((a) => a.toProduct()).toList();
  }
}
