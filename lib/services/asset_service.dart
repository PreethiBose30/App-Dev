import 'dart:typed_data';
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
    final data = await ApiClient.put('/assets/$id', body: product.toRequestBody());
    return Product.fromJson(data['asset'] as Map<String, dynamic>);
  }

  static Future<void> deleteAsset(String id) async {
    await ApiClient.delete('/assets/$id');
  }

  /// Uploads a scanned bill/warranty document (jpg/png/pdf, max 10MB) and
  /// attaches it to the asset. Returns the asset with imagePath/
  /// documentOriginalName/documentMimeType populated -- the local file path
  /// picked on-device is never sent to or stored by the backend.
  static Future<Product> uploadDocument(String assetId, String localFilePath) async {
    final data = await ApiClient.uploadFile('/assets/$assetId/document', filePath: localFilePath, fieldName: 'document');
    return Product.fromJson(data['asset'] as Map<String, dynamic>);
  }

  static Future<Uint8List> getDocumentBytes(String assetId) {
    return ApiClient.getBytes('/assets/$assetId/document');
  }

  static Future<Product> deleteDocument(String assetId) async {
    final data = await ApiClient.delete('/assets/$assetId/document');
    return Product.fromJson(data['asset'] as Map<String, dynamic>);
  }
}
