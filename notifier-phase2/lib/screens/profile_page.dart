import 'dart:convert';

import 'package:async/async.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notifier/constants.dart';
import 'package:http/http.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/database/student_search.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/profile/profilepic.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/widget/showtoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SharedPreferences _profilePicName;
  String picName;
  List<String> por = [];
  bool showMoreInfo = false;
  bool _refreshLoading = false;
  SearchModel searchModel = SearchModel(
    bloodGroup: '',dept: '',gender: 'M',hall: '',hometown: '',name: '',program: '',rollno: '', room: '',username: id,year: 'Others'
  );
  final List<String> hall = List.generate(13, (index)=>'Hall ${index+1}',growable: true);
  Future<bool> loadProfilePage() async {
    try{
      userBox = await HiveDatabaseUser().hiveBox;
      _profilePicName = await SharedPreferences.getInstance();
      picName = '${userBox.toMap()[0].rollno}.jpg';
      picName = _profilePicName.getString(PICNAME);
      if(picName != null && !picName.contains(userBox.toMap()[0].rollno)){
        picName = null;
      }
      if(userBox.isNotEmpty){
        List<SearchModel> list= await StuSearchDatabase().getAllPostswithQuery(QueryDatabase(['username'], [id]));
        print(list.length);
        List<SearchModel> val = list.where((test)=>test.username == id).toList();
        print(val);
        if(val==null || val.length==0){
          val = [SearchModel(bloodGroup: '',dept: '',gender: 'M',hall: '',hometown: '',name: '',program: '',rollno: '', room: '',username: '$id',year: 'Others')];
        }
        _jsonData = val[0].toMap();
          setState(() {
            searchModel = val[0];
            name = val[0].name;
            print(val[0].toMap());
            rollno = val[0].rollno;
            print(val[0].rollno);
          });
          return true;
      }    
      return false;
    }catch(e){
      print('ERROR WHILE IN FUNCTION loadProfilePage() .....');
      print(e);
      return false;
    }
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
    loadProfilePage().then((bool v) {
      if (v != null) {
        setState(() {
          _load = false;
        });
      } else{

      }
    });
  }
  Future<bool>changeStudentData(Map<String,dynamic> map) async{
    try {
      // Map<String, String> headers = {"Content-type": "application/json"};
      // final String url = 'http://ec2-18-204-20-179.compute-1.amazonaws.com/updateStudent';
      print('RUNNING FUNCTION changeStudentData .....');
      Response res = await post(UPDATE_STUDENT_SEARCH_DATA_API,headers: HEADERS,body: jsonEncode(map));
      print('RESPONSE STATUSCODE - ' + res.statusCode.toString());
      print('RESPONSE BODY: ' + res.body);
      if(res.statusCode == 200){
        return true;
      }
      return false;
    } catch (e) {
      print('ERROR WHILE UPDATING STUDENT DATA');
      print(e);
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    // print(double.maxFinite);
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
                                            Row(
                                              children: [
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
                                                SizedBox(width: 5,),
                                                Tooltip(
                                                  message: 'Update Department',
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor: Colors.transparent,
                                                    child: InkWell  (
                                                      onTap: (){
                                                      _updateDialog(UpdateProfile.DEPT).then((value) => setState((){}));
                                                    },
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Theme.of(context).iconTheme.color,
                                                        size: 20,
                                                      ))),
                                                  
                                                )
                                              ],
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
                                                        _updateDialog(UpdateProfile.ROOM).then((value) => setState((){}));
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
                                                      _updateDialog(UpdateProfile.HALL).then((value) => setState((){}));
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
                          future: file(picName?? "${searchModel.rollno}.jpg"),
                          builder: (context, snapshot){
                            switch(snapshot.connectionState){
                              case ConnectionState.done:
                                if(snapshot == null || snapshot.data == null || !snapshot.hasData || snapshot.hasError){
                                  return CircleAvatar(
                                    radius: 50.0,
                                    backgroundImage: AssetImage(defaultProfileUrl(searchModel.gender)),
                                  );
                                }else{
                                  if(snapshot.data.existsSync()){  
                                    return CircleAvatar(
                                      radius: 50.0,
                                      backgroundImage: MemoryImage(
                                        snapshot.data.readAsBytesSync()
                                      ),
                                    );
                                  }else{
                                    return CircleAvatar(
                                      radius: 50.0,
                                      backgroundImage: AssetImage(defaultProfileUrl(searchModel.gender)),
                                    );
                                  }
                                }
                              break;
                              default: return CircleAvatar(
                                radius: 50.0,
                                backgroundImage: AssetImage(defaultProfileUrl(searchModel.gender)),
                              );
                              break;
                            }
                          }
                        ),
                        // FutureBuilder(
                        //         future: UserProfilePic(searchModel).getUserProfilePic(),
                        //         builder: (context, snapshot){
                        //           print(searchModel.gender);
                        //         switch (snapshot.connectionState) {
                        //           case ConnectionState.done:
                        //             if(snapshot == null || snapshot.data == null || !snapshot.hasData || snapshot.hasError){
                        //               return CircleAvatar(
                        //                 radius: 50.0,
                        //                 backgroundImage: AssetImage('assets/${searchModel.gender.toLowerCase()}profile.png'),
                        //               );
                        //             }else{
                        //               return CircleAvatar(
                        //                 radius: 50.0,
                        //                 backgroundImage: snapshot.data,
                        //               );
                        //             }
                        //             break;
                        //           default: return CircleAvatar(
                        //                 radius: 50.0,
                        //                 backgroundImage: AssetImage('assets/${searchModel.gender.toLowerCase()}profile.png'),
                        //               );
                        //               break;
                        //         }
                        //       }),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: MediaQuery.of(context).size.width *0.5 + 25,
                      child: AbsorbPointer(
                        absorbing: 
                        // false,
                        _refreshLoading,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white,
                            elevation: 5,
                            child: Tooltip(
                              message: 'Re-fetch profile picture',
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashColor: Colors.transparent,
                                onTap: ()async{
                                  setState(() {
                                    _refreshLoading = !_refreshLoading;
                                  });
                                  await UserProfilePic(searchModel).getDirectoryProfilePic().then((value){
                                    if(mounted)
                                      setState(() {
                                        _refreshLoading = false;
                                      });
                                    if(value == false)
                                      showErrorToast('Can\'t fetch at the moment !!! Please try again later or try after connecting to IITK Network');
                                  });
                                },
                                child: _refreshLoading ?
                                  Center(
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      padding: EdgeInsets.all(6),
                                      child: CircularProgressIndicator(
                                        backgroundColor: /*Theme.of(context).brightness == Brightness.dark ? Colors.white : */Colors.black,
                                        strokeWidth: 2.2),
                                    )
                                  )
                                : Icon(
                                  Icons.refresh,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                                  width: MediaQuery.of(context).size.width
                                   * 0.6,
                                  // -48-200, //100
                                  child: TextFormField(
                                    initialValue: '${searchModel.dept}',
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Department'
                                    ),
                                  ),
                                ),
                                // SizedBox(width: 8,),
                                // IconButton(
                                //   icon: Icon(Icons.edit), 
                                //   onPressed: (){
                                //     _updateDialog(UpdateProfile.DEPT);
                                //   },
                                //   tooltip: 'Update Department',
                                // ),
                                SizedBox(width:12),
                                Container(
                                  width: 
                                  MediaQuery.of(context).size.width * 0.4 -46,
                                  // 100 - 20.0,
                                  child: TextFormField(
                                    initialValue: '${searchModel.program}',
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Program'
                                    ),
                                  ),
                                ),
                                // SizedBox(width: 8,),
                                // IconButton(
                                //   icon: Icon(Icons.edit), 
                                //   onPressed: (){
                                //     _updateDialog(UpdateProfile.PROGRM);
                                //   },
                                //   tooltip: 'Update Program',
                                // ),
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
                                          _updateDialog(UpdateProfile.ROOM).then((value) => setState((){}));
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
                                            _updateDialog(UpdateProfile.HALL).then((value) => setState((){}));
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
  
  Future _updateDialog(UpdateProfile type) {
    return showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) {
          final _formKey = GlobalKey<FormState>();
          String _typeValue = ((){
            switch(type){
              case UpdateProfile.DEPT : return UPDATE_PROFILE_DEPT;
              case UpdateProfile.HALL : return UPDATE_PROFILE_HALL;
              case UpdateProfile.PROGRM :return UPDATE_PROFILE_PROGRM;
              case UpdateProfile.ROOM : return UPDATE_PROFILE_ROOM;
              default : return '';
            }
          }());
          String _value = ((){
            switch(type){
              case UpdateProfile.DEPT : return searchModel.dept;
              case UpdateProfile.HALL : return hallName(searchModel.hall);
              case UpdateProfile.PROGRM :return searchModel.program;
              case UpdateProfile.ROOM : return searchModel.room;
              default: return '';
            }
          }());
          bool _loading = false;
          // type == 'hall'?hallName(searchModel.hall) : searchModel.room;
          return StatefulBuilder(
            builder: (context, setStat) {
              return AlertDialog(
                elevation: 5.0,
                contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                    title: Center(
                      child: Text(
                        'Update ' + _typeValue
                      )
                  ),
                content: Form(
                  key: _formKey,
                  child: Container(
                    // height: 200,
                    width: MediaQuery.of(context).size.width * 0.5,
                    // constraints: BoxConstraints(
                    //   maxWidth: MediaQuery.of(context).size.width * 0.65,
                    //   minWidth: MediaQuery.of(context).size.width * 0.45,
                    // ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                            // width: 150,
                            child: type == UpdateProfile.HALL || type == UpdateProfile.PROGRM?
                              DropdownButtonFormField(
                                items: ((){
                                  if(type == UpdateProfile.HALL)
                                    return hall;
                                  return program;}()).map((location) {
                                return DropdownMenuItem(
                                  child: new Text(
                                    type == UpdateProfile.HALL?hallName(location): location),
                                  value: location,
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText: 'Hall',
                                hintText: 'Select Hall',
                                isDense: true
                              ),
                              onChanged: (newValue) =>setStat((){
                                type == UpdateProfile.HALL?
                                _value = hallName(newValue)
                                : _value = newValue;}),
                                          // hint: Text('Choose Council'),
                              value: _value,
                              validator: (value) => value == null || value.isEmpty
                                ? 'The field is required to update record'
                                : null,
                              onSaved: (value) => _value = type == UpdateProfile.HALL? hallName(value): value,
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
                              initialValue: type == UpdateProfile.ROOM ? '${searchModel.room}' : searchModel.dept,
                              decoration: new InputDecoration(
                                labelText: type == UpdateProfile.ROOM ? 'Room' : 'Department',
                                helperText: type == UpdateProfile.ROOM ? 'Room should be like A-508' : 'Your department'
                              ),
                              validator: (value) => value.isEmpty?'The field is required to update record'
                                  : null,
                              onSaved: (value) => _value = value,
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
                                    child: Container(
                                      // constraints: BoxConstraints(
                                      //   maxWidth: 85
                                      //   //  MediaQuery.of(context).size.width - 30 - 109
                                      // ),
                                      width: 50,
                                      child: AutoSizeText('Dismiss'))),
                                SizedBox(width: 7),
                                Padding(
                                  padding: const EdgeInsets.only(left:0,right: 0.0),
                                  child: RaisedButton(
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(30.0)),
                                      color: Colors.blue,
                                      onPressed: () async{
                                        if (_formKey.currentState.validate()) {
                                          _formKey.currentState.save();
                                          setStat(() {
                                            _loading = true;
                                          });
                                          showInfoToast('Updating ' + _typeValue);
                                          String prev;
                                          switch(type){
                                            case UpdateProfile.DEPT : prev = searchModel.dept;
                                            break;
                                            case UpdateProfile.HALL : prev = searchModel.hall;
                                            break;
                                            case UpdateProfile.PROGRM : prev = searchModel.program;
                                            break;
                                            case UpdateProfile.ROOM : prev = searchModel.room;
                                            break;
                                                }
                                          try{
                                            await changeStudentData({_typeValue.toLowerCase(): _value,"auth": auth}).then((status)async{
                                              if(status == true){
                                                switch(type){
                                                  case UpdateProfile.DEPT : {
                                                    prev = searchModel.dept;
                                                    searchModel.dept = _value;
                                                  } break;
                                                  case UpdateProfile.HALL : {
                                                    prev = searchModel.hall;
                                                    searchModel.hall = _value;
                                                  } break;
                                                  case UpdateProfile.PROGRM :{
                                                    prev = searchModel.program;
                                                    searchModel.program = _value;
                                                  } break;
                                                  case UpdateProfile.ROOM : {
                                                    prev = searchModel.room;
                                                    searchModel.room = _value;
                                                  } break;
                                                }
                                                await StuSearchDatabase().updatePosts(searchModel).then((v){
                                                  if(v ==true){
                                                    setStat(() {
                                                      _loading = false;
                                                    });
                                                    showSuccessToast('Successfully Updated your' + _typeValue);
                                                  }else{
                                                    showErrorToast( 'Updation Failed!!!');
                                                    //  setStat(() {
                                                      _loading = false;
                                                    // });
                                                    switch(type){
                                                      case UpdateProfile.DEPT : setState((){searchModel.dept = prev;});
                                                      break;
                                                      case UpdateProfile.HALL : setState((){searchModel.hall = prev;});
                                                      break;
                                                      case UpdateProfile.PROGRM : setState((){searchModel.program = prev;});
                                                      break;
                                                      case UpdateProfile.ROOM : setState((){searchModel.room = prev;});
                                                      break;
                                                    }
                                                  // if (type == 'hall') {
                                                  //   setState(() {
                                                  //     searchModel.hall = prev;
                                                  //   });
                                                  // } else {
                                                  //   setState(() {
                                                  //     searchModel.room = prev;
                                                  //   });
                                                  // }
                                                  }
                                                }).catchError((onError){
                                                print(onError);
                                                //  setStat(() {
                                                      _loading = false;
                                                // });
                                                switch(type){
                                                    case UpdateProfile.DEPT : setState((){searchModel.dept = prev;});
                                                    break;
                                                    case UpdateProfile.HALL : setState((){searchModel.hall = prev;});
                                                    break;
                                                    case UpdateProfile.PROGRM : setState((){searchModel.program = prev;});
                                                    break;
                                                    case UpdateProfile.ROOM : setState((){searchModel.room = prev;});
                                                    break;
                                                }
                                                showErrorToast( 'Updation Failed!!!');
                                              });
                                              }else{
                                                // setStat(() {
                                                  _loading = false;
                                                // });
                                                switch(type){
                                                  case UpdateProfile.DEPT : setState((){searchModel.dept = prev;});
                                                  break;
                                                  case UpdateProfile.HALL : setState((){searchModel.hall = prev;});
                                                  break;
                                                  case UpdateProfile.PROGRM : setState((){searchModel.program = prev;});
                                                  break;
                                                  case UpdateProfile.ROOM : setState((){searchModel.room = prev;});
                                                  break;
                                                }
                                                showErrorToast( 'Updation Failed!!!');
                                              }
                                            });
                                          }catch(onError){
                                              print(onError);
                                              //  setStat(() {
                                                      _loading = false;
                                                    // });
                                              switch(type){
                                                case UpdateProfile.DEPT : setState((){searchModel.dept = prev;});
                                                break;
                                                case UpdateProfile.HALL : setState((){searchModel.hall = prev;});
                                                break;
                                                case UpdateProfile.PROGRM : setState((){searchModel.program = prev;});
                                                break;
                                                case UpdateProfile.ROOM : setState((){searchModel.room = prev;});
                                                break;
                                              }
                                              // if (type == 'hall') {
                                              //   setState(() {
                                              //     searchModel.hall = prev;
                                              //   });
                                              // } else {
                                              //   setState(() {
                                              //     searchModel.room = prev;
                                              //   });
                                              // }
                                              showErrorToast( 'Updation Failed!!!');
                                          }
                                          if(mounted) Navigator.of(context).pop();
                                        }
                                      },
                                      child: Container(
                                        // width: ,
                                        // width: MediaQuery.of(context).size.width *0.8 - 30 - 57 - 88,
                                        // constraints: BoxConstraints(
                                        //   maxWidth: MediaQuery.of(context).size.width *0.8 - 40 - 57-88,
                                        // MediaQuery.of(context).size.width - 180
                                        // ), //30 + 85 + 7
                                        child: _loading ?
                                          Center(
                                            child: Container(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(backgroundColor: Colors.white,strokeWidth: 2,)),
                                          )
                                        : AutoSizeText('Update ' + _typeValue,
                                          maxLines: 1,
                                          minFontSize: 2,
                                          maxFontSize: 15,
                                          style: TextStyle(color: Colors.white),
                                        ),
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