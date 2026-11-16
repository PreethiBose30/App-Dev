import '../models/product.dart';
import 'api_client.dart';

/// All inventory/vault CRUD goes through here -- no screen calls the API
/// directly and no screen writes to local storage and calls it done. Every
/// method either returns backend-confirmed data or throws ApiException.
class AssetService {
  static Future<List<Product>> getAssets({String? search, String? category}) async {
    final data = await ApiClient.get('/assets', query: {'search': search, 'category': category});
    return (data as List).map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<Product> getAsset(String id) async {
    final data = await ApiClient.get('/assets/$id');
    return Product.fromJson(data as Map<String, dynamic>);
  }

  static Future<Product> createAsset(Product product) async {
    final data = await ApiClient.post('/assets', body: product.toRequestBody());
    return Product.fromJson(data['asset'] as Map<String, dynamic>);
  }

  static Future<Product> updateAsset(String id, Product product) async {
    final data = await ApiClient.put('/assets/$id', body: product.toRequestBody(forUpdate: true));
    return Product.fromJson(data['asset'] as Map<String, dynamic>);
  }

  static Future<void> deleteAsset(String id) async {
    await ApiClient.delete('/assets/$id');
  }
}
