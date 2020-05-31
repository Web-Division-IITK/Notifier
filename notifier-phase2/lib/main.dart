import 'dart:convert';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as sh;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/rootpage.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:notifier/services/connectivity.dart';
import 'package:notifier/services/database.dart';

NotificationAppLaunchDetails notificationAppLaunchDetails;
NotificationAppLaunchDetails onNotificationAppLaunchDetails;
NotificationAppLaunchDetails onNotificationAppLaunchDetail;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugi = FlutterLocalNotificationsPlugin();
final FlutterLocalNotificationsPlugin fLNP = FlutterLocalNotificationsPlugin();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  sh.timeDilation = 1.0;
  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  onNotificationAppLaunchDetail = await flutterLocalNotificationsPlugi.getNotificationAppLaunchDetails();
  onNotificationAppLaunchDetails = await fLNP.getNotificationAppLaunchDetails();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MyAppHome();
  }
}
class MyAppHome extends StatefulWidget {
  @override
  _MyAppHomeState createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  Map _source = {ConnectionState.none : false};
  CheckNetworkConnectivity _connectivity = CheckNetworkConnectivity.instance;
  // List<SortDateTime> globalPostsArray = [];
  @override
  void initState() {
    _connectivity.initialise();
    _connectivity.myStream.listen((source){

    });
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('launch');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    flutterLocalNotificationsPlugi.initialize(initializationSettings,
        onSelectNotification: selectNotificationP);
    fLNP.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
    appReview();
    super.initState();
  }
  @override
  void dispose() { 
    _connectivity.disposeStream();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => ThemeData(
        fontFamily: 'Raleway',
        // textTheme: GoogleFonts.ralewayTextTheme(
        //   Theme.of(context).textTheme,
        // ),
        
        // primaryColor: brightness == Brightness.dark ? Colors.deepPurple: Colors.amber,
        buttonColor:brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
          splashColor: brightness == Brightness.dark ? Colors.deepPurpleAccent[700] : Colors.blueAccent[700],
          // toggleButtonsTheme: ,
          errorColor: Colors.red,
          
          buttonTheme: ButtonThemeData(
             shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(16.0)
                ),
            buttonColor:brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
            splashColor: Colors.amberAccent,
            // splashColor: Colors.,
            
            textTheme: ButtonTextTheme.primary,
            padding: EdgeInsets.symmetric(horizontal: 20.0)
          ),
          // snackBarTheme: SnackBarThemeData(

          // ),
          textSelectionColor: brightness == Brightness.dark ?Colors.deepPurpleAccent:Colors.blueAccent,
          
          tabBarTheme: TabBarTheme(
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(
              // color: brightness == Brightness.dark ?Colors.bla:Colors.white,
              // fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
            labelColor:  brightness == Brightness.dark ?Colors.white:Colors.black,
          ),
          accentColor: brightness == Brightness.dark ?Colors.deepPurpleAccent:Colors.blueAccent,
          appBarTheme: AppBarTheme(
            color: brightness == Brightness.dark ?Colors.black:Colors.white,
            iconTheme: IconThemeData(
              // color: Colors.white
            ),
            textTheme: TextTheme(
              title: TextStyle(
                fontSize: 20.0,
                color: brightness == Brightness.dark ?Colors.white:Colors.black,
              )
            )
          ),
          // colorScheme: ColorScheme(
          //   primary: brightness == Brightness.dark? Colors.green:Colors.accents, 
          //   primaryVariant: null, 
          //   secondary: null, 
          //   secondaryVariant: null, 
          //   surface: null, 
          //   background: null, 
          //   error: Colors.red, 
          //   onPrimary: null, 
          //   onSecondary: null,
          //   onSurface: null, 
          //   onBackground: null, 
          //   onError: Colors.red, 
          //   brightness: null),          
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
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Raleway',
              )
            ),
            barBackgroundColor: brightness == Brightness.dark ? Colors.pink: Colors.deepOrange,
          ),
          dialogBackgroundColor: brightness == Brightness.dark ? Colors.black:Colors.white,
        // accentColor: MyColors.accent,
        brightness: brightness, // default is dark
      ),
      themedWidgetBuilder: (context, theme) {
        return StyledToast(
          dismissOtherOnShow: true,
          child: MaterialApp(
            // navigatorObservers: [BotToastNavigatorObserver()],
            navigatorKey: MyApp.navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: theme,
//            initialRoute: '/home',
              // routes: {
              //   '/home': (context) => RootPage(auth:new Auth()),
              // },
            home:  /*DataHolderAndProvider(
              // child:*/ FeatureDiscovery(child: RootPage(auth: new Auth())),
              // data: inheritedStream,
            // )
          ),
        );
      },
    );
  }
}
Future _onSelectNotification(String payload)async{
  print('$payload');
  return await DBProvider().getPosts(GetPosts(queryColumn: 'id', queryData: json.decode(payload)['id'])).then((post)async{
    return await  MyApp.navigatorKey.currentState.push(
      MaterialPageRoute(builder: (context){
        return  FeatureDiscovery(child: 
          PostDescription(
            listOfPosts: [post], 
            type: 'display',index: 0,));
      } 
      )
     
    );
  });
}

