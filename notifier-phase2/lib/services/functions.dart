import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/hive_allCouncilData.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/widget/showtoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> addStringToSF(String date) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool checkValue = prefs.containsKey('lastTime');
    if (checkValue) {
      await prefs.remove("lastTime");
    }

    return await prefs.setString('lastTime', "$date");
  } catch (e) {
    print(e.toString() + ' error while');
    return false;
  }
}

Future<String> getStringValuesSF() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    bool checkValue = prefs.containsKey('lastTime');
    // prefs.reload()
    String stringValue = checkValue ? prefs.getString('lastTime') : '0';
    return stringValue;
  } catch (e) {
    print(e.toString() + ' error while');
    return 'Error!!';
  }
}

removeValues() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Remove String
    bool checkValue = prefs.containsKey('lastTime');
    var _v;
    if (checkValue) {
      _v = await prefs.remove("lastTime");
    } else {
      _v = null;
    }
    return _v != null ? true : null;
  } catch (e) {
    print(e.toString() + 'Error removing value');
    return null;
  }
}

///loads all posts greater than or equal to provided time
// Future<bool> loadAllPosts(var postsAccToCouncil)async{
//   Map<String,dynamic> posts = {};
//   var db = Firestore.instance;
//   return await fileExists('posts').then((bool exists)async{
//     if(!exists){
//        await writeContent('posts',json.encode({'postsAccToCouncil':postsAccToCouncil}));
//       // return await p1(posts,postsAccToCouncil,'5');
//     }
//     else{
//       // await p1(posts,postsAccToCouncil,'5');
//       return await readContent('posts').then((var value) async {
//           if (value != null) {
//             if(value['postsAccToCouncil']!=null){
//               posts = value['postsAccToCouncil'];
//               print('value exists of posts line71 function.dart:' +
//               posts.toString());
              
//               return writeContent('posts',json.encode({'postsAccToCouncil':postsAccToCouncil}));
//             }
//            else{
//              return await db.collection('posts').document('council').get().then((DocumentSnapshot snapshot) async{
//                return await writeContent('posts',json.encode({'postsAccToCouncil':snapshot.data}));
//              });
//            }
//           } else {
//             return await db.collection('posts').document('council').get().then((DocumentSnapshot snapshot) async{
//                return await writeContent('posts',json.encode({'postsAccToCouncil':snapshot.data}));
//              });
//           }
//         });
//     }
//   });
// }
// geallposts()async{
//   var db= Firestore.instance;
//   return await db.collection('snt').getDocuments().then((QuerySnapshot snapshot){
//     print(snapshot.documents);
//     snapshot.documents.forEach((f) async{
//       var data = f.data;
//       data['timeStamp'] = (data['timeStamp'] as Timestamp).toDate().millisecondsSinceEpoch;
//       data.update('club', (_){
//               return data['sub'][0];
//            },ifAbsent: ()=>data['sub'][0]);
//       print(json.encode(data));
//       Posts nwPosts = postsFromJson(json.encode(data));
//               // printPosts(nwPosts);
//                 // Future.delayed(Duration(seconds: 2), () async{
//       await DBProvider().newPost(nwPosts);
//                 // });
//     });       
//   });
// }
/// return null for no data 
Future<bool> p1(last,{@required String owner}) async {
  var db = Firestore.instance;
  return await getStringValuesSF().then((String lastTime) async {
    print(lastTime + 'lasttime line81 funtion.dart');
    if (lastTime == '0' || last == '0') {
      return await db
          .collection('allPosts')
          // .where('type',arrayContainsAny: ['create','update'])
          .orderBy('timeStamp',descending: true).limit(50)
          .getDocuments()
          .then((QuerySnapshot snapshot) async {
            print(snapshot.documents);
                if(snapshot.documents.length!=0){
                  snapshot.documents.forEach((f) async{
                    if(f.data['type'] == 'permission'){}
                    else{
                      var data = f.data;
                        data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                        if(data.containsKey("startTime")){
                          data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                        }
                        if(data.containsKey("endTime")){
                          data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                        }
                        data.update('sub', (_){
                                return data['sub'][0];
                            },ifAbsent: ()=>data['sub'][0]);
                        print(json.encode(data));
                        Posts nwPosts = postsFromJson(json.encode(data));
                        await DBProvider().newPost(nwPosts);
                        if(owner == nwPosts.owner) await DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(postsSortFromJson(json.encode(data)));
                    }
                // });
                  });
                  addStringToSF(DateTime.now().toIso8601String());
                  return true; 
                  }
                  else{
                    addStringToSF(DateTime.now().toIso8601String());
                    return null;
                  }
            }).catchError((onError){
              print('Error in p1\' : $onError');
              return false;
            });
    } else {
      return await db.collection('allPosts')
      // .where('type',arrayContainsAny: ['create','update'])
          .where('timeStamp', isGreaterThanOrEqualTo: DateTime.parse(lastTime)).orderBy('timeStamp',descending: true).limit(50)
          .getDocuments()
          .then((QuerySnapshot snapshot) async {
            if(snapshot.documents.length!=0){
                  snapshot.documents.forEach((f) async{
                    if(f.data['type'] == 'permission'){}
                    else{
                      var data = f.data;
                        data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                        if(data.containsKey("startTime")){
                          data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                        }
                        if(data.containsKey("endTime")){
                          data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                        }
                        data.update('sub', (_){
                                return data['sub'][0];
                            },ifAbsent: ()=>data['sub'][0]);
                        print(json.encode(data));
                        Posts nwPosts = postsFromJson(json.encode(data));
                        await DBProvider().newPost(nwPosts);
                        if(owner == nwPosts.owner) await DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(postsSortFromJson(json.encode(data)));
                    }
                  });
                  addStringToSF(DateTime.now().toIso8601String());
                  return true; 
            }else{
              addStringToSF(DateTime.now().toIso8601String());
              return null;
            }
      }).catchError((onError){
              print('Error in p1\' : $onError');
              return false;
            });
    }
  });
}



