// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disk_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiskModelAdapter extends TypeAdapter<DiskModel> {
  @override
  final int typeId = 0;

  @override
  DiskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiskModel(
      releaseId: fields[0] as int,
      title: fields[1] as String,
      artist: fields[2] as String,
      year: fields[3] as int,
      genres: (fields[4] as List).cast<String>(),
      styles: (fields[5] as List).cast<String>(),
      coverUrl: fields[6] as String,
      tracklist: (fields[7] as List).cast<Track>(),
    );
  }

  @override
  void write(BinaryWriter writer, DiskModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.releaseId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.genres)
      ..writeByte(5)
      ..write(obj.styles)
      ..writeByte(6)
      ..write(obj.coverUrl)
      ..writeByte(7)
      ..write(obj.tracklist);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 1;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      title: fields[0] as String,
      duration: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
