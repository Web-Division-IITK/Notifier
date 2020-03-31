import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  }
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
            iconTheme: IconThemeData(
              color: Colors.white
            ),
            textTheme: TextTheme(
              title: TextStyle(
                fontSize: 20.0,
                color: Colors.white
              )
            )
          ),
          toggleableActiveColor: brightness == Brightness.dark ? Colors.teal:Colors.green,
          dialogTheme: brightness == Brightness.dark?DialogTheme(backgroundColor: Colors.black):DialogTheme(backgroundColor: Colors.white),
          cupertinoOverrideTheme: CupertinoThemeData(
            brightness: brightness,
            primaryContrastingColor: brightness == Brightness.dark ? Colors.deepPurple: Colors.amber,
            scaffoldBackgroundColor: brightness == Brightness.dark ? Colors.black:Colors.white,
            // primaryColor:  brightness == Brightness.dark ? Colors.deepPurple: Colors.amber,
            barBackgroundColor: brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
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