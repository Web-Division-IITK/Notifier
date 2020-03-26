import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notifier/main.dart';
import 'package:notifier/models/user.dart';
import 'package:notifier/screens/home/type1.dart';
import 'package:notifier/services/auth.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/shared/customDrawer.dart';
import 'package:notifier/shared/function.dart';
import 'dart:async';

import 'package:notifier/shared/loading.dart';

class Home extends StatefulWidget {
  // final Function toggleTheme;
  final User user;
  Home(this.user);

  @override
  _HomeState createState() => _HomeState();
}

Map<String, dynamic> jsonContent;

class _HomeState extends State<Home> {
  final Storage storage = Storage();
  String id;
  bool admin = null;
  final AuthService _auth = AuthService();
  bool called = false;
  @override
  void initState() {
    super.initState();
    // print(getData().toString() + 'arr');
    // print(arr.toString());
    readContent('users').then((Map<String, dynamic> value) {
      setState(() {
        // print(value.toString());
        id = value['id'].toString();
        admin = value['admin'];
        // print(admin);
      });
    });
    // print(count);
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you really want to exit?'),
            // content: new Text('Do you really want to exit'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text(
                  'Yes',
                  style: TextStyle(color: Colors.lightGreenAccent[400]),
                ),
              ),
              new FlatButton(
                color: Colors.amber[900],
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  'No',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<User>(context);
    // ((id == 'adtgupta' || id == 'utkarshg') && selectionDataPeople.length == 0) ? getData() : print(selectionDataPeople);
    return admin == null
        ? Loading()
        : WillPopScope(
            onWillPop: _onWillPop,
            child: id == 'utkarshg' || id == 'adtgupta'
                ? MakeAdmin(id)
                : Scaffold(
                    appBar: AppBar(
                      iconTheme: IconThemeData(
                        color: darkThemeEnabled ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        'Selection',
                        style: TextStyle(
                            color:
                                darkThemeEnabled ? Colors.white : Colors.black),
                      ),
                      backgroundColor:
                          darkThemeEnabled ? Colors.black : Colors.white,
                      elevation: 0.0,
                      actions: <Widget>[
                        FlatButton.icon(
                          icon: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          label: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () async {
                            await _auth.signOut();
                          },
                        )
                      ],
                    ),
                    drawer: CustomDrawer(),
                    body: Center(child: Text('You are not an admin'))));
  }
}

class MakeAdmin extends StatelessWidget {
  final id;
  final AuthService _auth = AuthService();
  MakeAdmin(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: darkThemeEnabled ? Colors.white : Colors.black,
        ),
        title: Text(
          'Make Admin',
          style:
              TextStyle(color: darkThemeEnabled ? Colors.white : Colors.black),
        ),
        backgroundColor: darkThemeEnabled ? Colors.black : Colors.white,
        // elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.person,
              color: Colors.black,
            ),
            label: Text(
              'Logout',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ],
      ),
      drawer: CustomDrawer(),
      body: Container(
          // padding: EdgeInsets.only(top: 170.0),
          color: darkThemeEnabled ? Colors.black : Colors.white,
          child: Type1(id)
          ),
    );
  }
}

// String loadData(){
//     StreamBuilder<UserData>(
//       stream: DatabaseService(uid: user.uid).userData,
//       builder: (context, snapshot) {
//         if(snapshot != null){
//           print(admin);
//         UserData userData = snapshot.data;
//         print(userData.id);
//         userData == null ? Center(child: CircularProgressIndicator(backgroundColor:Colors.white)) : admin = userData.admin;
//         admin = user.admin;
//         return null;
//         }
//         else {
//           return Center(child: CircularProgressIndicator(backgroundColor:Colors.black));
//         }
//       });
//   }

//   load() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   setState(() {
//     // id = (prefs.getString('counter') ?? 0) + 1;
//     prefs.setString('id',user.id ?? loadData());
//     prefs.setString('admin',user.admin ?? loadData());
//   });
// }
//   _getCounter() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   setState(() {
//     id = (prefs.getString('id') ?? load());
//     admin = (prefs.getBool('admin') ?? load());
//   });
// }

// @override
// void initState() {
//   super.initState();
//   void localstorage(){
// if(called){

