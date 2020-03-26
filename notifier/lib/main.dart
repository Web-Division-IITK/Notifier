import 'package:flutter/material.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/authentication/loginsignuppage.dart';
import 'package:notifier/authentication/rootpage.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:  RootPage(auth: new Auth()));
  }
}