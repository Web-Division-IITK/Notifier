import 'dart:convert';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as sh;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/model/posts.dart';
import 'package:rxdart/subjects.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:notifier/rootpage.dart';
import 'package:notifier/screens/event_management/schedule_reminder.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:notifier/services/connectivity.dart';
import 'package:notifier/services/database.dart';


// final FlutterLocalNotificationsPlugin permissionNotificationPlugin = FlutterLocalNotificationsPlugin();
final FlutterLocalNotificationsPlugin createNotificationPlugin = FlutterLocalNotificationsPlugin();
// final FlutterLocalNotificationsPlugin reminderNotificationPlugin = FlutterLocalNotificationsPlugin();
// final FlutterLocalNotificationsPlugin flutterLocalNotification = FlutterLocalNotificationsPlugin();
String timeZone;

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  sh.timeDilation = 1.0;
  await _configureLocalTimeZone();
  Firebase.initializeApp();
  // final NotificationAppLaunchDetails permissionNotfAppLaunchDetails = 
  //   await permissionNotificationPlugin.getNotificationAppLaunchDetails();
  final NotificationAppLaunchDetails createNotificationAppLaunchDetails =
    await createNotificationPlugin.getNotificationAppLaunchDetails();
  // final NotificationAppLaunchDetails reminderNotificationAppLaunchDetails = 
  //   await reminderNotificationPlugin.getNotificationAppLaunchDetails();
  // final NotificationAppLaunchDetails eventNotificationAppLaunchDetails;
  var initializationSettingsAndroid = new AndroidInitializationSettings('launch');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
    android : initializationSettingsAndroid,iOS:  initializationSettingsIOS);
  
  // await permissionNotificationPlugin.initialize(initializationSettings,
  //   onSelectNotification: (payload){});
  await createNotificationPlugin.initialize(initializationSettings,
    onSelectNotification: selectCreateNotification);
  // await reminderNotificationPlugin.initialize(initializationSettings,
  //   onSelectNotification: _reminderSelectNotification
  // );
  runApp(MyApp(
    createNotificationAppLaunchDetails: createNotificationAppLaunchDetails,
    // permissionNotfAppLaunchDetails: permissionNotfAppLaunchDetails,
    // reminderNotificationAppLaunchDetails: reminderNotificationAppLaunchDetails,
    ));
  
}

class MyApp extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  const MyApp({this.createNotificationAppLaunchDetails,
    // this.permissionNotfAppLaunchDetails,
    // this.reminderNotificationAppLaunchDetails,
    Key key}) : super(key: key);

  // final NotificationAppLaunchDetails permissionNotfAppLaunchDetails;
  final NotificationAppLaunchDetails createNotificationAppLaunchDetails;
  // final NotificationAppLaunchDetails reminderNotificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      createNotificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // TODO implement connetivity to inform app
  /// provides the connectivity state of app
  CheckNetworkConnectivity _connectivity = CheckNetworkConnectivity.instance;
  @override
  void initState() {
    super.initState();
    _connectivity.initialise();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
    // TODO implement app review
  }
  @override
  void dispose() { 
    _connectivity.disposeStream();
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => ThemeData(
        fontFamily: PRIMARY_FONTFAMILY,
        buttonColor:brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
          splashColor: brightness == Brightness.dark ? Colors.deepPurpleAccent[700] : Colors.blueAccent[700],
          errorColor: Colors.red,
          buttonTheme: ButtonThemeData(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(16.0)
            ),
            buttonColor:brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
            splashColor: Colors.amberAccent,
            textTheme: ButtonTextTheme.primary,
            padding: EdgeInsets.symmetric(horizontal: 20.0)
          ),
          textSelectionColor: brightness == Brightness.dark ?Colors.deepPurpleAccent:Colors.blueAccent,
          tabBarTheme: TabBarTheme(
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(
              fontSize: 20.0,
            ),
            labelColor:  brightness == Brightness.dark ?Colors.white:Colors.black,
          ),
          accentColor: brightness == Brightness.dark ?Colors.deepPurpleAccent:Colors.blueAccent,
          appBarTheme: AppBarTheme(
            color: brightness == Brightness.dark ?Colors.black:Colors.white,
            iconTheme: IconThemeData(
            ),
            textTheme: TextTheme(
              headline1: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              headline2: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              headline3: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              headline4: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              headline5: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              headline6: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              subtitle1: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              subtitle2: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              bodyText1: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              bodyText2: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              ),
              // headline: TextStyle(
              //   fontSize: 20.0,
              //   color: brightness == Brightness.dark ?Colors.white:Colors.black,
              // ),
              // title: TextStyle(
              //   fontSize: 20.0,
              //   color: brightness == Brightness.dark ?Colors.white:Colors.black,
              // )
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
            scaffoldBackgroundColor: brightness == Brightness.dark ? Colors.black:Colors.white,
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Raleway',
              )
            ),
            barBackgroundColor: brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
          ),
          dialogBackgroundColor: brightness == Brightness.dark ? Colors.black:Colors.white,
         brightness: brightness, // default is dark
      ),
      themedWidgetBuilder: (context, theme) {
        return StyledToast(
          locale: Locale('en', 'US'),
          dismissOtherOnShow: true,
          child: MaterialApp(
            navigatorKey: MyApp.navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: FeatureDiscovery(
              child: SafeArea(
                child: RootPage(auth: new Auth()))),
          ),
        );
      },
    );
  }
  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      print(receivedNotification?.payload);
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      print(payload);
    });
  }

}