Stream<String> checkTime(DateTime postTime)async*{
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year,now.month,now.day - 1);
  final aDate = DateTime(postTime.year,postTime.month,postTime.day);
  if(aDate == today){
    yield ('Today');
  }else if(aDate == yesterday){
    yield 'Yesterday';
  }else{
     yield DateFormat("d MMMM, yyyy").format(postTime);
  }
}
String convertDateToString(DateTime postTime){
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year,now.month,now.day - 1);
  final aDate = DateTime(postTime.year,postTime.month,postTime.day);
  if(aDate == today){
    return ('Today');
  }else if(aDate == yesterday){
    return 'Yesterday';
  }else{
     return DateFormat("dd MMMM, yyyy").format(postTime);
  }
}
Future<dynamic> allData() async {
  final HttpClient _httpClient = HttpClient();
  var jsonResponse;
  try {
    final uri = Uri.http('notifier-phase-2.firebaseapp.com',
        '/data.json'); 
    final httpRequest = await _httpClient.getUrl(uri);
    final httpResponse = await httpRequest.close();
    if (httpResponse.statusCode != 200) {
      // jsonResponse = 'errorObtaining';
      jsonResponse = null;
    }
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    jsonResponse = json.decode(responseBody);
  } on Exception catch (e) {
    print('$e');
    jsonResponse = null;
  }
  if (jsonResponse == null) {
    print('Error retreiving content data');
    return null;
  }
  print(jsonResponse);
  
  // box.add()
  // await writeContent('allData', json.encode(jsonResponse));

  return jsonResponse;
}
/// returns data or null;
Future<Councils> councilData() async {
  Box box = await HiveDatabaseUser(databaseName: 'councilData').hiveBox;
  if(box.isEmpty){
    return await allData().then((var data) async {
      print(data);
      try {
        if(data!=null){
          Councils myData = Councils.fromMap(data);
          box.add(myData);
          return myData;
        } else {
          return null;
        }
      } catch (e) {
        print(e);
        showErrorToast('${e.message}');
        return null;
      }
    });
  }else{
    if(box.toMap()[0] != null){
      return box.toMap()[0];
    }else{
      return await allData().then((var data) async {
        print(data);
        try {
          if(data!=null){
            Councils myData = Councils.fromMap(data);
            box.add(myData);
            return myData;
          } else {
            return null;
          }
        } catch (e) {
          print(e);
          showErrorToast('${e.message}');
          return null;
        }
      });
    }
  }
  // return await fileExists('allData').then((var status) async {
  //   if (status) {
  //     return await readContent('allData').then((var data) async {
  //       if (data == null) {
  //         return await allData().then((var data) async {
  //           print(data);
  //           try {
  //             if (data != null) {
  //               Councils myData = Councils.fromMap(data);
  //               return myData;
  //             } else {
  //               return null;
  //             }
  //           } catch (e) {
  //             print(e);
  //             showErrorToast('${e.message}');
  //             // Fluttertoast.showToast(msg: e.message.toString());
  //             return null;
  //           }
  //         });
  //       } else {
  //         // Councils myData;
  //         // myData = Councils(globalCouncils: data)
  //         print(data['councils']);
  //          Councils myData = Councils.fromMap(data);

  //         // myData = Councils(
  //         //   // psg: SubCouncil.fromMap(data['psg']),
  //         //   presiChairPerson: [],
  //         //   councilsWithNoPower: data['councilsWithNoPower'].cast<String>(), 
  //         //   globalCouncils : data['councils'].cast<String>(),
  //         //   level3 : data['level3'].cast<String>(),
  //         //   subCouncil: [],
  //         //   coordOfCouncil: [],
  //         // );
  //         // for (var i in data['councils']) {
  //         //     print(data['councils']);
  //         //   myData.subCouncil.insert(data['councils'].indexOf(i),
  //         //     SubCouncil(
  //         //       council: i.toString(),
  //         //       entity: data[i]['entity'].cast<String>(),
  //         //       level2: data[i]['level2'].cast<String>(),
  //         //       misc: data[i]['misc'].cast<String>(),
  //         //       coordiOfInCouncil: [],
  //         //       select: [],
  //         //   ));
  //         // }
  //         return myData;
  //       }
  //     });
  //   } else {
  //     return await allData().then((var data) async {
  //       try {
  //         if (data != null) {
  //         //   Councils myData;
  //         //     myData = Councils(
  //         //       // psg: SubCouncil.fromMap(data['psg']),
  //         //       presiChairPerson: [],
  //         //       councilsWithNoPower: data['councilsWithNoPower'].cast<String>(), 
  //         //       globalCouncils : data['councils'].cast<String>(),
  //         //       level3 : data['level3'].cast<String>(),
  //         //       coordOfCouncil: [],
  //         //       subCouncil: [],
  //         //   );
  //         // for (var i in data['councils']) {
            
  //         //   myData.subCouncil.insert(data['councils'].indexOf(i),
  //         //     SubCouncil(
  //         //       council: i.toString(),
  //         //       entity: data[i]['entity'].cast<String>(),
  //         //       level2: data[i]['level2'].cast<String>(),
  //         //       misc: data[i]['misc'].cast<String>(),
  //         //       coordiOfInCouncil: [],
  //         //       select: []
  //         //   ));
  //         // }
  //          Councils myData = Councils.fromMap(data);

  //           return myData;
  //         } else {
  //           return null;
  //         }
  //       } catch (e) {
  //         print(e);
  //         showErrorToast('Error while loading');
  //         // Fluttertoast.showToast(msg: e.message.toString());
  //         return null;
  //       }
  //     });
  //   }
  // });
}
String convertFromCouncilName(String name){
  switch(name){
    case 'SnT': return 'snt';
      break;
    case 'SS': return 'ss';
      break;
    case 'MnC': return 'mnc';
      break;
    case 'AnC UG': return 'anc_ug';
      break;
    case 'AnC PG': return 'anc_pg';
      break;
    case 'GnS': return 'gns';
      break;
    case 'AnC': return 'anc';
      break;
    case 'PSG': return 'psg';
      break;
    default: return name.toLowerCase();
  }
}

