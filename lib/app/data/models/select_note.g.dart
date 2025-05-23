// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SelectedNoteAdapter extends TypeAdapter<SelectedNote> {
  @override
  final int typeId = 1;

  @override
  SelectedNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SelectedNote(
      fields[1] as int,
      fields[0] as int,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SelectedNote obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(0)
      ..write(obj.page)
      ..writeByte(2)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
