import 'dart:convert';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flnp = FlutterLocalNotificationsPlugin();
  String display;
  String bodyMsg;
  String data;
  bool darkMode = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
    // _fcm.setAutoInitEnabled(true);
    
    // _fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage :$message" + ' isthe message');
    //      showNotification(message['data']);
    //     setState(() {
    //       // addStringToSF(DateTime.now().toIso8601String());
    //     // loadSnt();
    //       // newNotf = true;
    //       bodyMsg = message['notification']['body'];
    //       data = message['data']['message'];
    //       display = message['notification']['title'];
    //     });
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     showNotification(message['data']);
    //     _fcm.autoInitEnabled();
    //     // AndroidNotificationDetails(channelId, channelName, channelDescription);
    //     print("onResume : $message" + 'is fromResume');
    //     setState(() {
    //       // addStringToSF(DateTime.now().toIso8601String());
    //       // loadEVERY();
    //       // newNotf = true;
    //       bodyMsg = message['notification']['body'];
    //       display = message['notification']['title'];
    //     });
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     showNotification(message['data']);
    //     print("onLaunch: $message" + ':is fromLaunch');
    //     setState(() {
    //       // addStringToSF(DateTime.now().toIso8601String());
    //       // loadEVERY();
    //       // newNotf = true;
    //       bodyMsg = message['notification']['body'];
    //       display = message['notification']['title'];
    //     });
    //     // onUpdate(prefsel)
    //   },
    //   onBackgroundMessage: myBackgroundMessageHandler,
    //   // onBackgroundMessage: 
    // );
    // configLocalNotification();
  }
  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('launch');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flnp.initialize(initializationSettings);
  }
   void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      // Platform.isAndroid
           'tk.notifier.sntiitk',
          // : 'com.duytq.flutterchatdemo',
      'Notifier',
      'Notifier',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));
    // await _flnp.initialize(initializationSettings;\);
    await _flnp.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  // await _flnp.
//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
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
          dialogTheme: DialogTheme(backgroundColor: brightness == Brightness.dark?Colors.black:Colors.white,
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(16.0)
                ),
          ),
          cupertinoOverrideTheme: CupertinoThemeData(
            brightness: brightness,
            // primaryContrastingColor: brightness == Brightness.dark ? Colors.deepPurple: Colors.amber,
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
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    print(data .toString() + 'backgrounddata from home');
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
//   }
//   configLocalNotification();
//  showNotification(message['data']);
  // Or do other work.
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