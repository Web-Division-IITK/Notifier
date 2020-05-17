
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'ss_model.g.dart';

/// here id is email id 
@HiveType(typeId: 5)
class SearchModel{
  @HiveField(0)
  String username;
  @HiveField(1)
  String name;
  @HiveField(2)
  String rollno;
  @HiveField(3)
  String program;
  @HiveField(4)
  String dept;
  @HiveField(5)
  String hall;
  @HiveField(6)
  String room;
  @HiveField(7)
  String bloodGroup;
  @HiveField(8)
  String gender;
  @HiveField(9)
  String hometown;
  @HiveField(10)
  String year;

  SearchModel({this.bloodGroup,this.dept,this.gender,this.hall,this.hometown,this.name,this.program,this.rollno,this.room,this.username,this.year});
  factory SearchModel.fromMap(jsonData){
    String roll = jsonData['rollno'].toString().substring(0,2);
    String yearIndex = "";
    if(!roll.startsWith(RegExp(r'[0-9]')) ){
      yearIndex = "Others";
    }else{
      if(int.parse(roll)<=DateTime.now().year.remainder(1000)){
        yearIndex = "Y$roll";
      }else{
        yearIndex = "Others";
      }
    }
    return SearchModel(
      bloodGroup: jsonData['bloodGroup'],
      dept: jsonData['dept'],
      gender: jsonData['gender'],
      hall: jsonData['hall'],
      hometown: jsonData['hometown'],
      name: jsonData['name'],
      program: jsonData['program'],
      rollno: jsonData['rollno'],
      room: jsonData['room'],
      username: jsonData['username'],
      year: yearIndex
    );
  }
  fromMaptoMap(Map<String,dynamic> jsonData) =>{
   'bloodGroup': jsonData['blood_group'],
      'dept': jsonData['dept'],
      'gender': jsonData['gender'],
      'hall': jsonData['hall'],
      'hometown': jsonData['hometown'],
      'name': jsonData['name'],
      'program': jsonData['program'],
      'rollno': jsonData['roll'],
      'room': jsonData['room'],
      'username': jsonData['username'],
      'year': 'Others'
  };
  Map<String, dynamic> toMap() =>{
    'rollno':rollno,
    'name':name,
    'username':username,
    'bloodGroup' : bloodGroup,
    'hall': hall,
    'dept':dept,
    'gender':gender,
    'hometown':hometown,
    'program':program,
    'room':room,
    'year':year
  };
}