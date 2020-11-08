import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/authentication/loginsignuppage.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'database/hive_database.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
  ERROR,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  @override
  void initState() {
    super.initState();
    initalizeFirebaseApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
        if(snapshot == null || snapshot.data == null){
          setState(() {
            authStatus = AuthStatus.NOT_DETERMINED;
          });
        }else{
          authStatus = AuthStatus.LOGGED_IN;
        }
      },
      
    );
  }

  Future initalizeFirebaseApp() async{
    try {
      final initialize = await Firebase.apps ;
      if(initialize != null){

      }
    } catch (e) {
    }
  }
}