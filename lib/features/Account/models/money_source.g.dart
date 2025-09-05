// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_source.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoneySourceAdapter extends TypeAdapter<MoneySource> {
  @override
  final int typeId = 3;

  @override
  MoneySource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoneySource(
      id: fields[0] as String?,
      name: fields[1] as String,
      balance: fields[2] as double,
      type: fields[3] as TypeMoney?,
      currency: fields[4] as CurrencyType?,
      iconCode: fields[5] as String?,
      color: fields[6] as String?,
      description: fields[7] as String?,
      isActive: fields[8] as bool,
    )
      ..uid = fields[9] as String?
      ..updatedAt = fields[10] as String?
      ..isDeleted = fields[11] as bool?
      ..pendingSync = fields[12] as bool?;
  }

  @override
  void write(BinaryWriter writer, MoneySource obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.balance)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.iconCode)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.uid)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isDeleted)
      ..writeByte(12)
      ..write(obj.pendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoneySourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrencyTypeAdapter extends TypeAdapter<CurrencyType> {
  @override
  final int typeId = 4;

  @override
  CurrencyType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CurrencyType.vnd;
      case 1:
        return CurrencyType.usd;
      default:
        return CurrencyType.vnd;
    }
  }

  @override
  void write(BinaryWriter writer, CurrencyType obj) {
    switch (obj) {
      case CurrencyType.vnd:
        writer.writeByte(0);
        break;
      case CurrencyType.usd:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TypeMoneyAdapter extends TypeAdapter<TypeMoney> {
  @override
  final int typeId = 5;

  @override
  TypeMoney read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TypeMoney.cash;
      case 1:
        return TypeMoney.eWallet;
      case 2:
        return TypeMoney.bank;
      case 3:
        return TypeMoney.other;
      default:
        return TypeMoney.cash;
    }
  }

  @override
  void write(BinaryWriter writer, TypeMoney obj) {
    switch (obj) {
      case TypeMoney.cash:
        writer.writeByte(0);
        break;
      case TypeMoney.eWallet:
        writer.writeByte(1);
        break;
      case TypeMoney.bank:
        writer.writeByte(2);
        break;
      case TypeMoney.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeMoneyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
