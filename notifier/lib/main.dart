import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/authentication/rootpage.dart';

void main(){
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;
  @override
 
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
        fontFamily: 'Raleway',
        primaryColor: brightness == Brightness.dark ? Colors.orange: Colors.amber,
        buttonColor: Colors.deepOrange,
          splashColor: Colors.orange,
        // accentColor: MyColors.accent,
        brightness: brightness, // default is dark
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home:  RootPage(auth: new Auth(),darkMode: darkMode,)
        );
      },
    );
  }
}
// MaterialApp(
      // debugShowCheckedModeBanner: false,
      // // darkTheme: ,
      //   theme: new ThemeData(
      //     brightness: darkMode?Brightness.dark:Brightness.light,
      //     buttonColor: Colors.deepOrange,
      //     splashColor: Colors.orange,
      //     cupertinoOverrideTheme: CupertinoThemeData(

      //     ),
      //     fontFamily: 'Raleway',
      //     primarySwatch: Colors.amber,
      //   ),
      //   home:  RootPage(auth: new Auth(),darkMode: darkMode,));