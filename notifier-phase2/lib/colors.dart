import 'package:flutter/material.dart';

class CustomColors {
  final BuildContext context;
  CustomColors(this.context): assert(context != null);

  /// returns whethere the current theme is dark or not
  bool get isDarkTheme => Theme.of(context).brightness == Brightness.dark;
  /// for * Light theme: `black` * Dark theme: `white`
  Color get textColor => isDarkTheme ? Colors.white : Colors.black;
  /// for * Light theme: `black` * Dark theme: `white`
  Color get noteColor => isDarkTheme ? Color.fromARGB(255, 232, 232, 232) : Colors.black54;
  /// for * Light theme: `black` * Dark theme: `white`
  Color get iconColor => isDarkTheme ? Colors.white : Colors.black;
  /// for * Light theme: `black` * Dark theme: `white`
  Color get bgColor => isDarkTheme ? Colors.black : Colors.white;
  /// for * Light theme: `deepPurpleAccent` * Dark theme: `blueAccent`
  Color get accentColor => isDarkTheme ? Colors.deepPurpleAccent:Colors.blueAccent;
  /// for * Light theme: `black54` * Dark theme: `a greyish shade of white`
  Color get exapndedTileColor => isDarkTheme ? Colors.black54 : Color.fromARGB(255,247, 247, 245);
  /// for * Light theme: `deepPurple` * Dark theme: `amber`
  Color get primaryColor => isDarkTheme ? Colors.deepPurple: Colors.amber;
  /// for * Light theme: `pink` * Dark theme: `deepOrange`
  Color get buttonColor => isDarkTheme ? Colors.pink: Colors.deepOrange;
  /// for * Light theme: `deepPurpleAccent[700]` * Dark theme: `blueAccent[700]`
  Color get splashColor => isDarkTheme ? Colors.deepPurpleAccent[700] : Colors.blueAccent[700];
  /// for * Light theme: `deepPurpleAccent` * Dark theme: `blueAccent`
  /// 
  /// `NOTE: ` This is same as accentColor
  Color get textSelectionColor => isDarkTheme ?Colors.deepPurpleAccent:Colors.blueAccent;
  /// for * Light theme: `teal` * Dark theme: `green`
  Color get switchToggleColor => isDarkTheme ? Colors.teal:Colors.green;
}