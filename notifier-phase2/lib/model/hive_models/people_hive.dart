import 'package:hive/hive.dart';

part 'people_hive.g.dart';

/// here id is email id 
@HiveType(typeId: 2)
class PeopleModel{
  @HiveField(0)
  String id;
  @HiveField(1)
  Map<String,List<String>> councils;
  @HiveField(2)
  Map<String,dynamic> posts;
  // DateTime birthDate;

  PeopleModel({this.id,this.councils,this.posts});
  factory PeopleModel.fromMap(Map<String,dynamic> jsonData){
    List<dynamic> council =jsonData['councils'];
    return PeopleModel(
      councils: Map.fromIterable(council,
        key: (item) => item.toString(),
        value: (item) => jsonData[item].cast<String>(),
      ),
      // Map.fromIterables(jsonData['councils'].cast<String>(), jsonData['councils'].map((council)=> jsonData[council].cast<String>())),
      id: jsonData['id'],
      posts: jsonData['posts']
    );
  }
}