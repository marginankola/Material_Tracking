// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsumptionModelAdapter extends TypeAdapter<ConsumptionModel> {
  @override
  final int typeId = 1;

  @override
  ConsumptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsumptionModel(
      id: fields[0] as String,
      materialId: fields[1] as String,
      operatorId: fields[2] as String,
      quantity: fields[3] as double,
      batchNumber: fields[4] as String?,
      notes: fields[5] as String?,
      consumedAt: fields[6] as DateTime,
      createdAt: fields[7] as DateTime,
      productId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConsumptionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.materialId)
      ..writeByte(2)
      ..write(obj.operatorId)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.batchNumber)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.consumedAt)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.productId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsumptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
