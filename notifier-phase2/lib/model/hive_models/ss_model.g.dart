// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ss_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchModelAdapter extends TypeAdapter<SearchModel> {
  @override
  final typeId = 5;

  @override
  SearchModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchModel(
      bloodGroup: fields[7] as String,
      dept: fields[4] as String,
      gender: fields[8] as String,
      hall: fields[5] as String,
      hometown: fields[9] as String,
      name: fields[1] as String,
      program: fields[3] as String,
      rollno: fields[2] as String,
      room: fields[6] as String,
      username: fields[0] as String,
      year: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SearchModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.rollno)
      ..writeByte(3)
      ..write(obj.program)
      ..writeByte(4)
      ..write(obj.dept)
      ..writeByte(5)
      ..write(obj.hall)
      ..writeByte(6)
      ..write(obj.room)
      ..writeByte(7)
      ..write(obj.bloodGroup)
      ..writeByte(8)
      ..write(obj.gender)
      ..writeByte(9)
      ..write(obj.hometown)
      ..writeByte(10)
      ..write(obj.year);
  }
}
