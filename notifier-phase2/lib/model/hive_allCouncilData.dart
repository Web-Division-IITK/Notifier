import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
part 'hive_allCouncilData.g.dart';

// /// here id is email id 
// @HiveType(typeId: 1)
// class AllCouncilData{
//   @HiveField(0)
//   List<String> level3;
//   @HiveField(1)
//   List<String> councils;
//   @HiveField(2)
//   List<String> gns;
//   @HiveField(3)
//   List<String> mnc;
//   @HiveField(4)
//   List<String> psg;
//   @HiveField(5)
//   List<String> snt;
//   @HiveField(6)
//   List<String> senate;
//   @HiveField(7)
//   List<String> councils;
//   @HiveField(8)
//   Map<String,List<String>> posts;
//   // DateTime birthDate;

//   AllCouncilData({this.id, this.anc,this.gns,this.mnc,this.psg,this.snt,this.senate,this.councils,this.posts});
// }



@HiveType(typeId: 4)
class SubCouncil{
  @HiveField(0)
  final String council;
  @HiveField(1)
  final List<String> level2;
  @HiveField(2)
   List<String> misc;
   @HiveField(3)
  List<String> coordiOfInCouncil;
  @HiveField(4)
  final List<String> entity;
  @HiveField(5)
  List<bool>select=[];
  SubCouncil({@required this.entity,this.level2,@required this.misc,this.coordiOfInCouncil,@required this.council, this.select});

  factory SubCouncil.fromMap(Map<String,dynamic>jsonData,String councilName) {
    if(jsonData == null){
     return SubCouncil(entity: [], misc: [], council: '',coordiOfInCouncil: [],level2: [],select: []);
   }else{
    return SubCouncil(
      coordiOfInCouncil: [],
      council: councilName,
      level2:jsonData['level2'] ==null? []: jsonData['level2'].cast<String>(),
      entity: [],
      misc: jsonData['misc'] ==null? []:jsonData['misc'].cast<String>(),  
      select: []
    );
   }
  }
  factory SubCouncil.fromMapToCouncil(Map<String,dynamic>jsonData,String councilName) {
   if(jsonData == null){
     return SubCouncil(entity: [], misc: [], council: '',coordiOfInCouncil: [],level2: [],select: []);
   }else{
      return SubCouncil(
      coordiOfInCouncil: [],
      council:councilName,
      level2:jsonData['level2'] ==null? []: jsonData['level2'].cast<String>(),
      entity:jsonData['entity'] ==null? []: jsonData['entity'].cast<String>(),
      misc: jsonData['misc'] ==null? []:jsonData['misc'].cast<String>(),
      select: List.generate(jsonData['entity'].length, (index)=>true,growable: true)
    );
   }
  }
}
@HiveType(typeId: 3)
class Councils{
  @HiveField(0)
  Map<String,SubCouncil> subCouncil = {};
  @HiveField(1)
  final List<String> level3;
  @HiveField(2)
  List<String> coordOfCouncil = [];
  @HiveField(3)
  final Map<String, SubCouncil> presiAndChairPerson ;
  Councils({this.subCouncil,this.coordOfCouncil,this.level3,this.presiAndChairPerson});
  
  factory Councils.fromMap(Map<String,dynamic> jsonData){
    List<String> councils = jsonData['councils'].cast<String>();
    List<String> presiAndChairPerson = (jsonData['presiAndChairPerson'] == null || jsonData['presiAndChairPerson'] == [])?
      []
      : jsonData['presiAndChairPerson'].cast<String>();
    print(jsonData['level3']);
    return Councils(
      coordOfCouncil: [],
      level3: jsonData['level3'].cast<String>(),
      subCouncil: Map.fromIterables(councils, councils.map((council)=> SubCouncil.fromMapToCouncil(jsonData[council], council))),
      presiAndChairPerson: Map.fromIterables(presiAndChairPerson, presiAndChairPerson.map((f)=>SubCouncil.fromMap(jsonData[f], f)))
    );
  }
}