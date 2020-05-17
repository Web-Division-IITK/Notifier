import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/screens/stu_search/searched_list.dart';
import 'package:notifier/services/functions.dart';


class StudentSearch extends StatefulWidget {
  @override
  _StudentSearchState createState() => _StudentSearchState();
}

class _StudentSearchState extends State<StudentSearch> {
  final List<String> year = List.generate(11,(index)=>(index==0)? 'Other':'Y${index + 9}');

  final List<String> gender = ['Any','Male','Female'];

  final List<String> hall = List.generate(13, (index)=>'HALL${index+1}',growable: true);

  final List<String> program = [
  '',
  'BS',
  'BS-MBA',
  'BS-MS',
  'BS-MT',
  'BT-MBA',
  'BT-MS',
  'BTech',
  'DIIT',
  'Exchng Prog.',
  'MBA',
  'MDes',
  'MS-Research',
  'MSc(2-Yr)',
  'MSc(Int)',
  'MSc-PhD(Dual)',
  'MT(Dual)',
  'MTech',
  'PGPEX-VLM',
  'PhD',
  'Prep.',
  'SURGE'
];

  final List<String> dept = [
  '',
  'AE',
  'BSBE',
  'CE',
  'CHE',
  'CHM',
  'CSE',
  'Cognitive Sciences',
  'DOAA',
  'DORA',
  'Dean Of Research & Development',
  'ECO',
  'EE',
  'EEM',
  'ES',
  'HSS',
  'IME',
  'Laser Technology',
  'MDes',
  'ME',
  'MSE',
  'MTH',
  'Mat.& Met.Engg.',
  'Materials Science Programme',
  'Nucc. Eng.& Tech Prog.',
  'PHY',
  'Photonics Science & Engg.',
  'Statistics',

];
  final _formKey = GlobalKey<FormState>();
  final List<String> bloodGroupList = ['','A+','A-','AB+','AB-','B+','B-','O+','O-'];
  String yearIndex ;
  String gen ;
  String h;
  String prog;
  String department ;
  String bloodGrp ;
  String hometown ;
  String search1 ;
  SearchModel values = SearchModel();
  Box _studentBox;
  List<SearchModel> studentData = [];
  @override
  void initState() { 
    super.initState();
    // hall.add('GH');
    hall.insert(13, 'GH');
    // hall.insert(9, 'HALLX');
    hall[9] = 'HALLX';
    // hall.insert(10, 'HALLXI');
    hall[10] = 'HALLXI';
    gen = gender[0];
    initDB();
  }
  initDB() async{
    _studentBox = await HiveDatabaseUser(databaseName: 'ss').hiveBox;
    
    studentData = _studentBox.toMap().values.toList().cast<SearchModel>();
    print(studentData);
    print(_studentBox.toMap());
  }
  @override
  Widget build(BuildContext context) {
    // print(year);
    double width = MediaQuery.of(context).size.width * 0.4;
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Search'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (strig) async{
              await getStudentData();
            },
            itemBuilder: (BuildContext context) {
              return {'Update Database',}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
 
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0)
            ),
            // margin: EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key:_formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: width,
                              // padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                items: year.map((y){
                                  return DropdownMenuItem(
                                    child: Text(y),
                                    value: y,
                                  );
                                }).toList(), 
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: 'Year',
                                  hintText: 'Choose Year...',
                                  isDense: true
                                ),
                                onChanged: (value)=> setState(()=>yearIndex = value),
                                value: yearIndex,
                                onSaved: (value){
                                 
                                  if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
                                    // print(checkingValue.toLowerCase().contains(value.toLowerCase()));
                                    // return checkingValue.toLowerCase().contains(value.toLowerCase());
                                    // return true;
                                     return values.year =value;
                                  }
                                  return values.year ='';
                                }
                                ,
                              ),
                            ),
                            Container(
                              width: width,
                              // padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                items: gender.map((g){
                                  return DropdownMenuItem(
                                    child: Text(g),
                                    value: g,
                                  );
                                }).toList(), 
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  hintText: 'Choose Gender...',
                                  isDense: true
                                ),
                                onChanged: (value)=> setState(()=>gen = value),
                                value: gen,
                                onSaved: (value){
                                  if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
                                    // return true;
                                     return values.gender= value;
                                  }
                                  return values.gender = '';
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: width,
                              // padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                items: hall.map((hl){
                                  return DropdownMenuItem(
                                    child: Text(hl),
                                    value: hl,
                                  );
                                }).toList(), 
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: 'Hall',
                                  hintText: 'Choose Hall...',
                                  isDense: true
                                ),
                                onChanged: (value)=> setState(()=>h = value),
                                value: h,
                                onSaved: (value){
                                   if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
                                    // return true;
                                     return values.hall = value;
                                  }else{
                                    return values.hall = '';
                                  }
                                },
                              ),
                            ),
                            Container(
                              width: width,
                              // padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                items: program.map((prg){
                                  return DropdownMenuItem(
                                    child: Text(prg),
                                    value: prg,
                                  );
                                }).toList(), 
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: 'Programme',
                                  // hintText: 'Choose Gender...',
                                  isDense: true
                                ),
                                onChanged: (value)=> setState(()=>prog = value),
                                value: prog,
                                onSaved: (value){
                                  if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
                                    // print(checkingValue.toLowerCase().contains(value.toLowerCase()));
                                    // return checkingValue.toLowerCase().contains(value.toLowerCase());
                                    // return true;
                                     return values.program = value;
                                  }else{
                                    return values.program = '';
                                  }
                                  // prog = v
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                       Container(
                              width: double.maxFinite,
                              // padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                items: dept.map((depart){
                                  return DropdownMenuItem(
                                    child: Text(depart),
                                    value: depart,
                                  );
                                }).toList(), 
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: 'Department',
                                  // hintText: 'Choose Year...',
                                  isDense: true
                                ),
                                onChanged: (value)=> setState(()=>department = value),
                                value: department,
                                onSaved: (value){
                                  if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
                                    // print(checkingValue.toLowerCase().contains(value.toLowerCase()));
                                    // return checkingValue.toLowerCase().contains(value.toLowerCase());
                                    // return true;
                                     return values.dept = value;
                                  }else{
                                    return values.dept = '';
                                  }
                                },
                              ),
                            ),
                       Container(
                              width: double.maxFinite,
                              child: DropdownButtonFormField(
                                items: bloodGroupList.map((bg){
                                  return DropdownMenuItem(
                                    child: Text(bg),
                                    value: bg,
                                  );
                                }).toList(), 
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: 'Blood Group',
                                  // hintText: 'Choose Gender...',
                                  isDense: true
                                ),
                                onChanged: (value)=> setState(()=>bloodGrp = value),
                                value: bloodGrp,
                                onSaved: (value){
                                  if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
                                    // print(checkingValue.toLowerCase().contains(value.toLowerCase()));
                                    // return checkingValue.toLowerCase().contains(value.toLowerCase());
                                    // return true;
                                     return values.bloodGroup = value;
                                  }else{
                                    return values.bloodGroup = '';
                                  }
                                },
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical:8.0),
                        child: TextFormField(
                          toolbarOptions: ToolbarOptions(
                            copy: true,
                            paste: true,
                            selectAll: true,
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          initialValue: hometown,
                          decoration: new InputDecoration(
                            labelText: 'Hometown',
                            // hintText: 'Title of the Post',
                            // helperText: 'Title would be displayed in the notification'
                          ),
                          onSaved: (value){
                            if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
                                    // print(checkingValue.toLowerCase().contains(value.toLowerCase()));
                                    // return checkingValue.toLowerCase().contains(value.toLowerCase());
                                    // return true;
                                     return values.hometown = value;
                                  }else{
                                    return values.hometown = '';
                                  }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical:8.0),
                        child: TextFormField(
                          toolbarOptions: ToolbarOptions(
                            copy: true,
                            paste: true,
                            selectAll: true,
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          initialValue: search1,
                          decoration: new InputDecoration(
                            // labelText: '',
                            hintText: 'Name, Username or Roll No',
                          ),
                          onSaved: (value){
                            if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
                                    // print(checkingValue.toLowerCase().contains(value.toLowerCase()));
                                    // return checkingValue.toLowerCase().contains(value.toLowerCase());
                                    // return true;
                                    values.username = value;
                                    values.rollno = value;
                                     return  values.name = value;
                                  }else{
                                    values.username = '';
                                    values.rollno = '';
                                    return values.name = '';
                                  }
                          },
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.all(16.0),
                        // height:45.0,
                        constraints: BoxConstraints(
                          minWidth: 150
                        ),
                        child: RaisedButton.icon(
                          onPressed: ()async{
                            _formKey.currentState.save();
                            String gendervalue ="";
                            studentData = _studentBox.toMap().values.toList().cast<SearchModel>();
                            if(values.gender == 'Any'){
                              gendervalue = "";
                            }else{
                              gendervalue = converttoGenderAbb(values.gender);
                            }
                            print(gendervalue);
                            print(values.name);
                            // print(studentData.where((test)=>test.rollno.toLowerCase().contains(values.rollno)).toList());
                            studentData.retainWhere((test){
                              return 
                              // return test.hall.toLowerCase().contains(h.toLowerCase()) && test.gender.toLowerCase().contains(gendervalue.toLowerCase());
                              (checkifThereisAvalue(values.bloodGroup, test.bloodGroup) && 
                              checkifThereisAvalue(values.dept, test.dept) &&
                              checkifThereisAvalue(gendervalue, test.gender) &&
                              checkifThereisAvalue(values.hall, test.hall) &&
                              checkifThereisAvalue(values.hometown, test.hometown) && 
                              checkifThereisAvalue(values.program, test.program) &&
                              (checkifThereisAvalue(values.rollno, test.rollno) ||
                              checkifThereisAvalue(values.name, test.name) ||
                              checkifThereisAvalue(values.username, test.username)) &&
                              checkifThereisAvalue(values.year,test.year));
                            });
                            // print(studentData);
                            await Navigator.push(context, MaterialPageRoute(
                              builder: (context) => SearchedList(studentData) 
                            ));
                          }, 
                          icon: Icon(Icons.search), 
                          label: Text('Search',style: TextStyle(fontSize: 15.0),)
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          )
        ),
      )
    );
  }
}
bool checkifThereisAvalue(String value,String checkingValue){
  print(value);
  value = value.replaceAll(' ', '');
  checkingValue = checkingValue != null ? checkingValue.replaceAll(' ', '') : '';
  // if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
    // print(checkingValue.toLowerCase().contains(value.toLowerCase()));
    return checkingValue.toLowerCase().contains(value.toLowerCase());
  // }
  // return true;
}



converttoGenderAbb(String gender){
  if (gender == 'Male') {
    return 'M';
  } else if(gender == 'Female'){
    return 'F';
  }else{
    return gender;
  }
}