Future _reminderSelectNotification(String payload)async{
  print('.....REMINDER NOTIFICATION TAPPED >>>>> $payload');
  return await DBProvider().getPosts(GetPosts(queryColumn: 'id', queryData: json.decode(payload)['id'])).then((post)async{
    return await  MyApp.navigatorKey.currentState.push(
      MaterialPageRoute(builder: (context){
        return  FeatureDiscovery(child: 
          PostDescription(
            listOfPosts: [post], 
            type: PostDescType.DISPLAY,index: 0,));
      } 
      )
     
    );
  });
}

/// send isPermission true if it is a approval notification
Future showNotification(Map<String,dynamic> notification ,bool isPermission) async{
  print(".........NOTIFICATION IS >>>>>>>>>>>>>> $notification");
  var notdata = notification["data"];
  var platformChannelSpecificsAndroid = AndroidNotificationDetails(
        'tk.notifier.sntiitk',
        'Notifier',
        notdata[SUB].toString(),
        playSound: true,
        enableVibration: true,
        category: "msg",
        channelShowBadge: true,
        channelAction: AndroidNotificationChannelAction.createIfNotExists,
        visibility: NotificationVisibility.public,
        ticker: notdata[SUB].toString(),
        importance: Importance.max,
        priority: Priority.high,
        );
    var platformChannelSpecificsIos = new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(android: platformChannelSpecificsAndroid,iOS: platformChannelSpecificsIos);
    int id = notdata != null && notdata['notfID'] != null ?
      int.parse(notdata['notfID'])?.toSigned(31)
      : 2;
    print(id);
    new Future.delayed(Duration.zero, () {
      createNotificationPlugin.show(
        id??1,
        isPermission? 'You have new pending permission request': notdata[TITLE],
        isPermission? 'Check it now' :notdata[MESSAGE],
        platformChannelSpecifics,
        payload: json.encode(notdata),
      );
    });
    print("..............SHOW NOTIFICATION FUNCTION ENDS >>>>>>>>>>>>>>>>>");
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
//   timeZone = await FlutterNativeTimezone.getLocalTimezone();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}


Future selectCreateNotification(String payload) async {
  print('....................NOTIFICATION PAYLOAD >>>>>>>>>>>>>> ' + payload);
  try{
    return await DBProvider().getPosts(GetPosts(queryColumn: 'id', queryData: json.decode(payload)['id'])).then((post)async{
      if(post.isFetched == false){
        return await fetchPostFromFirebase(json.decode(payload)[ID]).then((res)async{
          print("....POST FETCHED FROM DATABASE $res");
          if(res != null){
            if(res.containsKey(TIMESTAMP))
              res[TIMESTAMP] = (res[TIMESTAMP] is String)? double.parse(res[TIMESTAMP]).round() :res[TIMESTAMP];
            if(res.containsKey(STARTTIME))
              res[STARTTIME] = (res[STARTTIME] is String)? double.parse(res[STARTTIME]).round() :res[STARTTIME];
            if(res.containsKey(ENDTIME))
              res[ENDTIME] = (res[ENDTIME] is String)? double.parse(res[ENDTIME]).round() :res[ENDTIME];
            Posts _post = postsFromJson(json.encode(res));
            await DBProvider().insertPost(postsFromJson(json.encode(res)));
            return await  MyApp.navigatorKey.currentState.push(
              MaterialPageRoute(builder: (context){
                return  FeatureDiscovery(child: 
                  PostDescription(
                    listOfPosts: [_post], 
                    type: _post.type == NOTF_TYPE_PERMISSION?
                      PostDescType.APPROVAL :
                     PostDescType.DISPLAY,index: 0,));
                  }));
          }else{
            return await  MyApp.navigatorKey.currentState.push(
                MaterialPageRoute(builder: (context){
                  return   FeatureDiscovery(child: SafeArea(child: RootPage(auth: new Auth())));
                })
              ).then((value) => showErrorToast("A message was not fetched, try manually refreshing under post section!"));
          }
        });
      }
      return await  MyApp.navigatorKey.currentState.push(
        MaterialPageRoute(builder: (context){
          return  FeatureDiscovery(child: 
            PostDescription(
              listOfPosts: [post], 
              type: post.type == NOTF_TYPE_PERMISSION?
                      PostDescType.APPROVAL :PostDescType.DISPLAY,index: 0,));
            }));
    });
  }catch(e){
    print(e);
    return await MyApp.navigatorKey.currentState.push(
      MaterialPageRoute(builder: (context){
        return   FeatureDiscovery(child: SafeArea(child: RootPage(auth: new Auth())));
      })
    ).then((value) => showErrorToast("A message was not fetched, try manually refreshing under post section!"));
  }
  
}


class ReminderNotification{
  final Posts reminder;
  final int id;
  final String notfsDisplay;
  final tz.TZDateTime time;
  ReminderNotification(this.notfsDisplay,{this.reminder,this.id,this.time});
  get initiate => setupNotification();
  void setupNotification(){
    print("SUB ${reminder.sub[0]}");
    var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
    'tk.notifier.sntiitk',
    'Notifier',
    reminder.sub[0].toString(),
    playSound: true,
    enableVibration: true,
    styleInformation: DefaultStyleInformation(true, true),
    category: "reminder",
    channelShowBadge: true,
    channelAction: AndroidNotificationChannelAction.createIfNotExists,
    visibility: NotificationVisibility.public,
    ledColor: Colors.blueGrey,
    // color: Colors.amber,
    ticker: reminder.sub[0].toString(),
    ledOnMs: 1000,
    ledOffMs: 300,
    importance: Importance.max,
    priority: Priority.high);
    var platformChannelSpecificsIos = new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(android: platformChannelSpecificsAndroid, iOS: platformChannelSpecificsIos);
    int id;
    id = (reminder.timeStamp).toSigned(31);
    // if(id.bitLength>=32){
    //   id.toSigned(9);
    // }
    print(id);
    // = (notdata['notfID']/20000 + DateTime.now().millisecondsSinceEpoch/80000).round();
    // print(id= (double.parse(notdata['notfID'])/20000).round());
    // fLNP.schedule(id??1, title, body, scheduledDate, notificationDetails)
    new Future.delayed(Duration.zero, () {
      // fLNP.zonedSchedule(id, title, body, scheduledDate, notificationDetails, uiLocalNotificationDateInterpretation: null, androidAllowWhileIdle: null)
      createNotificationPlugin.zonedSchedule(
        id??1,
        reminder.title,
        // 'Starting in 10 min',
        notfsDisplay,
        time,
        // tz.TZDateTime.now(tz.local).add(Duration(milliseconds: 10)),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        payload: json.encode(reminder.toMap()),
        androidAllowWhileIdle: true,

      );
    });
  }
  get cancel => createNotificationPlugin.cancel(id).catchError((onError){
    print(onError);
  });
}





