// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      price: fields[3] as double?,
      purchaseDate: fields[4] as DateTime?,
      warrantyExpiry: fields[5] as DateTime?,
      emiDueDate: fields[6] as DateTime?,
      notes: fields[7] as String?,
      imagePath: fields[8] as String?,
      brand: fields[9] as String?,
      modelNumber: fields[10] as String?,
      warrantyDuration: fields[11] as int?,
      serviceDate: fields[12] as DateTime?,
      documentPath: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.purchaseDate)
      ..writeByte(5)
      ..write(obj.warrantyExpiry)
      ..writeByte(6)
      ..write(obj.emiDueDate)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.brand)
      ..writeByte(10)
      ..write(obj.modelNumber)
      ..writeByte(11)
      ..write(obj.warrantyDuration)
      ..writeByte(12)
      ..write(obj.serviceDate)
      ..writeByte(13)
      ..write(obj.documentPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
