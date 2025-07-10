// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplierPaymentAdapter extends TypeAdapter<SupplierPayment> {
  @override
  final int typeId = 4;

  @override
  SupplierPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplierPayment(
      supplierId: fields[0] as int,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      note: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SupplierPayment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.supplierId)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