void appReview()async{
  // await AppReview.getAppID.then((String value)async{
  //   await AppReview.isRequestReviewAvailable.then((onValue)async{
  //     await AppReview.storeListing.then((onValue){
        
  //     });
  //   });
  // });
}
Future showNotification(Map<String, dynamic> message) async {
    var pushTitle;
    var pushText;
    print(message);
    var notdata = message['data'];
    // print(DateTime.fromMillisecondsSinceEpoch(double.parse(notdata['timeStamp']).round()));
    // notdata['timeStamp'] = DateTime.fromMillisecondsSinceEpoch(double.parse(notdata['timeStamp']).round()).toIso8601String();
    // message['data']['timeStamp'] = notdata['timeStamp'];
    // if (Platform.isAndroid) {
      // var nodeData = message['data'];
      pushTitle = notdata['title'];
      pushText = notdata['message'];
    // } 
    print("AppPushs params pushTitle : $pushTitle");
    print("AppPushs params pushText : $pushText");
    var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
        'tk.notifier.sntiitk',
        'Notifier',
        notdata['sub'],
        playSound: true,
        enableVibration: true,
        category: "event",
        // category: "msg",
        channelShowBadge: true,
        channelAction: AndroidNotificationChannelAction.Update,
        visibility: NotificationVisibility.Public,
        // ledColor: Colors.blueGrey,
        // color: Colors.amber,
        ticker: notdata['sub'],
        // ledOnMs: 1000,
        // ledOffMs: 300,
        importance: setPriorityAndImportance(notdata['priority']??'min',notdata['sub']).importance ,
        priority: setPriorityAndImportance(notdata['priority']??'min',notdata['sub']).priority,
        );
    var platformChannelSpecificsIos = new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(platformChannelSpecificsAndroid, platformChannelSpecificsIos);
    int id;
    id = int.parse(notdata['notfID']).toSigned(31);
    // if(id.bitLength>=32){
    //   id.toSigned(31);
    // }
    print(id);
    // = (notdata['notfID']/20000 + DateTime.now().millisecondsSinceEpoch/80000).round();
    // print(id= (double.parse(notdata['notfID'])/20000).round());
    new Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
        id??1,
        pushTitle,
        pushText,
        platformChannelSpecifics,
        payload: json.encode(notdata),
      );
    });
    // }
}
Future showPermissionNotification(Map<String, dynamic> message) async {
    var pushTitle;
    var pushText;
    print(message);
    var notdata = message['data'];
    // print(DateTime.fromMillisecondsSinceEpoch(double.parse(notdata['timeStamp']).round()));
    // notdata['timeStamp'] = DateTime.fromMillisecondsSinceEpoch(double.parse(notdata['timeStamp']).round()).toIso8601String();
    // message['data']['timeStamp'] = notdata['timeStamp'];
    // if (Platform.isAndroid) {
      // var nodeData = message['data'];
      pushTitle = notdata['title'];
      pushText = notdata['message'];
    // } 
    print("AppPushs params pushTitle : $pushTitle");
    print("AppPushs params pushText : $pushText");
    var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
        'tk.notifier.sntiitk',
        'Notifier',
        notdata['sub'],
        playSound: true,
        enableVibration: true,
        category: "event",
        // category: "msg",
        channelShowBadge: true,
        channelAction: AndroidNotificationChannelAction.Update,
        visibility: NotificationVisibility.Public,
        // ledColor: Colors.blueGrey,
        // color: Colors.amber,
        ticker: notdata['sub'],
        // ledOnMs: 1000,
        // ledOffMs: 300,
        importance: Importance.Max ,
        priority: Priority.Max,
        );
    var platformChannelSpecificsIos = new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(platformChannelSpecificsAndroid, platformChannelSpecificsIos);
    int id;
    id = int.parse(notdata['notfID']).toSigned(31);
    // if(id.bitLength>=32){
    //   id.toSigned(31);
    // }
    print(id);
    // = (notdata['notfID']/20000 + DateTime.now().millisecondsSinceEpoch/80000).round();
    // print(id= (double.parse(notdata['notfID'])/20000).round());
    new Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
        id??1,
        // pushTitle,
        'You have new pending permission request',
        'Check it now',
        platformChannelSpecifics,
        payload: json.encode(notdata),
      );
    });
    // }
}
Future selectNotification(String payload) async {
  print('notification payload: ' + payload);
  print('this is fro notification app launch details' + notificationAppLaunchDetails.didNotificationLaunchApp.toString());
  // return await MyApp.navigatorKey.currentState.push(MaterialPageRoute(
  //     builder: (context){
  //       return AboutPage();
  //     }
  // ));
  //  selectNotificationSubject.add(payload);
  // DBProvider().
  return await DBProvider().getPosts(GetPosts(queryColumn: 'id', queryData: json.decode(payload)['id'])).then((post)async{
    return await  MyApp.navigatorKey.currentState.push(
      MaterialPageRoute(builder: (context){
        return  FeatureDiscovery(child: 
      PostDescription(
        listOfPosts: [post], 
        type: 'display',index: 0,));
      } 
      )
     
  );
  });
  
}
Future selectNotificationP(String payload) async {
  print('notification payload: ' + payload);
  print('this is fro notification app launch details' + notificationAppLaunchDetails.didNotificationLaunchApp.toString());
  return await DatabaseProvider(databaseName: 'permission',tableName: 'perm').getPosts(GetPosts(queryColumn: 'id', queryData: json.decode(payload)['id'])).then((post)async{
    return await  MyApp.navigatorKey.currentState.push(
      MaterialPageRoute(builder: (context){
        return  FeatureDiscovery(child: 
      PostDescription(
        listOfPosts: [post], 
        type: 'Create',index: 0,));
      } 
      )
     
    );
  });
}