String convertToCouncilName(String council){
  switch (council) {
    case 'snt': return 'SnT';
      break;
    case 'ss': return 'SS';
      break;
    case 'mnc': return 'MnC';
      break;
    case 'anc_pg': return 'AnC PG';
      break;
    case 'anc_ug': return 'AnC UG';
      break;
    case 'gns': return 'GnS';
      break;
    case 'anc': return 'AnC';
      break;
    case 'psg': return 'PSG';
      break;
    default: return council == null? 'null':council[0].toUpperCase() + council.substring(1).toLowerCase();
  }
}
String councilNameTOfullForms(String council){
    // print(council);
   switch (council) {
     case 'snt': return 'Science and Technology Council';
       break;
    case 'mnc': return 'Media and Cultural Council';
       break;
    case 'anc': return 'Academic and Career Council';
    break;
    case 'gns': return 'Games and Sports Council';
    break;
    case 'psg': return 'President Students Gymkhana';
    break;
    case 'senate': return 'Students Senate';
    break;
    // case 'gns': return 'Games and Sports Council';
    // break;
    // case 'gns': return 'Games and Sports Council';
    // break;
    // case 'ss':return 'Students\' Senate';
    // break;
     default: return council;
   } 
  }

Future<Response> publishPosts(String uid,PostsSort postsSort,bool priority,{bool permission = false})async{
  Map<String, String> headers = {"Content-type": "application/json"};
  String url;
  print('permission ' ':' '$permission');
  //  = (uid == null)? 
  // 'https://us-central1-notifier-phase-2.cloudfunctions.net/makePost' // create post
  // : 'https://us-central1-notifier-phase-2.cloudfunctions.net/editPost'; // edit post
  if(permission){
    postsSort.type = 'permission';
    
    url = (postsSort.id == null || postsSort.id.trim() == null || postsSort.id.trim() == '')? 
      'https://us-central1-notifier-phase-2.cloudfunctions.net/makePost' //create post
      : 'https://us-central1-notifier-phase-2.cloudfunctions.net/editPost'; // update post
   
  }else{
    if(postsSort.type == 'permission' && postsSort.owner != id ){
      if (postsSort.id != null ) {
        postsSort.type = 'create';
        // url = 'https://us-central1-notifier-phase-2.cloudfunctions.net/makePost'; // create post
      //   await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(postsSort.id);
      } else {
        postsSort.type = 'update';
      }
        url = 'https://us-central1-notifier-phase-2.cloudfunctions.net/editPost'; // update post
      // }
        await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(postsSort.id);
      // }
    }else{
      postsSort.type = (postsSort.id == null || postsSort.id.trim() == null || postsSort.id.trim() == '')? 
        'create'
        : 'update';
      url = (postsSort.id == null || postsSort.id.trim() == null || postsSort.id.trim() == '')? 
        'https://us-central1-notifier-phase-2.cloudfunctions.net/makePost' // create post
        : 'https://us-central1-notifier-phase-2.cloudfunctions.net/editPost'; // update post
      // await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(postsSort.id);
    } 
  }


  Map<String,dynamic> mapData = postsSort.toMapData();
  mapData.update('priority', (v){
    return priority || permission? 'max':'default';
  },ifAbsent: ()=>priority || permission? 'max':'default');
  String jsonPost = json.encode(mapData);
  print(jsonPost);
  try{
    Response res = await post(url,headers:headers,body: jsonPost);
    print(res.statusCode);
    // if(uid == null ) {
      print(res.body); 
     if(res.statusCode == 200){
        postsSort.id = res.body;
     }else{
       postsSort.id = '';
     }
    // }
       
    if(permission && res.statusCode == 200){
      postsSort.timeStamp = DateTime.now().millisecondsSinceEpoch;
      await DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(postsSort);
    } 
    return res;
  }catch(e){
    print('$e' + 'error while publishing post');
    showErrorToast('An unknown exception occured while publishing the post');
    return Response('Error', 404);
  }
}

