import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/screens/home.dart';
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
createTagsToList(String tags){
  return tags.split(';');
}
Future<bool> procedure() async {
  // var notfs = List();
  Map<String, dynamic> notfication = {};
  return await fileExists('snt').then((bool sntExists)async{
    print(sntExists.toString() + 'sntExists line62 of function.dart');
  if (!sntExists) {
    return await p1(notfication);
  } else {
    return await readContent('snt').then((var value) async {
      if (value != null) {
        notfication = value;
        print('value exists of snt line69 function.dart:' + notfication.toString());
        return await p1(notfication);
      } else {
        return await p1(notfication);
      }
    });
  }
  });
  
}
Future<bool>p1(Map<String,dynamic> notification) async{
  var db = Firestore.instance;
  return await getStringValuesSF().then((String lastTime)async{
    print(lastTime.toString() + 'lasttime line81 funtion.dart');
    if(lastTime == '0'){
      return await db.collection('snt').getDocuments().then((QuerySnapshot snapshot)async{
        snapshot.documents.forEach((f){
          notification.putIfAbsent(f.documentID, (){
            var data = f.data;
            data['timeStamp'] = (data['timeStamp'] as Timestamp).toDate().toIso8601String();
            return data;
          });
        });
        print( 'line92 function.dart'+ notification.toString());
        return notification.length == snapshot.documents.length ? 
        await writeContent('snt', json.encode(notification)):null;
      });
    }
    else{
      return db.collection('snt').where('timeStamp', isGreaterThanOrEqualTo: DateTime.parse(lastTime)).getDocuments().then((QuerySnapshot snapshot) async{
        // snapshot.documents.reversed
        snapshot.documents.forEach((f){
            notification.update(f.documentID, (v){
              var data = f.data;
              data['timeStamp'] = (data['timeStamp'] as Timestamp).toDate().toIso8601String();
              return data;
            },
            ifAbsent: () {
              var data = f.data;
              data['timeStamp'] = (data['timeStamp'] as Timestamp).toDate().toIso8601String();
              //  data['timeStamp'] = DateFormat('kk:mm dd-MM-yyyy')
              //   .format(DateTime.parse(data['timeStamp'])).toIso8601String();
              return data;
            }
            );
            
          // }
        });
        print( 'line115 function.dart'+ notification.toString());
        print( 'line116 function.dart'+ notification.length.toString());
        print( 'line116 function.dart'+ snapshot.documents.length.toString());
        return notification!=null ? await writeContent('snt', json.encode(notification)):null;
      });
    }
  });
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
  String url = 'https://us-central1-notifier-snt.cloudfunctions.net/makePost';
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