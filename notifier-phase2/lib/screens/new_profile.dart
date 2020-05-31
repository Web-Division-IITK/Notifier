import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/database/mogo_database.dart';
import 'package:notifier/database/student_search.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/profile/profilepic.dart';
import 'package:notifier/screens/stu_search/searched_list.dart';
import 'package:notifier/widget/showtoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Profile extends StatefulWidget {
  final AsyncMemoizer memorizer;
  Profile(this.memorizer);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var _jsonData;
  bool _load;
  String rollno;
  Box userBox;
  // mongo.Db db;
  List<String> por = [];
  // mongo.DbCollection _dbCollection;
  // DBConnection connection;
  // Box _stuSearch;
  bool showMoreInfo = false;
  SearchModel searchModel = SearchModel();
  final List<String> hall = List.generate(13, (index)=>'Hall ${index+1}',growable: true);
  Future<bool> preferen() async {
    // _stuSearch = await HiveDatabaseUser(databaseName: 'ss').hiveBox;
    userBox = await HiveDatabaseUser().hiveBox;
    if(userBox.isNotEmpty){
      List<SearchModel> list= await StuSearchDatabase().getAllPostswithQuery(QueryDatabase(['username'], [id]));
      // userBox.toMap()[0];
      // List<SearchModel> list = _stuSearch.toMap().values.toList().cast<SearchModel>();
      print(list.length);
      List<SearchModel> val = list.where((test)=>test.username == id).toList();
      print(val);
      if(val==null || val.length==0){
        val = [SearchModel(bloodGroup: '',dept: '',gender: '',hall: '',hometown: '',name: '',program: '',rollno: '', room: '',username: '',year: 'Others')];
      }
      _jsonData = val[0].toMap();
        setState(() {
          searchModel = val[0];
          // val[0].name = name;
          name = val[0].name;
          print(val[0].toMap());
          // name = _jsonData['name'];
          // val[0].rollno = rollno;
          rollno = val[0].rollno;
          print(val[0].rollno);
          // rollno = _jsonData['rollno'];
          // print(_jsonData);
          // print(_jsonData['prefs']);
        });
        return true;
    }    return false;
  }

  Future<bool> writeposts() async {
    userBox.toMap()[0].name = _jsonData['name'];
    userBox.toMap()[0].rollno = _jsonData['rollno'];
    return await userBox.putAt(0, userBox.toMap()[0]).then((v){
      return true;
    }).catchError((onError){
      print(onError);
      return false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load = true;
    for (var council in allCouncilData.coordOfCouncil) 
      por+=allCouncilData.subCouncil[council].coordiOfInCouncil;
    por.sort((a,b)=>a.length.compareTo(b.length));
    hall.insert(13, 'Type 5');
    hall.insert(13, 'Type 1B');
    hall.insert(13, 'Type 1');
    hall.insert(13, 'SBRA');
    hall.insert(13, 'RA');
    hall.insert(13, 'NRA');
    hall.insert(0, 'GH');
    hall.insert(0, 'DAY');
    hall.insert(0, 'CPWD');
    hall.insert(0, 'ACES');
    preferen().then((bool v) {
      if (v != null) {
        setState(() {
          _load = false;
        });
      } else{

      }
    });
    // writeposts();
  }
  Future<bool>changeStudentData(Map<String,dynamic> map) async{
    try {
      Map<String, String> headers = {"Content-type": "application/json"};
      final String url = 'http://ec2-18-204-20-179.compute-1.amazonaws.com/updateStudent';
      Response res = await post(url,headers: headers,body: jsonEncode(map));
      if(res.statusCode == 200){
        return true;
      }
      return false;
    } catch (e) {
      print('Error' + e.toString());
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: _load?
        Container(child: Center(child: CircularProgressIndicator(),),)
        : Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      height: showMoreInfo?
                        230
                      :200.0,
                      color: Theme.of(context).colorScheme.brightness == Brightness.dark?
                        Colors.blueGrey[800]
                        : Colors.blueGrey,
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back),
                              iconSize: 30,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              color: Colors.white,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              padding: EdgeInsets.only(top:10.0),
                              child: Text('E-iCard',style: TextStyle(
                                fontSize: 25.0,
                                color: Colors.white,
                                fontFamily: 'Nunito',
                              ),),
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.topRight,
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Icon(
                          //       Icons.settings,
                          //       color: Colors.white
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(20, 110, 20, 0),
                        constraints: BoxConstraints(
                          minHeight: 200
                        ),  
                        child: Card(
                          color: Theme.of(context).brightness == Brightness.dark?Colors.black : Colors.white,
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding:  EdgeInsets.only(top: 70,bottom: 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                      name == null || name == '' ? '$id@iitk.ac.in' : '${_jsonData['name']}',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.bold,
                                        height:1.4,
                                        fontSize: 17.0,
                                        // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                      ),
                                    ),
                                // Row(
                                //   children: <Widget>[
                                //     Text(
                                //       name == null || name == '' ? 'CC-Id :  ' : 'Name :  ',
                                //       style: TextStyle(
                                //         fontFamily: 'Comfortaa',
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 17.0,
                                //         // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                //       ),
                                //     ),
                                //     Text(
                                //       name == null || name == '' ? id : _jsonData['name'],
                                //       style: TextStyle(
                                //         fontFamily: 'Comfortaa',
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 17.0,
                                //         // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                SizedBox(height: 7.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // name == null || name == ''
                                  //     ? Text('')
                                  //     : Text(
                                  //         'CC-Id :  ',
                                  //         style: TextStyle(
                                  //           fontFamily: 'Comfortaa',
                                  //           fontWeight: FontWeight.bold,
                                  //           fontSize: 17.0,
                                  //           // color: Colors.grey
                                  //         ),
                                  //       ),
                                  name == null || name == ''
                                      ? Text('')
                                      : Text(
                                          id+ '@iitk.ac.in',
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.0,
                                            // color: Colors.grey
                                            ),
                                        ),
                                ],
                              ),
                            rollno == null || rollno == ''
                                  ?SizedBox():SizedBox(height: 10.0,),
                                    rollno == null || rollno == ''
                                  ? Text('')
                                  : Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          // Text(
                                          //     'Roll No :  ',
                                          //     style: TextStyle(
                                          //         fontFamily: 'Comfortaa',
                                          //         fontWeight: FontWeight.bold,
                                          //         fontSize: 17.0,
                                          //         // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                          //     ),
                                          //   ),
                                          Text(
                                              rollno,
                                              style: TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.0,
                                                  // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                              ),
                                            ),
                                        ],
                                      ),
                                      
                                      showMoreInfo? Container(
                                        margin: EdgeInsets.only(top:10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            searchModel == null || searchModel.dept == null || searchModel.dept.replaceAll(' ', '') == ''?
                                            Text(''):
                                           Text(
                                              'Dept. :  ${searchModel.dept}',
                                              // 'Program:  Eletrical Engg. (Btech.)',
                                              style: TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontWeight: FontWeight.bold,
                                                  height:1.4,
                                                  fontSize: 17.0,
                                                  // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                              ),
                                          ), 
                                          // Wrap(
                                          //   children: <Widget>[
                                          //     Text(
                                          //     'Department:  ',
                                          //     style: TextStyle(
                                          //         fontFamily: 'Comfortaa',
                                          //         fontWeight: FontWeight.bold,
                                          //         fontSize: 17.0,
                                          //         // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                          //     ),
                                          //   ),
                                          //     Text(
                                          //       '${searchModel.dept} (${searchModel.program})',
                                          //       maxLines: 2,
                                          //       style: TextStyle(
                                          //           fontFamily: 'Comfortaa',
                                          //           fontWeight: FontWeight.bold,
                                          //           fontSize: 17.0,
                                          //           // color: Theme.of(context).cardColor
                                          //         ),
                                          //       ),
                                          //   ],
                                          // ),
                                          searchModel == null || searchModel.room == null || searchModel.room.replaceAll(' ', '') == ''?
                                            SizedBox():
                                            !showMoreInfo?SizedBox():SizedBox(height: 5.0,),
                                            searchModel == null || searchModel.room == null || searchModel.room.replaceAll(' ', '') == ''?
                                            SizedBox():
                                            Row(
                                              children: <Widget>[
                                                Text(
                                              'Room :  ',
                                              style: TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.0,
                                                  // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                              ),
                                            ),
                                                Text(
                                                  '${searchModel.room}',
                                                  style: TextStyle(
                                                    fontFamily: 'Comfortaa',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17.0,
                                                    // color: Theme.of(context).cardColor
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Tooltip(
                                                  message: 'Update Room',
                                                  child: CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: (){
                                                        _updateDialog('room');
                                                      },
                                                      child: Icon(Icons.edit,
                                                      color: Theme.of(context).iconTheme.color,
                                                      size: 20,),
                                                    )),
                                                )
                                              ],
                                            ),
                                            searchModel == null || searchModel.hall == null || searchModel.hall.replaceAll(' ', '') == ''?
                                            SizedBox():
                                            Row(
                                              children: <Widget>[
                                                Text(
                                              'Hall :  ',
                                              style: TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.0,
                                              ),
                                            ),
                                                Text(
                                                  '${hallName(searchModel.hall)}',
                                                  style: TextStyle(
                                                    fontFamily: 'Comfortaa',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17.0,
                                                    // color: Theme.of(context).cardColor
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Tooltip(
                                                  message: 'Update Hall',
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor: Colors.transparent,
                                                    child: InkWell  (
                                                      onTap: (){
                                                      _updateDialog('hall');
                                                    },
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Theme.of(context).iconTheme.color,
                                                        size: 20,
                                                      ))),
                                                  
                                                )
                                              ],
                                            ),
                                            searchModel == null || searchModel.hometown == null || searchModel.hometown.replaceAll(' ', '') == ''?
                                            SizedBox():
                                            !showMoreInfo?SizedBox():SizedBox(height: 5.0,),
                                            searchModel == null || searchModel.hometown == null || searchModel.hometown.replaceAll(' ', '') == ''?
                                            SizedBox():
                                            Text(
                                              'Hometown :  ${searchModel.hometown}',
                                              style: TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.4,
                                                  fontSize: 17.0,
                                                  // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                              ),
                                            ),
                                            // Row(
                                            //   children: <Widget>[
                                            //     Text(
                                            //   'Hometown :  ',
                                            //   style: TextStyle(
                                            //       fontFamily: 'Comfortaa',
                                            //       fontWeight: FontWeight.bold,
                                            //       fontSize: 17.0,
                                            //       // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white
                                            //   ),
                                            // ),
                                            //     Text(
                                            //       '${searchModel.hometown}',
                                            //       style: TextStyle(
                                            //         fontFamily: 'Comfortaa',
                                            //         fontWeight: FontWeight.bold,
                                            //         fontSize: 17.0,
                                            //         // color: Theme.of(context).cardColor
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ):Container(),
                                      SizedBox(height:20)
                                      // Container(
                                      //   margin: EdgeInsets.symmetric(vertical:10),
                                      //   // width: 200,
                                      //   alignment: Alignment.center,
                                      //   child: IconButton(
                                      //     icon: Icon(
                                      //       showMoreInfo?
                                      //       AntDesign.upcircleo
                                      //       :AntDesign.downcircleo
                                      //     ),
                                      //     // color: Theme.of(context).brightness == Brightness.dark ? Colors.black:Colors.white, 
                                      //     onPressed: (){
                                      //       setState(() {
                                      //         showMoreInfo = !showMoreInfo;
                                      //       });
                                      //     }
                                      //   ),
                                      // ),
                                    ]
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.only(top: 60.0),
                        child: FutureBuilder(
                                future: ProfilePic(searchModel).getUserProfilePic(),
                                builder: (context, snapshot){
                                  print(searchModel.gender);
                                switch (snapshot.connectionState) {
                                  case ConnectionState.done:
                                    if(snapshot == null || snapshot.data == null || !snapshot.hasData || snapshot.hasError){
                                      return CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: AssetImage('assets/${searchModel.gender.toLowerCase()}profile.png'),
                                      );
                                    }else{
                                      return CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: snapshot.data,
                                      );
                                    }
                                    break;
                                  default: return CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: AssetImage('assets/${searchModel.gender.toLowerCase()}profile.png'),
                                      );
                                      break;
                                }
                              }),
                      ),
                    )
                  
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.symmetric(horizontal:16),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top:10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            searchModel == null || searchModel.dept == null || searchModel.dept.replaceAll(' ', '') == ''?
                            SizedBox():
                            Row(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width -48-100,
                                  child: TextFormField(
                                    initialValue: '${searchModel.dept}',
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Department'
                                    ),
                                  ),
                                ),
                                SizedBox(width:16),
                                Container(
                                  width: 100,
                                  child: TextFormField(
                                    initialValue: '${searchModel.program}',
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Program'
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            searchModel == null || searchModel.room == null || searchModel.room.replaceAll(' ', '') == ''?
                            SizedBox():
                            SizedBox(height: 10.0,),
                            searchModel == null || searchModel.room == null || searchModel.room.replaceAll(' ', '') == ''?
                            SizedBox():
                            Row(
                              children: <Widget>[
                                Container(
                                  width: (MediaQuery.of(context).size.width - 32)*0.5,
                                  //   decoration: BoxDecoration(
                                  //   border: Border.all()
                                  // ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: (MediaQuery.of(context).size.width - 32)*0.5 - 20 - 50,
                                        child:TextFormField(
                                          readOnly: true,
                                          initialValue: '${searchModel.room}',
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText:  'Room',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8,),
                                      IconButton(
                                        icon: Icon(Icons.edit), 
                                        onPressed: (){
                                          _updateDialog('room');
                                        },
                                        tooltip: 'Update Room',
                                      ),
                                      SizedBox(width: 12),
                                    ]
                                  ),
                                ),
                                Container(
                                  width: (MediaQuery.of(context).size.width - 32)*0.5,
                                  child: Row(
                                    children: <Widget>[
                                      searchModel == null || searchModel.hall == null || searchModel.hall.replaceAll(' ', '') == ''?
                                        SizedBox():
                                        Container(
                                          width: (MediaQuery.of(context).size.width - 32)*0.5 - 20 - 50,
                                          child:TextFormField(
                                             readOnly: true,
                                            initialValue: '${searchModel.hall}',
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Hall'
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8,),
                                        IconButton(
                                          icon: Icon(Icons.edit), 
                                          onPressed: (){
                                            _updateDialog('hall');
                                          },
                                          tooltip: 'Update Hall',
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            searchModel == null || searchModel.hometown == null || searchModel.hometown.replaceAll(' ', '') == ''?
                              SizedBox():SizedBox(height: 10.0,),
                                searchModel == null || searchModel.hometown == null || searchModel.hometown.replaceAll(' ', '') == ''?
                                SizedBox():
                                TextFormField(
                                  initialValue: '${searchModel.hometown}',
                                   readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Hometown',
                                    border: OutlineInputBorder()
                                  ),
                                )
                                            // Text(
                                            //   'Hometown :  ${searchModel.hometown}',
                                            //   style: TextStyle(
                                            //       fontFamily: 'Comfortaa',
                                            //       fontWeight: FontWeight.bold,
                                            //       height: 1.4,
                                            //       fontSize: 17.0,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height:20),
                      por ==null || por.length == 0 ?
                      Container():
                      Center(
                        child: Text('POR\'s',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      por ==null || por.length == 0 ?
                      Container():
                      SizedBox(height: 10.0),
                      for (var i in por)
                          Chip(label: Text(i)),
                      SizedBox(height: 15.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Qr Code',
                              style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: QrImage(data:id + '@iitk.ac.in',
                        foregroundColor:Theme.of(context).brightness == Brightness.light ?
                        Colors.black:Colors.white,
                          size: 200.0,
                        ),
                      ),
                      SizedBox(height: 25.0),
                    ],
                  ),
                )
                
              ],
            ),
            
          ],
        ),
      ),
    );
  }
  
  _updateDialog(String type) {
    return showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) {
          final _formKey = GlobalKey<FormState>();
          String _type = type == 'hall'?hallName(searchModel.hall) : searchModel.room;
          // return Container(
          return StatefulBuilder(
            builder: (context, setStat) {
              return AlertDialog(
                elevation: 5.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                    title: Center(child: Text('Change $type')),
                content: Form(
                  key: _formKey,
                  child: Container(
                    // height: 300.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        // Container(
                        //   alignment: Alignment.center,
                        //   child: Text('Note: Add like thi',

                        //   textAlign: TextAlign.center,
                        //   style:TextStyle(
                        //     fontSize: 12.0,
                        //     color: Colors.red,
                        //     fontWeight: FontWeight.bold
                        //   )
                        // )),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                          child: Material(
                            color: Colors.transparent,
                            child: type == 'hall'?
                            DropdownButtonFormField(
                              items: hall.map((location) {
                                return DropdownMenuItem(
                                  child: new Text(hallName(location)),
                                  value: location,
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText: 'Hall',
                                hintText: 'Select Hall',
                                isDense: true
                              ),
                              onChanged: (newValue) =>setStat((){_type = hallName(newValue);}),
                                          // hint: Text('Choose Council'),
                              value: _type,
                              validator: (value) => value == null || value.isEmpty
                                ? 'This field is Required'
                                : null,
                              onSaved: (value) => _type = hallName(value),
                            )
                            : TextFormField(
                              toolbarOptions: ToolbarOptions(
                                copy: true,
                                paste: true,
                                selectAll: true,
                              ),
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              initialValue: '${searchModel.room}',
                              decoration: new InputDecoration(
                                labelText:'Room',
                                helperText: 'Room should be like A-508'
                              ),
                              validator: (value) => value.isEmpty?'This field is required'
                                  : null,
                              onSaved: (value) => _type = value,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only( top: 25.0,left: 0.0),
                          // height: 100.0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0)),
                                    // color: Colors.blue,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Dismiss')),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0),
                                  child: RaisedButton(
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(30.0)),
                                      color: Colors.blue,
                                      onPressed: () async{
                                        if (_formKey.currentState.validate()) {
                                          _formKey.currentState.save();
                                          showInfoToast('Updating ' + type =='hall'? 'Hall': 'Room');
                                          
                                              String prev;
                                          await changeStudentData({"roll": searchModel.rollno,'$type': _type}).then((status)async{
                                            if(status == true){
                                              if (type == 'hall') {
                                                // setState(() {
                                                  prev = searchModel.hall;
                                                  searchModel.hall = _type;
                                                // });
                                              } else {
                                                // setState(() {
                                                  prev = searchModel.room;
                                                  searchModel.room = _type;
                                                // });
                                              }
                                              await StuSearchDatabase().updatePosts(searchModel).then((v){
                                                if(v ==true){
                                                    setState(() {
                                                    });
                                                  showSuccessToast('Successfully Updated your' + type =='hall'? 'Hall': 'Room');
                                                }else{
                                                  showErrorToast( 'Updation Failed!!!');
                                                  if (type == 'hall') {
                                                    setState(() {
                                                      searchModel.hall = prev;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      searchModel.room = prev;
                                                    });
                                                  }
                                                }
                                              }).catchError((onError){
                                                print(onError);
                                                  if (type == 'hall') {
                                                    setState(() {
                                                      searchModel.hall = prev;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      searchModel.room = prev;
                                                    });
                                                  }
                                                showErrorToast( 'Updation Failed!!!');
                                              });
                                            }else{
                                              if (type == 'hall') {
                                                setState(() {
                                                  searchModel.hall = prev;
                                                });
                                              } else {
                                                setState(() {
                                                  searchModel.room = prev;
                                                });
                                              }
                                              showErrorToast( 'Updation Failed!!!');
                                            }
                                          }).catchError((onError){
                                            print(onError);
                                            if (type == 'hall') {
                                              setState(() {
                                                searchModel.hall = prev;
                                              });
                                            } else {
                                              setState(() {
                                                searchModel.room = prev;
                                              });
                                            }
                                            showErrorToast( 'Updation Failed!!!');
                                          });
                                          Navigator.of(context).pop();
                                          // confirmPage();
                                        }
                                      },
                                      child: Text(
                                        type == 'hall'
                                            ? (searchModel.hall == null || searchModel.hall == ''
                                                ? 'Add Hall'
                                                : 'Update Hall')
                                            : (searchModel.room== null || searchModel.room == ''
                                                ? 'Add Room'
                                                : 'Update Room'),
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                              ]),
                        )
                        // )
                      ],
                      // )
                    ),
                  ),
                ),
              );
            }
          );
        });
  }
}

hallName(String hall){
  if(hall.toLowerCase() == 'hall'){
    return 'Hall';
  }
  if(hall.toLowerCase().contains('hall')){
    hall = hall.replaceAll(' ', '');
    // print(hall);
    switch(hall.toLowerCase()){
      case 'hallx':  return 'Hall 10';
      break;
      case 'hallxi': return 'Hall 11';
      break;
      default: return hall[0].toUpperCase() + hall.substring(1,4).toLowerCase()+ ' ' + hall.substring(4);
    }
  }else{
    return hall.toUpperCase();
  }
}