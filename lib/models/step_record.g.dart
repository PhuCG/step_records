// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StepRecordAdapter extends TypeAdapter<StepRecord> {
  @override
  final int typeId = 0;

  @override
  StepRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepRecord(
      id: fields[0] as String,
      steps: fields[1] as int,
      delta: fields[2] as int,
      timestamp: fields[3] as DateTime,
      sessionId: fields[4] as String,
      synced: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StepRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.steps)
      ..writeByte(2)
      ..write(obj.delta)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.sessionId)
      ..writeByte(5)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