//     StreamBuilder<UserData>(
//       stream: DatabaseService(uid: widget.user.uid).userData,
//       builder: (context, snapshot) {
//         if(snapshot != null){
//           // print(admin);
//         UserData userData = snapshot.data;
//         // return snapshot.doc;
//         // print(userData.id);
//         // // for i in user
//         jsonContent = [
//           Profile('id',userData.id),
//           Profile('name',userData.name),
//           Profile('email',userData.email),
//           Profile('prefs',userData.prefs),
//           Profile('rollno',userData.rollno),
//           Profile('admin',userData.admin),
//           Profile('uid',userData.uid),
//         ];
//         return null;
//         // );
//         // return jsonContent;
//         // }
//         // else {
//         //   return Center(child: CircularProgressIndicator(backgroundColor:Colors.black));
//         }}
//       );
// }
//  called = false;
// }
// localPath();

// getApplicationDocumentsDirectory().then((Directory directory){

//   dir = directory;
//   jsonFile = new File(dir.path + "/" + filename);
//   fileExists = jsonFile.existsSync();
//   if(fileExists) this.setState(() {
//     print('fileexists');
//     fileContent = json.decode(jsonFile.readAsStringSync());
//     if(fileContent['id']==null){
//       called= true;
//       localstorage();
//     }
//   } );
//   else{
//     if (jsonContent.length == 0){
//       called = true;
//       localstorage();
//     }
//     for (var i in jsonContent){
//       writeToFile(i.key, i.value);
//     }
//   }
// });
// }

// void createFile(Map<String,dynamic>content){
//   File file = new File(dir.path + "/" + filename);
//   file.createSync();
//   fileExists = true;
//   file.writeAsStringSync(json.encode(content));
//   // return file;
// }
// void writeToFile(String key,dynamic value){
//   Map<String,dynamic> content = {key:value};
//   if(fileExists){
//     print('file exists');
//     admin = true;
//   Map<String,dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
//   jsonFileContent.addAll(content);
//   jsonFile.writeAsStringSync(json.encode(jsonFileContent));
//   }
//   else{
//     print('filedoesn\'t exists');
//     createFile(content);
//   }

// }
// String id = 0;

// File jsonFile;
//   Directory dir;
//   String filename = 'data.json';
//   bool fileExists = false;
//   Map<String, dynamic> fileContent;
//   bool admin = false;
//   bool called = false;

//   Future<bool> _onWillPop() {
//     return showDialog(
//           context: context,
//           builder: (context) => new AlertDialog(
//             title: new Text('Are you really want to exit?'),
//             // content: new Text('Do you really want to exit'),
//             actions: <Widget>[
//               new FlatButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: new Text(
//                   'Yes',
//                   style: TextStyle(color: Colors.lightGreenAccent[400]),
//                 ),
//               ),
//               new FlatButton(
//                 color: Colors.amber[900],
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: new Text(
//                   'No',
//                   style: TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     void localstorage(){
//       if(called){

//           StreamBuilder<UserData>(
//             stream: DatabaseService(uid: widget.user.uid).userData,
//             builder: (context, snapshot) {
//               if(snapshot != null){
//                 // print(admin);
//               UserData userData = snapshot.data;
//               // return snapshot.doc;
//               // print(userData.id);
//               // // for i in user
//               jsonContent = [
//                 Profile('id',userData.id),
//                 Profile('name',userData.name),
//                 Profile('email',userData.email),
//                 Profile('prefs',userData.prefs),
//                 Profile('rollno',userData.rollno),
//                 Profile('admin',userData.admin),
//                 Profile('uid',userData.uid),
//               ];
//               return null;
//               // );
//               // return jsonContent;
//               // }
//               // else {
//               //   return Center(child: CircularProgressIndicator(backgroundColor:Colors.black));
//               }}
//             );
//       }
//       called = false;
//       }
//     storage.existence.then((bool fileExists){
//       if(fileExists) this.setState((){
//         print('fileexists');
//         storage.readData().then((Map<String,dynamic> content){
//           setState(() {
//             fileContent = content;// remember to deal the case when it is null
//             if(fileContent != null && fileContent['id'] != null){
//               called = true;
//               localstorage();
//             }
//           });
//         });
//       });
//       else{
//         if (jsonContent.length == 0){
//           called = true;
//           localstorage();
//         }
//         for (var i in jsonContent){
//           storage.writeData(i.key, i.value);
//         }
//       }
//     });
//   }
