
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
  factory SearchModel.fromMap(Map<String,dynamic>jsonData){
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
      bloodGroup: jsonData.containsKey('bloodGroup')?jsonData['bloodGroup']:'',
      dept: jsonData.containsKey('dept')?jsonData['dept']:'',
      gender: jsonData.containsKey('gender')?jsonData['gender']:'',
      hall: jsonData.containsKey('hall')?jsonData['hall']:'',
      hometown: jsonData.containsKey('hometown')?jsonData['hometown']:'',
      name: jsonData.containsKey('name')?jsonData['name']:'',
      program: jsonData.containsKey('program')?jsonData['program']:'',
      rollno: jsonData.containsKey('rollno')?jsonData['rollno']:'',
      room: jsonData.containsKey('room')?jsonData['room']:'',
      username: jsonData.containsKey('username')?jsonData['username']:'',
      year: yearIndex
    );
  }
  fromMaptoMap(Map<String,dynamic> jsonData) =>{
   'bloodGroup': jsonData.containsKey('blood_group')?jsonData['blood_group']:'',
      'dept': jsonData.containsKey('dept')?jsonData['dept']:'',
      'gender': jsonData.containsKey('gender')?jsonData['gender']:'',
      'hall': jsonData.containsKey('hall')?jsonData['hall']:'',
      'hometown': jsonData.containsKey('hometown')?jsonData['hometown']:'',
      'name': jsonData.containsKey('name')?jsonData['name']:'',
      'program': jsonData.containsKey('program')?jsonData['program']:'',
      'rollno': jsonData.containsKey('roll')?jsonData['roll']:'',
      'room': jsonData.containsKey('room')?jsonData['room']:'',
      'username': jsonData.containsKey('username')?jsonData['username']:'',
      'year': 'Others'
  };
  Map<String, dynamic> toMap() =>{
    'rollno':rollno!=null && rollno.replaceAll(' ', '')!=''?rollno:'',
    'name': name!=null && name.replaceAll(' ', '')!=''?name:'',
    'username': username!=null && username.replaceAll(' ', '')!=''?username:'',
    'bloodGroup' : bloodGroup!=null && bloodGroup.replaceAll(' ', '')!=''?bloodGroup:'',
    'hall': hall!=null && hall.replaceAll(' ', '')!=''?hall:'',
    'dept': dept!=null && dept.replaceAll(' ', '')!=''?dept:'',
    'gender': gender!=null && gender.replaceAll(' ', '')!=''?gender:'',
    'hometown': hometown!=null && hometown.replaceAll(' ', '')!=''?hometown:'',
    'program': program!=null && program.replaceAll(' ', '')!=''?program:'',
    'room': room!=null && room.replaceAll(' ', '')!=''?room:'',
    'year': year!=null && year.replaceAll(' ', '')!=''?year:'Others'
  };
}