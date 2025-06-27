// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_coordinates_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedAddressAdapter extends TypeAdapter<AddressModel> {
  @override
  final int typeId = 0;

  @override
  AddressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressModel(
      fields[0] as String,
      coordinates: fields[1] as CoordinatesModel?,
    );
  }

  @override
  void write(BinaryWriter writer, AddressModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.formatted)
      ..writeByte(1)
      ..write(obj.coordinates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavedCoordinatesAdapter extends TypeAdapter<CoordinatesModel> {
  @override
  final int typeId = 1;

  @override
  CoordinatesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoordinatesModel(fields[0] as double, fields[1] as double);
  }

  @override
  void write(BinaryWriter writer, CoordinatesModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedCoordinatesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
