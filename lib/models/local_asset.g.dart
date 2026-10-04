// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_asset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalAssetAdapter extends TypeAdapter<LocalAsset> {
  @override
  final typeId = 0;

  @override
  LocalAsset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalAsset(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      brand: fields[3] as String?,
      modelNumber: fields[4] as String?,
      price: (fields[5] as num?)?.toDouble(),
      purchaseDate: fields[6] as DateTime?,
      warrantyDuration: (fields[7] as num?)?.toInt(),
      warrantyExpiry: fields[8] as DateTime?,
      serviceDate: fields[9] as DateTime?,
      notes: fields[10] as String?,
      reminderEnabled: fields[11] as bool,
      ownerUserId: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalAsset obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.modelNumber)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.purchaseDate)
      ..writeByte(7)
      ..write(obj.warrantyDuration)
      ..writeByte(8)
      ..write(obj.warrantyExpiry)
      ..writeByte(9)
      ..write(obj.serviceDate)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.reminderEnabled)
      ..writeByte(12)
      ..write(obj.ownerUserId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalAssetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
