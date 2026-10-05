// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalDocumentAdapter extends TypeAdapter<LocalDocument> {
  @override
  final typeId = 1;

  @override
  LocalDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalDocument(
      localId: fields[0] as String,
      assetId: fields[1] as String,
      serverId: fields[2] as String?,
      filename: fields[3] as String,
      mimeType: fields[4] as String,
      fileSizeBytes: (fields[5] as num).toInt(),
      localFilePath: fields[6] as String?,
      checksum: fields[7] as String,
      syncStatus: fields[8] as DocumentSyncStatus,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      ownerUserId: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalDocument obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.assetId)
      ..writeByte(2)
      ..write(obj.serverId)
      ..writeByte(3)
      ..write(obj.filename)
      ..writeByte(4)
      ..write(obj.mimeType)
      ..writeByte(5)
      ..write(obj.fileSizeBytes)
      ..writeByte(6)
      ..write(obj.localFilePath)
      ..writeByte(7)
      ..write(obj.checksum)
      ..writeByte(8)
      ..write(obj.syncStatus)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.ownerUserId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentSyncStatusAdapter extends TypeAdapter<DocumentSyncStatus> {
  @override
  final typeId = 2;

  @override
  DocumentSyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentSyncStatus.pending;
      case 1:
        return DocumentSyncStatus.uploading;
      case 2:
        return DocumentSyncStatus.synced;
      case 3:
        return DocumentSyncStatus.failed;
      case 4:
        return DocumentSyncStatus.deleted;
      default:
        return DocumentSyncStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentSyncStatus obj) {
    switch (obj) {
      case DocumentSyncStatus.pending:
        writer.writeByte(0);
      case DocumentSyncStatus.uploading:
        writer.writeByte(1);
      case DocumentSyncStatus.synced:
        writer.writeByte(2);
      case DocumentSyncStatus.failed:
        writer.writeByte(3);
      case DocumentSyncStatus.deleted:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentSyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
