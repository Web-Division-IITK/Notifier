import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notifier/screens/wrapper.dart';
import 'package:notifier/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:notifier/models/user.dart';
// import 'package:splashscreen/splashscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
// bool darkTheme = false;

//   void toggleTheme(){
//     darkTheme = !darkTheme;
//   }
bool darkThemeEnabled;
class _MyAppState extends State<MyApp> {

  
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
          child: StreamBuilder(
      stream: bloc.darkThemeEnabled,
      initialData: false,
      builder: (context, snapshot) {
        darkThemeEnabled = snapshot.data;
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            // theme: snapshot.data ? ThemeData.light() : ThemeData.dark(),
            theme: ThemeData(
              brightness: snapshot.data ? Brightness.dark :Brightness.light,
              // primarySwatch: !snapshot.data ?   Colors.white :,
            ),
       home: Wrapper(),
       

      );
      },
      
          ),
    );
  }
}

class Bloc {
  final _themeController = StreamController<bool>();
  get changeTheme => _themeController.sink.add;
  get darkThemeEnabled => _themeController.stream;
}

final bloc = Bloc();
/*
class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 14,
      navigateAfterSeconds: new Wrapper(),
      // title: new Text('Welcome In SplashScreen',
      //   style: new TextStyle(
      //     fontWeight: FontWeight.bold,
      //     fontSize: 20.0
      //   ),
      // ),
      image: new Image.network('package:notifier/android/app/src/drawable/draw.png'),
      // backgroundGradient: new LinearGradient(colors: [Colors.cyan, Colors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 200.0,
      loadingText: Text("-Developed by Aditya Gupta"),
      onClick: ()=>print("Flutter Egypt"),
      loaderColor: Colors.red,
    );
  }
}
*/
// class AfterSplash extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: new AppBar(
//         title: new Text("Welcome In SplashScreen Package"),
//         automaticallyImplyLeading: false,
//         ),
//       body: new Center(
//         child: new Text("Succeeded!",
//         style: new TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 30.0
//         ),),

//       ),
//     );
//   }
// }