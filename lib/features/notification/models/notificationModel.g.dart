// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: file_names

part of 'notificationModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 9;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      isNotificationEnabled: fields[0] as bool,
      isDaily: fields[1] as bool,
      isWeekly: fields[2] as bool,
      reminderTime: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isNotificationEnabled)
      ..writeByte(1)
      ..write(obj.isDaily)
      ..writeByte(2)
      ..write(obj.isWeekly)
      ..writeByte(3)
      ..write(obj.reminderTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