// import 'dart:convert';
// import 'package:dynamic_theme/dynamic_theme.dart';
// import 'package:feature_discovery/feature_discovery.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart' as sh;
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
// import 'package:flutter_styled_toast/flutter_styled_toast.dart';
// import 'package:notifier/authentication/authentication.dart';
// import 'package:notifier/constants.dart';
// import 'package:notifier/database/reminder.dart';
// import 'package:notifier/model/options.dart';
// import 'package:notifier/model/posts.dart';
// import 'package:notifier/screens/home.dart';
// import 'package:notifier/services/functions.dart';
// import 'package:notifier/widget/showtoast.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:notifier/rootpage.dart';
// import 'package:notifier/screens/event_management/schedule_reminder.dart';
// import 'package:notifier/screens/posts/post_desc.dart';
// import 'package:notifier/services/connectivity.dart';
// import 'package:notifier/services/database.dart';

// NotificationAppLaunchDetails permissionNotfAppLaunchDetails;
// NotificationAppLaunchDetails createNotificationAppLaunchDetails;
// NotificationAppLaunchDetails reminderNotificationAppLaunchDetails;
// NotificationAppLaunchDetails eventNotificationAppLaunchDetails;
// final FlutterLocalNotificationsPlugin permissionNotification = FlutterLocalNotificationsPlugin();
// final FlutterLocalNotificationsPlugin createNotification = FlutterLocalNotificationsPlugin();
// final FlutterLocalNotificationsPlugin reminderNotification = FlutterLocalNotificationsPlugin();
// final FlutterLocalNotificationsPlugin flutterLocalNotification = FlutterLocalNotificationsPlugin();
// String timeZone;

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   sh.timeDilation = 1.0;
//   permissionNotfAppLaunchDetails = await permissionNotification.getNotificationAppLaunchDetails();
//   createNotificationAppLaunchDetails = await createNotification.getNotificationAppLaunchDetails();
//   reminderNotificationAppLaunchDetails = await reminderNotification.getNotificationAppLaunchDetails();
//   eventNotificationAppLaunchDetails = await flutterLocalNotification.getNotificationAppLaunchDetails();
//   await Firebase.initializeApp();
//   tz.initializeTimeZones();
//   timeZone = await FlutterNativeTimezone.getLocalTimezone();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   static final navigatorKey = GlobalKey<NavigatorState>();
//   @override
//   Widget build(BuildContext context) {
//     return MyAppHome();
//   }
// }
// class MyAppHome extends StatefulWidget {
//   @override
//   _MyAppHomeState createState() => _MyAppHomeState();
// }

