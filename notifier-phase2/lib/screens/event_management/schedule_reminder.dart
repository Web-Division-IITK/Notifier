
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:notifier/database/reminder.dart';
// import 'package:notifier/main.dart';
// import 'package:notifier/model/posts.dart';
// import 'package:notifier/screens/event_management/event_description.dart';

// Future onOpenNotification(String payload)async{
//   print('$payload');
//   return await DatabaseProvider().getPosts(GetPosts(queryColumn: 'id', queryData: json.decode(payload)['id'])).then((post)async{
//     return await  MyApp.navigatorKey.currentState.push(
//       MaterialPageRoute(builder: (context){
//         return  EventDescription(
//             listOfPosts: [post], 
//             type: 'display',index: 0,);
//         } 
//       )
//     );
//   });
// }

// class EventReminderNotification{
//   final Posts reminder;
//   final int id;
//   final String notfsDisplay;
//   final DateTime time;
//   EventReminderNotification(this.notfsDisplay,{this.reminder,this.id,this.time});
//   get initiate => setupNotification();
//   void setupNotification(){
//     var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
//     'tk.notifier.sntiitk',
//     'Notifier',
//     reminder.sub[0].toString(),
//     playSound: true,
//     enableVibration: true,
//     styleInformation: DefaultStyleInformation(true, true),
//     category: "reminder",
//     channelShowBadge: true,
//     channelAction: AndroidNotificationChannelAction.update,
//     visibility: NotificationVisibility.public,
//     ledColor: Colors.blueGrey,
//     ticker: reminder.sub[0].toString(),
//     ledOnMs: 1000,
//     ledOffMs: 300,
//     importance: Importance.max,
//     priority: Priority.high);
//     var platformChannelSpecificsIos = new IOSNotificationDetails(presentSound: false);
//     var platformChannelSpecifics = new NotificationDetails(android: platformChannelSpecificsAndroid, iOS: platformChannelSpecificsIos);
//     int notid;
//     notid = (id).toSigned(31);
//     print(id);
//     new Future.delayed(Duration.zero, () {
//       flutterLocalNotification.schedule(
//         notid??1,
//         reminder.title,
//         notfsDisplay,
//         time,
//         platformChannelSpecifics,
//         payload: json.encode(reminder.toMap()),
//         androidAllowWhileIdle: true
//       );
//     });
//   }
//   get cancel => flutterLocalNotification.cancel(id).catchError((onError){
//     print(onError);
//   });
// }
