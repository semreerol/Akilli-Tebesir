// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'odev_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OgrenciAdapter extends TypeAdapter<Ogrenci> {
  @override
  final int typeId = 1;

  @override
  Ogrenci read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ogrenci(
      adSoyad: fields[0] as String,
      sinif: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Ogrenci obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.adSoyad)
      ..writeByte(1)
      ..write(obj.sinif);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OgrenciAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OdevAdapter extends TypeAdapter<Odev> {
  @override
  final int typeId = 2;

  @override
  Odev read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Odev(
      baslik: fields[0] as String,
      sinif: fields[1] as String,
      tarih: fields[2] as DateTime,
    )..tamamlayanOgrenciKeyleri = (fields[3] as List).cast<int>();
  }

  @override
  void write(BinaryWriter writer, Odev obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.baslik)
      ..writeByte(1)
      ..write(obj.sinif)
      ..writeByte(2)
      ..write(obj.tarih)
      ..writeByte(3)
      ..write(obj.tamamlayanOgrenciKeyleri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OdevAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