// class _MyAppHomeState extends State<MyAppHome> {
//   CheckNetworkConnectivity _connectivity = CheckNetworkConnectivity.instance;
//   @override
//   void initState() {
//     _connectivity.initialise();
//     _connectivity.myStream.listen((source){

//     });
//     Firebase.initializeApp();
//     tz.setLocalLocation(tz.getLocation(timeZone)); 
//     var initializationSettingsAndroid =
//     new AndroidInitializationSettings('launch');
//     var initializationSettingsIOS = new IOSInitializationSettings();
//     var initializationSettings = new InitializationSettings(
//         android : initializationSettingsAndroid,iOS:  initializationSettingsIOS);
//     permissionNotification.initialize(initializationSettings,
//         onSelectNotification: selectPermissionNotification);
//     createNotification.initialize(initializationSettings,
//         onSelectNotification: selectCreateNotification);
//     reminderNotification.initialize(initializationSettings,
//         onSelectNotification: _reminderSelectNotification);
//     flutterLocalNotification.initialize(initializationSettings,
//         onSelectNotification: onOpenNotification);
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
//     appReview();
//     super.initState();
//   }
//   @override
//   void dispose() { 
//     _connectivity.disposeStream();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return DynamicTheme(
//       defaultBrightness: Brightness.dark,
//       data: (brightness) => ThemeData(
//         fontFamily: 'Raleway',
//         // textTheme: GoogleFonts.ralewayTextTheme(
//         //   Theme.of(context).textTheme,
//         // ),
        
//         // primaryColor: brightness == Brightness.dark ? Colors.deepPurple: Colors.amber,
//         buttonColor:brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
//           splashColor: brightness == Brightness.dark ? Colors.deepPurpleAccent[700] : Colors.blueAccent[700],
//           // toggleButtonsTheme: ,
//           errorColor: Colors.red,
          
