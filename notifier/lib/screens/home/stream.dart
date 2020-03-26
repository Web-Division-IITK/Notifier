import 'package:flutter/material.dart';
import 'package:notifier/main.dart';
import 'package:notifier/models/user.dart';
import 'package:notifier/screens/wrapper.dart';
import 'package:notifier/services/auth.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/shared/function.dart';
import 'package:provider/provider.dart';
import 'package:notifier/screens/home/home.dart';

class AddContentData extends StatefulWidget {
  @override
  _AddContentDataState createState() => _AddContentDataState();
}

class _AddContentDataState extends State<AddContentData> {
  final AuthService _auth = AuthService();
  Widget wid;
  // var stream;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          UserData userData = snapshot.data;
          print('sn' + snapshot.data.toString());
          // // for i in user
          if (userData == null) {
            return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(
                    color: darkThemeEnabled ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    'Make Admin',
                    style: TextStyle(
                        color: darkThemeEnabled ? Colors.white : Colors.black),
                  ),
                  backgroundColor:
                      darkThemeEnabled ? Colors.black : Colors.white,
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
                body: Center(child: CircularProgressIndicator()));
          } else {
            // print('gon');
            jsonContent = {
              'id': userData.id,
              'name': userData.name,
              'email': userData.email,
              'prefs': userData.prefs,
              'rollno': userData.rollno,
              'admin': userData.admin,
              'uid': userData.uid,
            };
            // print(userData.id);
            // print(jsonContent);
            // setState(() {
              // setState(() {
                load = false;
              // });
            writeContent('users',jsonContent);
            
            return  Home(user);
          }
          // return wid;
        });
  }
}

// class DownloadPeople extends StatefulWidget {
//   @override
//   _DownloadPeopleState createState() => _DownloadPeopleState();
// }
// Map<String,dynamic> peopleList ;
// class _DownloadPeopleState extends State<DownloadPeople> {
//   final AuthService _auth = AuthService();
//   Widget wid;
//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<User>(context);
//     return StreamBuilder<UserData>(
//         stream: DatabaseService(uid: user.uid).userData,
//         builder: (context, snapshot) {
//           UserData userData = snapshot.data;
//           // print('sn' + snapshot.data.toString());
//           // // for i in user
//           if (userData == null) {
//             wid = Scaffold(
//                 appBar: AppBar(
//                   iconTheme: IconThemeData(
//                     color: darkThemeEnabled ? Colors.white : Colors.black,
//                   ),
//                   title: Text(
//                     'Make Admin',
//                     style: TextStyle(
//                         color: darkThemeEnabled ? Colors.white : Colors.black),
//                   ),
//                   backgroundColor:
//                       darkThemeEnabled ? Colors.black : Colors.white,
//                   // elevation: 0.0,
//                   actions: <Widget>[
//                     FlatButton.icon(
//                       icon: Icon(
//                         Icons.person,
//                         color: Colors.black,
//                       ),
//                       label: Text(
//                         'Logout',
//                         style: TextStyle(
//                           color: Colors.black,
//                         ),
//                       ),
//                       onPressed: () async {
//                         await _auth.signOut();
//                       },
//                     )
//                   ],
//                 ),
//                 body: Center(child: CircularProgressIndicator()));
//           } else {
//             // print('gon');
//             jsonContent = {
//               'id': userData.id,
//               'name': userData.name,
//               'email': userData.email,
//               'prefs': userData.prefs,
//               'rollno': userData.rollno,
//               'admin': userData.admin,
//               'uid': userData.uid,
//             };
//             // print(userData.id);
//             // print(jsonContent);
//             // setState(() {
//             writeContent();
//             load = false;
//             // wid = Home(user);
//           }
//           return wid;
//         });
//   }
//   }
// }
