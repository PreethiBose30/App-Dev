import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class HiveService {
  static const String productBoxName = 'products';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }

    if (!Hive.isBoxOpen(productBoxName)) {
      await Hive.openBox<Product>(productBoxName);
    }
  }

  static Box<Product> getProductBox() {
    return Hive.box<Product>(productBoxName);
  }

  static Future<void> addProduct(Product product) async {
    final Box<Product> box = getProductBox();

    await box.put(
      product.id,
      product,
    );
  }

  static List<Product> getProducts() {
    final Box<Product> box = getProductBox();

    return box.values.toList();
  }

  static Future<void> updateProduct(Product product) async {
    final Box<Product> box = getProductBox();

    await box.put(
      product.id,
      product,
    );
  }

  static Future<void> deleteProduct(String id) async {
    final Box<Product> box = getProductBox();

    await box.delete(id);
  }
}