//           buttonTheme: ButtonThemeData(
//              shape: new RoundedRectangleBorder(
//                 borderRadius: new BorderRadius.circular(16.0)
//                 ),
//             buttonColor:brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
//             splashColor: Colors.amberAccent,
//             // splashColor: Colors.,
            
//             textTheme: ButtonTextTheme.primary,
//             padding: EdgeInsets.symmetric(horizontal: 20.0)
//           ),
//           // snackBarTheme: SnackBarThemeData(

//           // ),
//           textSelectionColor: brightness == Brightness.dark ?Colors.deepPurpleAccent:Colors.blueAccent,
          
//           tabBarTheme: TabBarTheme(
//             indicatorSize: TabBarIndicatorSize.tab,
//             labelStyle: TextStyle(
//               // color: brightness == Brightness.dark ?Colors.bla:Colors.white,
//               // fontWeight: FontWeight.bold,
//               fontSize: 20.0,
//             ),
//             labelColor:  brightness == Brightness.dark ?Colors.white:Colors.black,
//           ),
//           accentColor: brightness == Brightness.dark ?Colors.deepPurpleAccent:Colors.blueAccent,
//           // primaryColor: brightness == Brightness.dark ?Colors.pink:Colors.deepOrange,
//           appBarTheme: AppBarTheme(
//             color: brightness == Brightness.dark ?Colors.black:Colors.white,
//             iconTheme: IconThemeData(
//               // color: Colors.white
//             ),
//             textTheme: TextTheme(
//               headline1: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               headline2: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               headline3: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               headline4: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               headline5: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               headline6: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               subtitle1: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               subtitle2: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               bodyText1: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               bodyText2: TextStyle(
//                 fontSize: 20.0,
//                 color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               ),
//               // headline: TextStyle(
//               //   fontSize: 20.0,
//               //   color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               // ),
//               // title: TextStyle(
//               //   fontSize: 20.0,
//               //   color: brightness == Brightness.dark ?Colors.white:Colors.black,
//               // )
//             )
//           ),
//           // backgroundColor: brightness == Brightness.dark?Colors.black:Colors.white,
//           // highlightColor: brightness == Brightness.dark ?Colors.white:Colors.black,        
//           toggleableActiveColor: brightness == Brightness.dark ? Colors.teal:Colors.green,
//           dialogTheme: DialogTheme(backgroundColor: brightness == Brightness.dark?Colors.black:Colors.white,
//             elevation: 5.0,
//             shape: new RoundedRectangleBorder(
//                 borderRadius: new BorderRadius.circular(16.0)
//                 ),
//           ),
//           cupertinoOverrideTheme: CupertinoThemeData(
//             brightness: brightness,
//             // primaryContrastingColor: brightness == Brightness.dark ? Colors.deepPurple: Colors.amber,
//             scaffoldBackgroundColor: brightness == Brightness.dark ? Colors.black:Colors.white,
//             // primaryColor:  brightness == Brightness.dark ? Colors.deepPurple: Colors.amber,
//             textTheme: CupertinoTextThemeData(
//               dateTimePickerTextStyle: TextStyle(
//                 color: Colors.white,
//                 fontFamily: 'Raleway',
//               )
//             ),
//             barBackgroundColor: brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
//           ),
//           dialogBackgroundColor: brightness == Brightness.dark ? Colors.black:Colors.white,
//         // accentColor: MyColors.accent,
//         brightness: brightness, // default is dark
//       ),
//       themedWidgetBuilder: (context, theme) {
//         return StyledToast(
//           locale: Locale('en', 'US'),
//           dismissOtherOnShow: true,
//           child: MaterialApp(
//             // navigatorObservers: [BotToastNavigatorObserver()],
//             navigatorKey: MyApp.navigatorKey,
//             debugShowCheckedModeBanner: false,
//             theme: theme,
// //            initialRoute: '/home',
//               // routes: {
//               //   '/home': (context) => RootPage(auth:new Auth()),
//               // },
//             home:  /*DataHolderAndProvider(
//               // child:*/ FeatureDiscovery(child: SafeArea(child: RootPage(auth: new Auth()))),
//               // data: inheritedStream,
//             // )
//           ),
//         );
//       },
//     );
//   }
// }
// Future _reminderSelectNotification(String payload)async{
//   print('.....REMINDER NOTIFICATION TAPPED >>>>> $payload');
//   return await DBProvider().getPosts(GetPosts(queryColumn: 'id', queryData: json.decode(payload)['id'])).then((post)async{
//     return await  MyApp.navigatorKey.currentState.push(
//       MaterialPageRoute(builder: (context){
//         return  FeatureDiscovery(child: 
//           PostDescription(
//             listOfPosts: [post], 
//             type: PostDescType.DISPLAY,index: 0,));
//       } 
//       )
     
