// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkerPaymentAdapter extends TypeAdapter<WorkerPayment> {
  @override
  final int typeId = 1;

  @override
  WorkerPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkerPayment(
      workerId: fields[0] as int,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      note: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkerPayment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.workerId)
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
      other is WorkerPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
