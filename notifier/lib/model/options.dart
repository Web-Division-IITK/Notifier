class Options{
  final String title;
  final List<String>  name;
  final List<bool> isSelected;
  Options(this.title,this.name,this.isSelected);
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

class SubCouncil{
  final String council;
  final List<String> level2;
  final List<String> misc;
  List<String> coordiOfInCouncil;
  final List<String> entity;
  List<bool>select=[];
  SubCouncil({this.entity,this.level2,this.misc,this.coordiOfInCouncil,this.council,this.select});
}
class Prefren{
   List<String> entity;
   List<String> misc;
   String council; 
  Prefren(this.entity,this.misc,this.council);
}


class Councils{
   final List<SubCouncil> subCouncil ;
  final  List<String> globalCouncils ;
  final  List<String> level3;
  List<String> coordOfCouncil =[];
  Councils({this.coordOfCouncil,this.globalCouncils,this.level3,this.subCouncil});
  // final 
}


class Repository{
  final Councils allCouncilData;
  Repository(this.allCouncilData);
  List<SubCouncil> getAll() => allCouncilData.subCouncil;

  getEntityBCouncil(String councilName) => allCouncilData.subCouncil
  .where((item) => item.council == councilName).map((item)=>(item.entity + item.misc))
  .expand((i) => i).toList();

  List<String> getCouncil() =>allCouncilData.subCouncil.map((item) =>item.council).toList();
  getEntityofCoordiByCouncil(String council) => allCouncilData.subCouncil
  .where((item) =>item.council == council).map((item)=> item.coordiOfInCouncil)
  .expand((i) => i).toList();
  List<String> getCoordiCouncil() =>allCouncilData.coordOfCouncil;
}
// class Options