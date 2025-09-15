// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_insight_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIInsightModelAdapter extends TypeAdapter<AIInsightModel> {
  @override
  final int typeId = 1;

  @override
  AIInsightModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIInsightModel(
      id: fields[0] as String,
      typeValue: fields[1] as int,
      title: fields[2] as String,
      description: fields[3] as String,
      action: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      priority: fields[6] as int,
      metadata: (fields[7] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AIInsightModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.typeValue)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.action)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIInsightModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
