import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/screens/new_profile.dart';
import 'package:notifier/screens/stu_search/searched_list.dart';
import 'package:notifier/widget/showtoast.dart';

import '../../database/student_search.dart';
import 'searched_list.dart';


class StudentSearch extends StatefulWidget {
  @override
  _StudentSearchState createState() => _StudentSearchState();
}

class _StudentSearchState extends State<StudentSearch> {
  final List<String> year = List.generate(11,(index)=>(index==10)? 'Other':'Y${index + 10}',growable: true);
  final List<String> gender = ['Gender','Male','Female'];
  final List<String> hall = List.generate(13, (index)=>'HALL ${index+1}',growable: true);
  final List<String> program = [
  'Program',
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
  'MSc(2 Yr)',
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
  'Department',
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
  final List<String> bloodGroupList = ['Blood Group','A+','A-','AB+','AB-','B+','B-','O+','O-'];
  bool _isLoading = false;
  String yearIndex;
  String gen ;
  String h;
  String prog;
  String department ;
  String bloodGrp ;
  String hometown ;
  String search1 ;
  SearchModel values = SearchModel();
  // Box _studentBox;
  List<SearchModel> studentData = [];
  @override
  void initState() { 
    super.initState();
    year.insert(0, 'Year');
    year.insert(11, 'Y9');
    year.insert(11, 'Y8');
    yearIndex = year[0];
    hall.insert(13, 'TYPE 5');
    hall.insert(13, 'TYPE 1B');
    hall.insert(13, 'TYPE 1');
    hall.insert(13, 'SBRA');
    hall.insert(13, 'RA');
    hall.insert(13, 'NRA');
    hall.insert(0, 'Hall');
    hall.insert(1, 'GH');
    hall.insert(1, 'DAY');
    hall.insert(1, 'CPWD');
    hall.insert(1, 'ACES');
    h = hall[0];
    prog = program[0];
    bloodGrp = bloodGroupList[0];
    department = dept[0];
    gen = gender[0];
    initDB();
  }
  initDB() async{
    // _studentBox = await HiveDatabaseUser(databaseName: 'ss').hiveBox;
    StuSearchDatabase().getAllStuData();
    // studentData = _studentBox.toMap().values.toList().cast<SearchModel>();
    print(studentData);
    // print(_studentBox.toMap());
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.4;
    return Scaffold(
      appBar: AppBar(
        // title: Text('Student Search'),
        actions: <Widget>[
          // FlatButton(onPressed: ()=>_formKey.currentState.reset(), child: Text('Reset')),
          IconButton(icon: Icon(Icons.refresh), onPressed: ()async{
             if(mounted){
               setState(() {
                 _isLoading = true;
              });
            }
            
            await getStudentDataFromServer().then((var v){
              if(v == true){
                showSuccessToast('Database updated successfully !!!');
              }else{
                showErrorToast('An error occured while updating database');
              }
               if(mounted){
                setState(() {
                  _isLoading = false;
                });
              }
            }).catchError((onError){
              print(onError);
              showErrorToast('An error occured while updating database');
              if(mounted){
                setState(() {
                  _isLoading = false;
                });
              }
            }).timeout(Duration(seconds: 40),onTimeout: (){
              showErrorToast('Your request has timeout out!!! Seems like your internet is slow');
              if(mounted){
                setState(() {
                  _isLoading = false;
                });
              }
            });
          })
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[

            Container(
              // color: Theme.of(context).cardColor,
              color: Theme.of(context).brightness == Brightness.dark? 
                Theme.of(context).cardColor
                : Colors.white.withOpacity(0.8),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(MaterialCommunityIcons.account_search,
                            size: 50,
                          ),
                          SizedBox(width: 10),
                          Text('Student Search',
                            style: TextStyle(
                              fontSize: 30
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)
                        ),
                        color: Theme.of(context).brightness == Brightness.dark? Colors.black : Colors.white,
                        
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark? 
                              Theme.of(context).cardColor
                            : Colors.white.withOpacity(0.8),)
                          ),
                          child: Form(
                            key:_formKey,
                            child: SingleChildScrollView(
                              child: Container(
                                margin: EdgeInsets.all(16.0),
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
                                            child: DropdownButtonFormField(
                                              items: year.map((y){
                                                return DropdownMenuItem(
                                                  child: Text(y),
                                                  value: y,
                                                );
                                              }).toList(), 
                                              // isDense: true,
                                              decoration: InputDecoration(
                                                // labelText: 'Year',
                                                hintText: 'Choose Year...',
                                                // isDense: true
                                              ),
                                              onChanged: (value)=> setState(()=>yearIndex = value),
                                              value: yearIndex,
                                              onSaved: (value){
                                                if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty && value!=year[0]){
                                                   return values.year =value;
                                                }
                                                return values.year ='';
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: width,
                                            child: DropdownButtonFormField(
                                              items: gender.map((g){
                                                return DropdownMenuItem(
                                                  child: Text(g),
                                                  value: g,
                                                );
                                              }).toList(),
                                              decoration: InputDecoration(
                                                // labelText: 'Gender',
                                                hintText: 'Choose Gender...',
                                                // isDense: true
                                              ),
                                              onChanged: (value)=> setState(()=>gen = value),
                                              value: gen,
                                              onSaved: (value){
                                                if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty && value!=gender[0]){
                                                   return values.gender= converttoGenderAbb(value);
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
                                      height: 80,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: width,
                                            child: DropdownButtonFormField(
                                              items: hall.map((hl){
                                                return DropdownMenuItem(
                                                  child: Text(hallName(hl)),
                                                  value: hl,
                                                );
                                              }).toList(), 
                                              // isExpanded: true,
                                              decoration: InputDecoration(
                                                // labelText: 'Hall',
                                                hintText: 'Choose Hall...',
                                                // isDense: true
                                              ),
                                              onChanged: (value)=> setState(()=>h = value),
                                              value: h,
                                              onSaved: (value){
                                                if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty && value!=hall[0]){
                                                  // return true;
                                                  if(value.toString().toLowerCase() == 'hall 10' || value.toString().toLowerCase() == 'hall 11'){
                                                    return values.hall =(value.toString().toLowerCase() == 'hall 10')?'HallX':'HallXI' ;
                                                  }else{
                                                    return values.hall = value;
                                                  }
                                                }else{
                                                  return values.hall = '';
                                                }
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: width,
                                            child: DropdownButtonFormField(
                                              items: program.map((prg){
                                                return DropdownMenuItem(
                                                  child: Text(prg),
                                                  value: prg,
                                                );
                                              }).toList(),
                                              isExpanded: true,
                                              // decoration: InputDecoration(
                                              //   // labelText: 'Programme',
                                              //   // isDense: true
                                              // ),
                                              onChanged: (value)=> setState(()=>prog = value),
                                              value: prog,
                                              onSaved: (value){
                                                if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty && value!=program[0]){
                                                   return values.program = value;
                                                }else{
                                                  return values.program = '';
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.maxFinite,
                                      child: DropdownButtonFormField(
                                        items: dept.map((depart){
                                          return DropdownMenuItem(
                                            child: Text(depart),
                                            value: depart,
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          // labelText: 'Department',
                                          // isDense: true
                                        ),
                                        onChanged: (value)=> setState(()=>department = value),
                                        value: department,
                                        onSaved: (value){
                                          if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty && value!= dept[0]){
                                            return values.dept = value;
                                          }else{
                                            return values.dept = '';
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 18.0),
                                      width: double.maxFinite,
                                      child: DropdownButtonFormField(
                                        items: bloodGroupList.map((bg){
                                          return DropdownMenuItem(
                                            child: Text(bg),
                                            value: bg,
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          // labelText: 'Blood Group',
                                          // isDense: true
                                        ),
                                        onChanged: (value)=> setState(()=>bloodGrp = value),
                                        value: bloodGrp,
                                        onSaved: (value){
                                          if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty && value!= bloodGroupList[0]){
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
                                        // toolbarOptions: ToolbarOptions(
                                        //   cut: true,
                                        //   copy: true,
                                        //   paste: true,
                                        //   selectAll: true,
                                        // ),
                                        maxLines: 1,
                                        keyboardType: TextInputType.text,
                                        autofocus: false,
                                        initialValue: hometown,
                                        decoration: new InputDecoration(
                                          labelText: 'Hometown',
                                        ),
                                        onSaved: (value){
                                          if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
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
                                          hintText: 'Name, Username or Roll No',
                                        ),
                                        onSaved: (value){
                                          if(value!=null && value.isNotEmpty && value.trim()!=null && value.trim().isNotEmpty){
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
                                      constraints: BoxConstraints(
                                        minWidth: 150
                                      ),
                                      child: RaisedButton.icon(
                                        onPressed: ()async{
                                          _formKey.currentState.save();
                                          print(values.hall);
                                          // String gendervalue ="";
                                          // studentData = _studentBox.toMap().values.toList().cast<SearchModel>();
                                          // if(values.gender == 'Any'){
                                          //   gendervalue = "";
                                          // }else{
                                          //   gendervalue = converttoGenderAbb(values.gender);
                                          // }
                                          // print(gendervalue);
                                          // print(values.name);
                                          // // print(studentData.where((test)=>test.rollno.toLowerCase().contains(values.rollno)).toList());
                                          // studentData.retainWhere((test){
                                          //   return 
                                          //   // return test.hall.toLowerCase().contains(h.toLowerCase()) && test.gender.toLowerCase().contains(gendervalue.toLowerCase());
                                          //   (checkifThereisAvalue(values.bloodGroup, test.bloodGroup) && 
                                          //   checkifThereisAvalue(values.dept, test.dept) &&
                                          //   checkifThereisAvalue(gendervalue, test.gender) &&
                                          //   checkifThereisAvalue(values.hall, test.hall) &&
                                          //   checkifThereisAvalue(values.hometown, test.hometown) && 
                                          //   checkifThereisAvalue(values.program, test.program) &&
                                          //   (checkifThereisAvalue(values.rollno, test.rollno) ||
                                          //   checkifThereisAvalue(values.name, test.name) ||
                                          //   checkifThereisAvalue(values.username, test.username)) &&
                                          //   checkifThereisAvalue(values.year,test.year));
                                          // });
                                          // print(studentData);
                                          await Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => Seraching(values)
                                            // SearchedList(studentData) 
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
                          ),
                        )
                      )
                    ),
                  ],
                ),
              ),
            ),
            _isLoading ?
            Container(
              color: Colors.black.withOpacity(0.8),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[                                
                    SpinKitDualRing(color: Theme.of(context).accentColor,size: 40,lineWidth: 5,),
                    SizedBox(height:15),
                    Text('Updating Database',style: TextStyle(color:Colors.white),)
                  ],
                ),
              ),
            ):Container(),
          ],
        ),
      ),
      // bottomSheet: ,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     // Pop
      //     // OverlayEntry(builder: null)
      //   }
      // ),
    );
  }
}
bool checkifThereisAvalue(String value,String checkingValue){
  // print(value);
  value = value.replaceAll(' ', '');
  checkingValue = checkingValue != null ? checkingValue.replaceAll(' ', '') : '';
  return checkingValue.toLowerCase().contains(value.toLowerCase());
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