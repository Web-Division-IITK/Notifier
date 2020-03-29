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
        
        primaryColor: brightness == Brightness.dark ? Colors.deepPurple: Colors.amber,
        buttonColor:brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
          splashColor: Colors.orange,
          // toggleButtonsTheme: ,
          appBarTheme: AppBarTheme(
            
          ),
          toggleableActiveColor: brightness == Brightness.dark ? Colors.teal:Colors.green,
          cupertinoOverrideTheme: CupertinoThemeData(
            brightness: brightness,
            
          ),
          dialogBackgroundColor: brightness == Brightness.dark ? Colors.black:Colors.white,
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