//     );
//   });
// }

// void appReview()async{
//   // await AppReview.getAppID.then((String value)async{
//   //   await AppReview.isRequestReviewAvailable.then((onValue)async{
//   //     await AppReview.storeListing.then((onValue){
        
//   //     });
//   //   });
//   // });
// }
// Future showNotification(Map<String, dynamic> message) async {
//     var pushTitle;
//     var pushText;
//     print(message);
//     var notdata = message['data'];
//       pushTitle = notdata['title'];
//       pushText = notdata['message'];
//     // } 
//     print(">>SHOWING NOTIFICATION TITLE : $pushTitle");
//     print("....NOTIFICATION SUB : ${notdata[SUB]}");
//     var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
//         'tk.notifier.sntiitk',
//         'Notifier',
//         notdata[SUB].toString(),
//         playSound: true,
//         enableVibration: true,
//         // category: "event",
//         category: "msg",
//         channelShowBadge: true,
//         channelAction: AndroidNotificationChannelAction.createIfNotExists,
//         visibility: NotificationVisibility.public,
//         ticker: notdata[SUB].toString(),
//         importance: Importance.max,
//         priority: Priority.high,
//         );
//     var platformChannelSpecificsIos = new IOSNotificationDetails(presentSound: false);
//     var platformChannelSpecifics = new NotificationDetails(android: platformChannelSpecificsAndroid,iOS: platformChannelSpecificsIos);
//     int id;
//     id = int.parse(notdata['notfID']).toSigned(31);
//     print(id);
//     new Future.delayed(Duration.zero, () {
//       createNotification.show(
//         id??1,
//         pushTitle,
//         pushText,
//         platformChannelSpecifics,
//         payload: json.encode(notdata),
//       );
//     });
// }
// Future showPermissionNotification(Map<String, dynamic> message) async {
//     var pushTitle;
//     var pushText;
//     print(message);
//     var notdata = message['data'];
//     // print(DateTime.fromMillisecondsSinceEpoch(double.parse(notdata['timeStamp']).round()));
//     // notdata['timeStamp'] = DateTime.fromMillisecondsSinceEpoch(double.parse(notdata['timeStamp']).round()).toIso8601String();
//     // message['data']['timeStamp'] = notdata['timeStamp'];
//     // if (Platform.isAndroid) {
//       // var nodeData = message['data'];
//       pushTitle = notdata['title'];
//       pushText = notdata['message'];
//     // } 
//     print("AppPushs params pushTitle : $pushTitle");
//     print("AppPushs params pushText : $pushText");
//     var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
//         'tk.notifier.sntiitk',
//         'Notifier',
//         notdata[SUB].toString(),
//         playSound: true,
//         enableVibration: true,
//         category: "event",
//         // category: "msg",
//         channelShowBadge: true,
//         channelAction: AndroidNotificationChannelAction.createIfNotExists,
//         visibility: NotificationVisibility.public,
//         // ledColor: Colors.blueGrey,
//         // color: Colors.amber,
//         ticker: notdata[SUB].toString(),
//         // ledOnMs: 1000,
//         // ledOffMs: 300,
//         importance: Importance.max ,
//         priority: Priority.max,
//         );
//     var platformChannelSpecificsIos = new IOSNotificationDetails(presentSound: false);
//     var platformChannelSpecifics = new NotificationDetails(android: platformChannelSpecificsAndroid, iOS: platformChannelSpecificsIos);
//     int id;
//     id = int.parse(notdata['notfID']).toSigned(31);
//     // if(id.bitLength>=32){
//     //   id.toSigned(31);
//     // }
//     print(id);
//     // = (notdata['notfID']/20000 + DateTime.now().millisecondsSinceEpoch/80000).round();
//     // print(id= (double.parse(notdata['notfID'])/20000).round());
//     new Future.delayed(Duration.zero, () {
//       permissionNotification.show(
//         id??1,
//         // pushTitle,
//         'You have new pending permission request',
//         'Check it now',
//         platformChannelSpecifics,
//         payload: json.encode(notdata),
//       );
//     });
//     // }
// }
// Future selectCreateNotification(String payload) async {
//   print('notification payload: ' + payload);
//   try{
//     print('this is fro notification app launch details' + createNotificationAppLaunchDetails.didNotificationLaunchApp.toString());
//     return await DBProvider().getPosts(GetPosts(queryColumn: 'id', queryData: json.decode(payload)['id'])).then((post)async{
//       if(post.isFetched == false){
//         return await fetchPostFromFirebase(json.decode(payload)[ID]).then((res)async{
//           print("....POST FETCHED FROM DATABASE $res");
//           if(res != null){
//             if(res.containsKey(TIMESTAMP))
//               res[TIMESTAMP] = (res[TIMESTAMP] is String)? double.parse(res[TIMESTAMP]).round() :res[TIMESTAMP];
//             if(res.containsKey(STARTTIME))
//               res[STARTTIME] = (res[STARTTIME] is String)? double.parse(res[STARTTIME]).round() :res[STARTTIME];
//             if(res.containsKey(ENDTIME))
//               res[ENDTIME] = (res[ENDTIME] is String)? double.parse(res[ENDTIME]).round() :res[ENDTIME];
//             // await DBProvider().insertPost(postsFromJson(json.encode(res)));
//             // return await  MyApp.navigatorKey.currentState.push(
//             //   MaterialPageRoute(builder: (context){
//             //     return  FeatureDiscovery(child: 
//             //       PostDescription(
//             //         listOfPosts: [post], 
//             //         type: PostDescType.DISPLAY,index: 0,));
//             //       }));
//           }else{
//             return await  MyApp.navigatorKey.currentState.push(
//                 MaterialPageRoute(builder: (context){
//                   return   FeatureDiscovery(child: SafeArea(child: RootPage(auth: new Auth())));
//                 })
//               ).then((value) => showErrorToast("A message was not fetched, try manually refreshing under post section!"));
//           }
//         });
//       }
//       // return await  MyApp.navigatorKey.currentState.push(
//       //   MaterialPageRoute(builder: (context){
//       //     return  FeatureDiscovery(child: 
//       //       PostDescription(
//       //         listOfPosts: [post], 
//       //         type: PostDescType.DISPLAY,index: 0,));
//       //       }));
//     });
//   }catch(e){
//     print(e);
//     // return await MyApp.navigatorKey.currentState.push(
//     //   MaterialPageRoute(builder: (context){
//     //     return   FeatureDiscovery(child: SafeArea(child: RootPage(auth: new Auth())));
//     //   })
//     // ).then((value) => showErrorToast("A message was not fetched, try manually refreshing under post section!"));
//   }
  
