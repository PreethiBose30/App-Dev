import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double? price;

  @HiveField(4)
  final DateTime? purchaseDate;

  @HiveField(5)
  final DateTime? warrantyExpiry;

  @HiveField(6)
  final DateTime? emiDueDate;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final String? imagePath;

  @HiveField(9)
  final String? brand;

  @HiveField(10)
  final String? modelNumber;

  @HiveField(11)
  final int? warrantyDuration;

  @HiveField(12)
  final DateTime? serviceDate;

  @HiveField(13)
  final String? documentPath;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.price,
    this.purchaseDate,
    this.warrantyExpiry,
    this.emiDueDate,
    this.notes,
    this.imagePath,
    this.brand,
    this.modelNumber,
    this.warrantyDuration,
    this.serviceDate,
    this.documentPath,
  });
}