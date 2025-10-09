// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LogRecordAdapter extends TypeAdapter<LogRecord> {
  @override
  final int typeId = 1;

  @override
  LogRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LogRecord(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      level: fields[2] as String,
      eventType: fields[3] as String,
      data: (fields[4] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LogRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.eventType)
      ..writeByte(4)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