class ReminderNotification{
  final PostsSort reminder;
  final int id;
  final String notfsDisplay;
  final DateTime time;
  ReminderNotification(this.notfsDisplay,{this.reminder,this.id,this.time});
  get initiate => setupNotification();
  void setupNotification(){
    var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
    'tk.notifier.sntiitk',
    'Notifier',
    reminder.sub,
    playSound: true,
    enableVibration: true,
    styleInformation: DefaultStyleInformation(true, true),
    category: "reminder",
    channelShowBadge: true,
    channelAction: AndroidNotificationChannelAction.Update,
    visibility: NotificationVisibility.Public,
    ledColor: Colors.blueGrey,
    // color: Colors.amber,
    ticker: reminder.sub,
    ledOnMs: 1000,
    ledOffMs: 300,
    importance: Importance.Max,
    priority: Priority.High);
    var platformChannelSpecificsIos = new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(platformChannelSpecificsAndroid, platformChannelSpecificsIos);
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
      fLNP.schedule(
        id??1,
        reminder.title,
        // 'Starting in 10 min',
        notfsDisplay,
        time,
        platformChannelSpecifics,
        payload: json.encode(reminder.toMap()),
        androidAllowWhileIdle: true
      );
    });
  }
  get cancel => fLNP.cancel(id).catchError((onError){
    print(onError);
  });
}

PriorityAndImportance setPriorityAndImportance(String priority,String club){
  if(priority == 'max' || club == 'Web Division'){
    // var priority = Priority.Max;
    // var import = Importance.Max;
    // return (priority,import);
    return PriorityAndImportance(importance: Importance.Max,priority: Priority.Max);
  }else{
    // var priority = Priority.Max;
    // var import = Importance.Max;
    return PriorityAndImportance(importance: Importance.High,priority: Priority.High);
  }
}