// }
// Future selectPermissionNotification(String payload) async {
//   print('notification payload: ' + payload);
//   print('this is fro notification app launch details' + permissionNotfAppLaunchDetails.didNotificationLaunchApp.toString());
//   try{
//     return await DBProvider()
//     .getPosts(GetPosts(queryColumn: 'id', queryData: json.decode(payload)['id']))
//     .then((post)async{
//       if(post.isFetched == false){
//         return await fetchPostFromFirebase(json.decode(payload)[ID]).then((res)async{
//           if(res != null){
//             if(res.containsKey(TIMESTAMP))
//               res[TIMESTAMP] = (res[TIMESTAMP] is String)? double.parse(res[TIMESTAMP]).round() :res[TIMESTAMP];
//             if(res.containsKey(STARTTIME))
//               res[STARTTIME] = (res[STARTTIME] is String)? double.parse(res[STARTTIME]).round() :res[STARTTIME];
//             if(res.containsKey(ENDTIME))
//               res[ENDTIME] = (res[ENDTIME] is String)? double.parse(res[ENDTIME]).round() :res[ENDTIME];
//           await DBProvider().insertPost(postsFromJson(json.encode(res)));
//             return await  MyApp.navigatorKey.currentState.push(
//               MaterialPageRoute(builder: (context){
//                 return  FeatureDiscovery(child: 
//                   PostDescription(
//                     listOfPosts: [post], 
//                     type: PostDescType.APPROVAL,index: 0,));
//                   } 
//               )
//             );
//           }
//           else{
//             return await  MyApp.navigatorKey.currentState.push(
//               MaterialPageRoute(builder: (context){
//                 return   FeatureDiscovery(child: SafeArea(child: RootPage(auth: new Auth())));
//               })
//             ).then((value) => showErrorToast("A message was not fetched, try manually refreshing under post section!"));
//           }
//         });
//       }
//       return await  MyApp.navigatorKey.currentState.push(
//         MaterialPageRoute(builder: (context){
//           return  FeatureDiscovery(child: 
//         PostDescription(
//           listOfPosts: [post], 
//           type: PostDescType.APPROVAL,index: 0,));
//         })
//       );
//     });
//   }catch(e){
//     print(e);
//     return await  MyApp.navigatorKey.currentState.push(
//               MaterialPageRoute(builder: (context){
//                 return   FeatureDiscovery(child: SafeArea(child: RootPage(auth: new Auth())));
//               })
//             ).then((value) => showErrorToast("A message was not fetched, try manually refreshing under post section!"));
//   }
// }

