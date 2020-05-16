// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeopleModelAdapter extends TypeAdapter<PeopleModel> {
  @override
  final typeId = 2;

  @override
  PeopleModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeopleModel(
      id: fields[0] as String,
      councils: (fields[1] as Map)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List)?.cast<String>())),
      posts: (fields[2] as Map)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, PeopleModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.councils)
      ..writeByte(2)
      ..write(obj.posts);
  }
}
