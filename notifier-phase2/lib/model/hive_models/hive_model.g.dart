// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      rollno: fields[2] as String,
      uid: fields[3] as String,
      prefs: (fields[4] as List)?.cast<String>(),
      admin: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.rollno)
      ..writeByte(3)
      ..write(obj.uid)
      ..writeByte(4)
      ..write(obj.prefs)
      ..writeByte(5)
      ..write(obj.admin);
  }
}
