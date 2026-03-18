// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: file_names

part of 'AI_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiSettingsAdapter extends TypeAdapter<AiSettings> {
  @override
  final int typeId = 10;

  @override
  AiSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiSettings(
      isConfirm: fields[0] as bool,
      defaultMoneySource: fields[1] as MoneySource?,
    );
  }

  @override
  void write(BinaryWriter writer, AiSettings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.isConfirm)
      ..writeByte(1)
      ..write(obj.defaultMoneySource);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
