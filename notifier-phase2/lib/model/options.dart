import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notifier/model/hive_models/hive_allCouncilData.dart';

class People{
  // final String title;
  final dynamic  popleData;
  final bool status;
  People(this.popleData,this.status);
}
/// [eg: an id 1234 is coordinator of Eclub in snt and Dance club in mnc then this list has councils as ['snt','mnc'] 
/// globalCouncils as name of all councils;  entity,misc , level2 as name of all clubs of every council with index same as index in globalCouncils
/// ;  has council as name of council in globalCouncils;  sub as the ['Eclub'] for 'snt' and ['Dance club'] for mnc] 
// class Councils{
//   ///it is the name of councils of whose the person is coordinators
//   List<dynamic> councils; 
//   /// all councils
//   final List<dynamic> globalCouncils;
//   /// entity of a council
//   final List<dynamic> entity;
//   List<bool>select = [];
//   final List<dynamic> misc;
//   final List<dynamic> level2;
//   /// persons with superior authority
//   final List<dynamic> level3;
//   /// name of council
//   final String council;
//   /// it is the array of the name of clubs of a particular council of whoose the person is coordinator;
//   /// like person is coordinator in snt and mnc then this array has separate name of the clubs or hobby groups where he is the coordinator
//   /// with the name of council same as the name of council
  
//  List<dynamic> sub;
//   Councils({this.council,this.select,this.globalCouncils,this.councils,this.entity,this.level2,this.level3,this.misc,this.sub});
// }

// class SubCouncil{
//   final String council;
//   final List<String> level2;
//    List<String> misc;
//   List<String> coordiOfInCouncil;
//   final List<String> entity;
//   List<bool>select=[];
//   SubCouncil({@required this.entity,this.level2,@required this.misc,this.coordiOfInCouncil,@required this.council, this.select});

//   factory SubCouncil.fromMap(Map<String,dynamic>jsonData,String councilName) {
//     if(jsonData == null){
//      return SubCouncil(entity: [], misc: [], council: '',coordiOfInCouncil: [],level2: [],select: []);
//    }else{
//     return SubCouncil(
//       coordiOfInCouncil: [],
//       council: councilName,
//       level2:jsonData['level2'] ==null? []: jsonData['level2'].cast<String>(),
//       entity: [],
//       misc: jsonData['misc'] ==null? []:jsonData['misc'].cast<String>(),  
//       select: []
//     );
//    }
//   }
//   factory SubCouncil.fromMapToCouncil(Map<String,dynamic>jsonData,String councilName) {
//    if(jsonData == null){
//      return SubCouncil(entity: [], misc: [], council: '',coordiOfInCouncil: [],level2: [],select: []);
//    }else{
//       return SubCouncil(
//       coordiOfInCouncil: [],
//       council:councilName,
//       level2:jsonData['level2'] ==null? []: jsonData['level2'].cast<String>(),
//       entity:jsonData['entity'] ==null? []: jsonData['entity'].cast<String>(),
//       misc: jsonData['misc'] ==null? []:jsonData['misc'].cast<String>(),
//       select: List.generate(jsonData['entity'].length, (index)=>true)
//     );
//    }
//   }
// }
// // class Prefren{
// //    List<String> entity;
// //    List<String> misc;
// //    String council; 
// //   Prefren(this.entity,this.misc,this.council);
// // }


// // class Councils{
// //    final List<SubCouncil> subCouncil ;
// //   final  List<String> globalCouncils ;
// //   final  List<String> councilsWithNoPower ;
// //   final  List<String> level3;
// //   ///president student gymkhana
// //   final  List<SubCouncil> presiChairPerson;
// //   List<String> coordOfCouncil =[];
// //   Councils({this.coordOfCouncil,this.globalCouncils,this.level3,this.subCouncil,@required this.presiChairPerson,@required this.councilsWithNoPower});
// //   // final 
// // }

// class Councils{
//   Map<String,SubCouncil> subCouncil = {};
//   final List<String> level3;
//   List<String> coordOfCouncil = [];
//   final Map<String, SubCouncil> presiAndChairPerson ;
//   Councils({this.subCouncil,this.coordOfCouncil,this.level3,this.presiAndChairPerson});
//   factory Councils.fromMap(Map<String,dynamic> jsonData){
//     List<String> councils = jsonData['councils'].cast<String>();
//     List<String> presiAndChairPerson = jsonData['presiAndChairPerson'].cast<String>();
//     print(jsonData['level3']);
//     return Councils(
//       coordOfCouncil: [],
//       level3: jsonData['level3'].cast<String>(),
//       subCouncil: Map.fromIterables(councils, councils.map((council)=> SubCouncil.fromMapToCouncil(jsonData[council], council))),
//       presiAndChairPerson: Map.fromIterables(presiAndChairPerson, presiAndChairPerson.map((f)=>SubCouncil.fromMap(jsonData[f], f)))
//     );
//   }
// }


class Repository{
  final Councils allCouncilData;
  Repository(this.allCouncilData);
  List<SubCouncil> getAll() => allCouncilData.subCouncil.values.toList();

  getEntityBCouncil(String councilName) => allCouncilData.subCouncil.values.toList()
  .where((item) => item.council == councilName).map((item)=>(item.entity + item.misc))
  .expand((i) => i).toList();

  List<String> getCouncil() =>allCouncilData.subCouncil.values.toList().map((item) =>item.council).toList();
  getEntityofCoordiByCouncil(String council) => allCouncilData.subCouncil.values.toList()
  .where((item) =>item.council == council).map((item)=> item.coordiOfInCouncil)
  .expand((i) => i).toList();
  List<String> getpresis() =>allCouncilData.presiAndChairPerson.values.toList().map((item) =>item.council).toList();
  getEntityofChairByCouncil(String council) => allCouncilData.presiAndChairPerson.values.toList()
  .where((item) =>item.council == council).map((item)=> (item.entity + item.misc))
  .expand((i) => i).toList();
  List<String> getCoordiCouncil() =>allCouncilData.coordOfCouncil;
}

class AddingImage{
  String url;
  File image;
  AddingImage({@required this.image,@required this.url});
}

class PriorityAndImportance{
  var importance;
  var priority;
  PriorityAndImportance({this.importance,this.priority});
}
// class People