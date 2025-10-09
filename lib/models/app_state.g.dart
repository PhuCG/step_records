// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppStateAdapter extends TypeAdapter<AppState> {
  @override
  final int typeId = 2;

  @override
  AppState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppState(
      serviceStartTime: fields[0] as DateTime?,
      lastKnownSteps: fields[1] as int,
      currentSessionId: fields[2] as String,
      isServiceRunning: fields[3] as bool,
      lastUpdateTime: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.serviceStartTime)
      ..writeByte(1)
      ..write(obj.lastKnownSteps)
      ..writeByte(2)
      ..write(obj.currentSessionId)
      ..writeByte(3)
      ..write(obj.isServiceRunning)
      ..writeByte(4)
      ..write(obj.lastUpdateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