Future<Response> deletePost(PostsSort postsSort,{bool permission = false})async{
  Map<String, String> headers = {"Content-type": "application/json"};
  String jsonPost = json.encode(postsSort.toMapData());
  print(jsonPost);
   String url = 'https://us-central1-notifier-phase-2.cloudfunctions.net/deletePost';
   if(permission){
     try {
       return databaseReference.collection('notification').document(postsSort.id).delete().then((val){
         DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(postsSort.id);
         return Response('Done',200);
       });
     } catch (e) {
       print(e);
       return Response('Error',404);
     }
   }
    try {
      Response response = await post(url, headers: headers, body: jsonPost);
      int statusCode = response.statusCode;
      print(statusCode);

      return response;
    } catch (e) {
      print('$e' + 'error while deleting post');
      showErrorToast(e.message??'An unknown exception occured while deleting the post');
      return Response('Error', 404);
    }
}

Future<Map<String,dynamic>> fetchPostFromFirebase(String id,{String collection = 'allPosts'}) async{
  try {
    return await databaseReference.collection('allPosts').document(id).get().then((var snapshot) async{
      var data = snapshot.data;
      data.update('sub', (v)=>v[0]);
      // data['timeStamp'] = double.parse(data['timeStamp']).round()??DateTime.now().millisecondsSinceEpoch;
      // return await DBProvider().newPost(postsFromJson(json.encode(snapshot.data)));
      return data;
    }).catchError((onError){
      print(onError);
      return null;
    });
  } catch (e) {
    print(e);
    return null;
  }
}

