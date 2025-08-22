// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: file_names

part of 'transactionsModels.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionsmodelsAdapter extends TypeAdapter<Transactionsmodels> {
  @override
  final int typeId = 7;

  @override
  Transactionsmodels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transactionsmodels(
      id: fields[0] as String,
      uid: fields[1] as String,
      accountId: fields[2] as String,
      categoriesId: fields[3] as String,
      type: fields[4] as TransactionType,
      amount: fields[5] as double,
      note: fields[6] as String?,
      transactionDate: fields[7] as DateTime?,
      createdAt: fields[8] as DateTime?,
      isSync: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Transactionsmodels obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.accountId)
      ..writeByte(3)
      ..write(obj.categoriesId)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.transactionDate)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionsmodelsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 6;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
