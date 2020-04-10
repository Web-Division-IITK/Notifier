import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/services/databse.dart';
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

createTagsToList(String tags) {
  return tags.split(';');
}

proc() async{
  var val;
  var db = Firestore.instance;
 return await  db.collection('users').getDocuments().then((var v){
    
    Future.delayed(Duration(seconds: 4), () => (val = v.documents));
    
    return val;
  });
// yield val;
}


Future<bool> procedure() async {
  // var notfs = List();
  Map<String, dynamic> notfication = {};
  return await fileExists('snt').then((bool sntExists) async {
    print(sntExists.toString() + 'sntExists line62 of function.dart');
    if (!sntExists) {
      return await p1(notfication);
    } else {
      return await readContent('snt').then((var value) async {
        if (value != null) {
          notfication = value;
          print('value exists of snt line69 function.dart:' +
              notfication.toString());
          return await p1(notfication);
        } else {
          return await p1(notfication);
        }
      });
    }
  });
}

Future<bool> p1(Map<String, dynamic> notification) async {
  var db = Firestore.instance;
  return await getStringValuesSF().then((String lastTime) async {
    print(lastTime.toString() + 'lasttime line81 funtion.dart');
    if (lastTime == '0') {
      return await db
          .collection('snt').orderBy('timeStamp',descending: true)
          .getDocuments()
          .then((QuerySnapshot snapshot) async {
            // List<SortDateTime> array =[];
        snapshot.documents.forEach((f) {
          if(f.data['exists']!=null && f.data['exists']){
            // array.add(SortDateTime(f.documentID,(f.data['timeStamp'] as Timestamp).toDate().millisecondsSinceEpoch , f.data,null,null));
            notification.update(f.documentID, (v) {
              var data = f.data;
              // data['timeStamp'] = 
              data.update('opened', (_)=> true, ifAbsent: ()=> true);
              data['timeStamp'] =
                  (data['timeStamp'] as Timestamp).toDate().toIso8601String();

              return data;
            },
          ifAbsent: (){
            var data = f.data;
            data.update('opened', (_)=> true, ifAbsent: ()=> true);
            data['timeStamp'] =
                  (data['timeStamp'] as Timestamp).toDate().toIso8601String();

              return data;
          }
            );
            
          }
        });
        // return await sortingArray(array, notification).then((notification)async{
        //   print('line92 function.dart' + notification.toString());
        //   return notification.length == snapshot.documents.length
        //     ? await writeContent('snt', json.encode(notification))
        //     : null;
        // });
        print('\"\"\"line92 function.dart specially now\"\"\"' + notification.toString());
        return notification!=null ? await writeContent('snt', json.encode(notification))
            : null;
      });
    } else {
      return await db.collection('snt')
          .where('timeStamp', isGreaterThanOrEqualTo: DateTime.parse(lastTime)).orderBy('timeStamp',descending: true)
          .getDocuments()
          .then((QuerySnapshot snapshot) async {
        // snapshot.documents.reversed
        // List<SortDateTime> array =[];
        snapshot.documents.forEach((f) {
          // array.add(SortDateTime(
          //   f.documentID,(f.data['timeStamp'] as Timestamp).toDate().millisecondsSinceEpoch,
          //   f.data,null,null
          // ));
           if(f.data['exists']!=null && f.data['exists']){
          notification.update(f.documentID, (v) {
            var data = f.data;
            data.update('opened', (_)=> true, ifAbsent: ()=> true);
            data['timeStamp'] =
                (data['timeStamp'] as Timestamp).toDate().toIso8601String();
            return data;
          }, ifAbsent: () {
            var data = f.data;
            data.update('opened', (_)=> true, ifAbsent: ()=> true);
            data['timeStamp'] =
                (data['timeStamp'] as Timestamp).toDate().toIso8601String();
            //  data['timeStamp'] = DateFormat('kk:mm dd-MM-yyyy')
            //   .format(DateTime.parse(data['timeStamp'])).toIso8601String();
            return data;
          });

          }else if(f.data['exists']!=null && !f.data['exists']){
            if(notification.containsKey(f.documentID)){
              notification.remove(f.documentID);
            }
          }
        });
        // return await sortingArray(array, notification).then((notification) async{
        //   print('line115 function.dart' + notification.toString());
        //   print('line116 function.dart' + notification.length.toString());
        //   print('line116 function.dart' + snapshot.documents.length.toString());
        //   return notification != null
        //       ? await writeContent('snt', json.encode(notification))
        //       : null;
        // });
        print('line115 function.dart' + notification.toString());
        print('line116 function.dart' + notification.length.toString());
        print('line116 function.dart' + snapshot.documents.length.toString());
        return notification != null
            ? await writeContent('snt', json.encode(notification))
            : null;
      });
    }
  });
}
Future<Map<String,dynamic>>sortingArray(List<SortDateTime> array,Map<String,dynamic>notification) async{
  // array.iterator.current.date.sort();
  array.sort((a,b)=> b.date.compareTo(a.date));
  // for (var i = 0; i < array.length; i++) {
  //     for (var j = i + 1; j < array.length; j++) {
  //       if (array[i].uid == array[j].uid) {
  //         // array[j].value = array[i].value;
  //         array.remove(array[j]);
  //         continue;
  //       }
  //       // print('\'diff:' + array[i].value.toString());
  //       if (array[i].date < array[j].date) {
  //         SortDateTime temp = array[i];
  //         array[i] = array[j];
  //         array[j] = temp;
  //         temp = null;
  //       }
  //     }
  //   }
    for (var i in array) {
      notification.update(i.uid, (v) {
              var data = i.value;
              // data['timeStamp'] = 
              data['timeStamp'] =
                  (data['timeStamp'] as Timestamp).toDate().toIso8601String();

              return data;
            },
          ifAbsent: (){
            var data = i.value;
            data['timeStamp'] =
                  (data['timeStamp'] as Timestamp).toDate().toIso8601String();

              return data;
          }
            );
    }
    return notification;
    
}
Future<Res> createPostForNotifs(
  String _title,
  String _body,
  List<dynamic> tags,
  // String _subtitile,
  String _id,
  String _url,
  String _council,
  String _author,
  String _message,
  List<dynamic> _subs,
) async {
  Map<String, String> headers = {"Content-type": "application/json"};
  // value = jsonEncode(value);
  var value = jsonEncode({
    'title': _title,
    'tags': tags,
    'council': _council.toLowerCase(),
    'sub': _subs,
    'body': _body,
    'author': _author,
    'url': _url,
    'owner': _id,
    'message': _message,
  });
  print(value);
  String json = '$value';
  String url =
      'https://us-central1-notifier-phase-2.cloudfunctions.net/makePost';
  try {
    Response response = await post(url, headers: headers, body: json);
    int statusCode = response.statusCode;
    print(statusCode);
    print(response.body.toString());
    var value = jsonEncode({
      'title': _title,
      'tags': tags,
      'council': _council,
      'sub': _subs,
      'body': _body,
      'author': _author,
      'url': _url,
      'owner': _id,
      'message': _message,
      'exists': true,
      'timeStamp': DateTime.now().toIso8601String(),
      'uid': response.body.toString(),
    });
    return Res(
        uid: response.body.toString(),
        statusCode: statusCode,
        value: jsonDecode(value));
  } catch (e) {
    print(e);
    return null;
  }
}