DateTime replaceMinuteAndHourFromDate(String duration,DateTime date){
  // print(duration);
  int hour = 0;
  int minutes = 0;
  if (duration.contains(' hours')) {
    var d = duration.split(' hours');
    for (var i in d) {
      i = i.replaceAll(' minutes', '');
      i = i.replaceAll(' hours', '');
      i= i.replaceAll(' and ', '');
      // d[d.indexOf(i)] = i;
    }
    d[0] = d[0].replaceAll(' minutes', '');
      d[0] = d[0].replaceAll(' hours', '');
      d[0]= d[0].replaceAll(' and ', '');
    // print(d);
      hour= double.parse(d[0]).floor();
    if(d[1]!=null && d[1]!= ''){
      d[1] = d[1].replaceAll(' minutes', '');
      d[1] = d[1].replaceAll(' hours', '');
      d[1]= d[1].replaceAll(' and ', '');
    minutes = double.parse(d[1]).floor();
    }
  } else {
      duration = duration.replaceAll(' minutes', '');
      duration = duration.replaceAll(' hours', '');
      duration.replaceAll(' and ', '');
    minutes = double.parse(duration).floor();
  }
  return DateTime(date.year,date.month,date.day,date.hour+ hour,date.minute+minutes);
  // var d= duration.split(' minutes');

  
}

DateTime convertDateFromStringToDateTime(String date){
  //02:45 PM, 20 April, 2020
  // print(date.substring(13,(date.length - 6)));
  int hour = double.parse(date.substring(0,2)).round();
  int minute = double.parse(date.substring(3,5)).round();
  String amPm = date.substring(6,8);
  if(amPm == 'PM' && hour !=12){
    hour +=12;
    // DateTime()
  }
  int day = double.parse(date.substring(10,12)).round();
  int year = double.parse(date.substring((date.length - 4), (date.length))).round();
  String month = date.substring((13),(date.length - 6));
  print(month);
  // print(DateTime(year,convertMonthFromStringToInt(month), day,hour,minute));
  return DateTime(year,convertMonthFromStringToInt(month), day,hour,minute);
}

int convertMonthFromStringToInt(month){
  switch (month.toLowerCase()) {
    case 'january': return 1;
      break;
    case 'february': return 2;
      break;
    case 'march': return 3;
      break;
    case 'april': return 4;
      break;
    case 'may': return 5;
      break;
    case 'june': return 6;
      break;
    case 'july': return 7;
      break;
    case 'august': return 8;
      break;
    case 'september': return 9;
      break;
    case 'october': return 10;
      break;
    case 'november': return 11;
      break;
    // case 'december': return 12;
    //   break;
    default: return 12;
  }
}

/// appends data if not present else updates that data
List<PostsSort> updateDataInList(List<PostsSort>list,PostsSort data){
  int index = list.indexWhere((test)=>test.id == data.id);
  if(index != -1){
    list[index] = data;
    return list;
  }
  else{
    list.add(data);
    return list;
  }
}