// class ReminderNotification{
//   final Posts reminder;
//   final int id;
//   final String notfsDisplay;
//   final tz.TZDateTime time;
//   ReminderNotification(this.notfsDisplay,{this.reminder,this.id,this.time});
//   get initiate => setupNotification();
//   void setupNotification(){
//     print("SUB ${reminder.sub[0]}");
//     var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
//     'tk.notifier.sntiitk',
//     'Notifier',
//     reminder.sub[0].toString(),
//     playSound: true,
//     enableVibration: true,
//     styleInformation: DefaultStyleInformation(true, true),
//     category: "reminder",
//     channelShowBadge: true,
//     channelAction: AndroidNotificationChannelAction.createIfNotExists,
//     visibility: NotificationVisibility.public,
//     ledColor: Colors.blueGrey,
//     // color: Colors.amber,
//     ticker: reminder.sub[0].toString(),
//     ledOnMs: 1000,
//     ledOffMs: 300,
//     importance: Importance.max,
//     priority: Priority.high);
//     var platformChannelSpecificsIos = new IOSNotificationDetails(presentSound: false);
//     var platformChannelSpecifics = new NotificationDetails(android: platformChannelSpecificsAndroid, iOS: platformChannelSpecificsIos);
//     int id;
//     id = (reminder.timeStamp).toSigned(31);
//     // if(id.bitLength>=32){
//     //   id.toSigned(9);
//     // }
//     print(id);
//     // = (notdata['notfID']/20000 + DateTime.now().millisecondsSinceEpoch/80000).round();
//     // print(id= (double.parse(notdata['notfID'])/20000).round());
//     // fLNP.schedule(id??1, title, body, scheduledDate, notificationDetails)
//     new Future.delayed(Duration.zero, () {
//       // fLNP.zonedSchedule(id, title, body, scheduledDate, notificationDetails, uiLocalNotificationDateInterpretation: null, androidAllowWhileIdle: null)
//       reminderNotification.zonedSchedule(
//         id??1,
//         reminder.title,
//         // 'Starting in 10 min',
//         notfsDisplay,
//         time,
//         // tz.TZDateTime.now(tz.local).add(Duration(milliseconds: 10)),
//         platformChannelSpecifics,
//         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
//         payload: json.encode(reminder.toMap()),
//         androidAllowWhileIdle: true,

//       );
//     });
//   }
//   get cancel => reminderNotification.cancel(id).catchError((onError){
//     print(onError);
//   });
// }

// // PriorityAndImportance setPriorityAndImportance(String priority,String club){
// //   if(priority == 'max' || club == 'Web Division'){
// //     // var priority = Priority.Max;
// //     // var import = Importance.Max;
// //     // return (priority,import);
// //     return PriorityAndImportance(importance: Importance.Max,priority: Priority.Max);
// //   }else{
// //     // var priority = Priority.Max;
// //     // var import = Importance.Max;
// //     return PriorityAndImportance(importance: Importance.High,priority: Priority.High);
// //   }
// // }