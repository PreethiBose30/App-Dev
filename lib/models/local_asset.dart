import 'package:hive_ce/hive.dart';
import 'product.dart';

part 'local_asset.g.dart';

/// Offline read cache of a Product/Asset. Written every time the API
/// successfully returns a fresh list, read whenever the API is unreachable
/// -- see AssetRepository. Keyed in its Hive box by [id] (the server's
/// Mongo id), scoped per [ownerUserId] so switching accounts on the same
/// device never shows a previous user's cached inventory.
@HiveType(typeId: 0)
class LocalAsset extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final String? brand;
  @HiveField(4)
  final String? modelNumber;
  @HiveField(5)
  final double? price;
  @HiveField(6)
  final DateTime? purchaseDate;
  @HiveField(7)
  final int? warrantyDuration;
  @HiveField(8)
  final DateTime? warrantyExpiry;
  @HiveField(9)
  final DateTime? serviceDate;
  @HiveField(10)
  final String? notes;
  @HiveField(11)
  final bool reminderEnabled;
  @HiveField(12)
  final String ownerUserId;

  LocalAsset({
    required this.id,
    required this.name,
    required this.category,
    this.brand,
    this.modelNumber,
    this.price,
    this.purchaseDate,
    this.warrantyDuration,
    this.warrantyExpiry,
    this.serviceDate,
    this.notes,
    required this.reminderEnabled,
    required this.ownerUserId,
  });

  factory LocalAsset.fromProduct(Product product, String ownerUserId) {
    return LocalAsset(
      id: product.id!,
      name: product.name,
      category: product.category,
      brand: product.brand,
      modelNumber: product.modelNumber,
      price: product.price,
      purchaseDate: product.purchaseDate,
      warrantyDuration: product.warrantyDuration,
      warrantyExpiry: product.warrantyExpiry,
      serviceDate: product.serviceDate,
      notes: product.notes,
      reminderEnabled: product.reminderEnabled,
      ownerUserId: ownerUserId,
    );
  }

  Product toProduct() {
    return Product(
      id: id,
      name: name,
      category: category,
      brand: brand,
      modelNumber: modelNumber,
      price: price,
      purchaseDate: purchaseDate,
      warrantyDuration: warrantyDuration,
      warrantyExpiry: warrantyExpiry,
      serviceDate: serviceDate,
      notes: notes,
      reminderEnabled: reminderEnabled,
    );
  }
}
