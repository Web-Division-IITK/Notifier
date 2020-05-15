// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_allCouncilData.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubCouncilAdapter extends TypeAdapter<SubCouncil> {
  @override
  final typeId = 4;

  @override
  SubCouncil read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubCouncil(
      entity: (fields[4] as List)?.cast<String>(),
      level2: (fields[1] as List)?.cast<String>(),
      misc: (fields[2] as List)?.cast<String>(),
      coordiOfInCouncil: (fields[3] as List)?.cast<String>(),
      council: fields[0] as String,
      select: (fields[5] as List)?.cast<bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, SubCouncil obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.council)
      ..writeByte(1)
      ..write(obj.level2)
      ..writeByte(2)
      ..write(obj.misc)
      ..writeByte(3)
      ..write(obj.coordiOfInCouncil)
      ..writeByte(4)
      ..write(obj.entity)
      ..writeByte(5)
      ..write(obj.select);
  }
}

class CouncilsAdapter extends TypeAdapter<Councils> {
  @override
  final typeId = 3;

  @override
  Councils read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Councils(
      subCouncil: (fields[0] as Map)?.cast<String, SubCouncil>(),
      coordOfCouncil: (fields[2] as List)?.cast<String>(),
      level3: (fields[1] as List)?.cast<String>(),
      presiAndChairPerson: (fields[3] as Map)?.cast<String, SubCouncil>(),
    );
  }

  @override
  void write(BinaryWriter writer, Councils obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.subCouncil)
      ..writeByte(1)
      ..write(obj.level3)
      ..writeByte(2)
      ..write(obj.coordOfCouncil)
      ..writeByte(3)
      ..write(obj.presiAndChairPerson);
  }
}
