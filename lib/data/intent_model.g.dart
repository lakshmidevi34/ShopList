// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intent_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IntentItemAdapter extends TypeAdapter<IntentItem> {
  @override
  final int typeId = 0;

  @override
  IntentItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IntentItem(
      id: fields[0] as String,
      name: fields[1] as String,
      expectedPrice: fields[2] as double,
      desireLevel: fields[3] as int,
      priority: fields[4] as String,
      reason: fields[5] as String,
      bought: fields[6] as bool,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, IntentItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.expectedPrice)
      ..writeByte(3)
      ..write(obj.desireLevel)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.reason)
      ..writeByte(6)
      ..write(obj.bought)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntentItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