Future<dynamic> allData() async {
  final HttpClient _httpClient = HttpClient();
  var jsonResponse;
  try {
    final uri = Uri.http('notifier-phase-2.firebaseapp.com',
        '/home'); //TODO: replace index.htmlwithcorrect path
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
  await writeContent('allData', jsonEncode(jsonResponse));
  return jsonResponse;
}

Future<Councils> councilData() async {
  return await fileExists('allData').then((var status) async {
    if (status) {
      return await readContent('allData').then((var data) async {
        if (data == null) {
          return await allData().then((var data) async {
            try {
              if (data != null) {
                Councils myData;

                myData = Councils(
            globalCouncils : data['councils'].cast<String>(),
          level3 : data['level3'].cast<String>(),
          subCouncil: [],
          coordOfCouncil: [],
          );
          for (var i in data['councils']) {
  
            myData.subCouncil.insert(data['councils'].indexOf(i),
              SubCouncil(
                council: i.toString(),

                entity: data[i]['entity'].cast<String>(),
                level2: data[i]['level2'].cast<String>(),
                misc: data[i]['misc'].cast<String>(),
                coordiOfInCouncil: [],
                select: [],

            ));
          }
                return myData;
              } else {
                return null;
              }
            } catch (e) {
              print(e);
              Fluttertoast.showToast(msg: e.message.toString());
              return null;
            }
          });
        } else {
          Councils myData;
          // myData = Councils(globalCouncils: data)
          print(data['councils']);
          myData = Councils(
            globalCouncils : data['councils'].cast<String>(),
          level3 : data['level3'].cast<String>(),
          subCouncil: [],
          coordOfCouncil: [],
          );
          for (var i in data['councils']) {
  
            myData.subCouncil.insert(data['councils'].indexOf(i),
              SubCouncil(
                council: i.toString(),

                entity: data[i]['entity'].cast<String>(),
                level2: data[i]['level2'].cast<String>(),
                misc: data[i]['misc'].cast<String>(),
                coordiOfInCouncil: [],
                select: [],
            ));
          }
          return myData;
        }
      });
    } else {
      return await allData().then((var data) async {
        try {
          if (data != null) {
            Councils myData;
           myData = Councils(
            globalCouncils : data['councils'].cast<String>(),
          level3 : data['level3'].cast<String>(),
          coordOfCouncil: [],
          subCouncil: [],
          );
          for (var i in data['councils']) {
            
            myData.subCouncil.insert(data['councils'].indexOf(i),
              SubCouncil(
                council: i.toString(),

                entity: data[i]['entity'].cast<String>(),
                level2: data[i]['level2'].cast<String>(),
                misc: data[i]['misc'].cast<String>(),
                coordiOfInCouncil: [],
                select: List(data[i]['entity'].length)
            ));
          }
            return myData;
          } else {
            return null;
          }
        } catch (e) {
          print(e);
          Fluttertoast.showToast(msg: e.message.toString());
          return null;
        }
      });
    }
  });
}
String convertFromCouncilName(String name){
  switch(name){
    case 'SnT': return 'snt';
      break;
    case 'SS': return 'ss';
      break;
    case 'MnC': return 'mnc';
      break;
    case 'AnC': return 'anc';
      break;
    case 'GnS': return 'gnS';
      break;
    default: return name;
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
    case 'anc': return 'AnC';
      break;
    case 'gns': return 'GnS';
      break;
    default: return council;
  }
}

String checkTime(DateTime postTime) {
  if(DateTime.now().day == postTime.day){
    if(DateTime.now().month == postTime.month){
      if(DateTime.now().year == postTime.year){
        return 'Today';
      }else{
        return DateFormat('d MMMM, yyyy').format(postTime);
      }
    }else{
      return DateFormat('d MMMM, yyyy').format(postTime);
    }
  }
  else{
    if((DateTime.now().day - 1) == postTime.day){
      if(DateTime.now().month == postTime.month){
        if(DateTime.now().year == postTime.year){
          return 'Yesterday';
        }else{
          return DateFormat('d MMMM, yyyy').format(postTime);
        }
      }else{
        return DateFormat('d MMMM, yyyy').format(postTime);
      }
    }
    else if((DateTime.now().day -1 )!=0){
      return DateFormat('d MMMM, yyyy').format(postTime);
    }
    else if((DateTime.now().day - 1) == 0){
      // var month  = postTime.month;
      // var nowMonth = (DateTime.now().month - 1)!=0 ? (DateTime.now().month - 1):12;
      // if((nowMonth == month) ){
      //   if(nowMonth)
      // }
      if(DateTime.now().year == postTime.year){
        if((DateTime.now().month -1) == postTime.month){
          if(lastDayofMonth(DateTime.now().month -1, DateTime.now().year) == postTime.day){
            return 'Yesterday';
          }
          else{
            return DateFormat('d MMMM, yyyy').format(postTime);
          }
        }else{
          return DateFormat('d MMMM, yyyy').format(postTime);
        }
      }else if((DateTime.now().year - 1) == postTime.year){
        if(DateTime.now().month == 1 && postTime.month == 12){
          if(postTime.day == 31){
            return "Yesterday";
          }
          else{
          return DateFormat('d MMMM, yyyy').format(postTime);
        }
        }else{
          return DateFormat('d MMMM, yyyy').format(postTime);
        }
      }
      else{
          return DateFormat('d MMMM, yyyy').format(postTime);
        }
    }
    else{
          return DateFormat('d MMMM, yyyy').format(postTime);
        }
  }
}
checkLeapYear(int year){
  if(year%400 == 0){
    // if(year%100)
    return true;
  }
  if(year%100 ==0){
    return false;
  }
  if(year%4 == 0){
    return true;
  }
  return false;
}
lastDayofMonth(int month,int year){
  switch (month) {
    case 2: return checkLeapYear(year) ? 29:28;
      break;
      
    case 3:return 31;
      
      break;case 4:return 30;
      
      break;case 5:return 31;
      
      break;case 6:return 30;
      
      break;case 7:return 31;
      
      break;case 8:return 31;
      
      break;case 9:return 30;
      
      break;case 10:return 31;
      
      break;case 11:return 30;
      
      break;case 12:return 31;
      
      break;
    default:
  }
}

changeTime(time,day,postTime){
  // var arr =[];
  if (DateTime.now().day == postTime.day && DateTime.now().month == postTime.month && DateTime.now().year == postTime.year) {
                if (DateTime.now().hour == postTime.hour ||
                    (DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) < 3600000) {
                  switch (DateTime.now().minute - postTime.minute) {
                    case 0:
                      time = 'now';
                      day = 'Today';
                      return [time,day];
                      break;
                    default:
                      var i = ((DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) /60000)
                          .round();
                      time = '$i minutes ago';
                      day = 'Today';
                      return [time,day];
                  }
                } else {
                  time = 'Today, ' + DateFormat('kk:mm').format(postTime);
                  day = 'Today';
                  return [time,day];
                }
              } else {
                time = DateFormat('d MMMM, yyyy : kk:mm').format(postTime);
                day = DateFormat('d MMMM, yyyy').format(postTime);
                return [time,day];
              }
}