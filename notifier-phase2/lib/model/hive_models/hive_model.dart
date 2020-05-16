import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

part 'hive_model.g.dart';

/// here id is email id 
@HiveType(typeId: 1)
class UserModel{
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String rollno;
  @HiveField(3)
  String uid;
  @HiveField(4)
  List<String> prefs;
  @HiveField(5)
  bool admin;
  // @HiveField(6)
  // Map<String,List<String>> councils;
  // @HiveField(7)
  // Map<String,List<String>> posts;
  UserModel({@required this.id,@required this.name, @required this.rollno,@required this.uid,@required this.prefs,@required this.admin/*,this.councils,this.posts*/});
  toMap() => {
    "id": id,
    "admin":admin,
    "name":name,
    "rollno":rollno,
    "uid": uid,
    "prefs":prefs,
  };
}