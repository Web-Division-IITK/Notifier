import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
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


/*
Future<bool> p1(Map<String, dynamic> notfication) async {
  var db = Firestore.instance;
  String v;
  return await getStringValuesSF().then((String value) async {
    var error;
    print(value.toString() + ' latTme');

    if (value == '0') {
      return await db
              .collection('snt')
              .getDocuments()
              .then((QuerySnapshot snapshot) async {
        snapshot.documents.forEach((f) {
          print('getting from internet');
          if (notfication.containsKey(f.documentID)) {
            notfication.update(f.documentID, (var v) {
              var v = f.data;
              v['timeStamp'] =
                  (v['timeStamp'] as Timestamp).toDate().toIso8601String();
              //  print(v['timeStamp']);
              return v;
            });
          }
          notfication.putIfAbsent(f.documentID, () {
            var v = f.data;
            v['timeStamp'] =
                (v['timeStamp'] as Timestamp).toDate().toIso8601String();
            return v;
          });
        });
        print('retreieving notfs fro  internet');
        // });
        return error == null && notfication != null
            ? await writeContent('snt', json.encode(notfication))
            : false;
        // print(notfs);
      }).catchError((e) {
        print(e.toString() + ' error while retreieving notfs fro  internet');
        error = 'Error';
        return false;
      }) /*.whenComplete(() {
        // print(notfication);
        // return error == null && notfication != null?  writeContent('snt',json.encode(notfication)).whenComplete(() => v= 'true')  : v = 'Error'; 
      })*/
          ;
    } else {
     return  await db
              .collection('snt')
              .where('timeStamp', isGreaterThanOrEqualTo: DateTime.parse(value))
              .getDocuments()
              .then((QuerySnapshot snapshot) async {
        print('getting from internet with lasttime');
        snapshot.documents.forEach((f) {
          print(f.documentID);
          if (notfication.containsKey(f.documentID)) {
            notfication.update(f.documentID, (var v) {
              var v = f.data;
              v['timeStamp'] =
                  (v['timeStamp'] as Timestamp).toDate().toIso8601String();
              //  print(v['timeStamp']);
              return v;
            });
          }
          notfication.putIfAbsent(f.documentID, () {
            var v = f.data;

            v['timeStamp'] =
                (v['timeStamp'] as Timestamp).toDate().toIso8601String();
            //  print(v['timeStamp']);
            return v;
          });
        });
        return error == null
            ? await writeContent('snt', json.encode(notfication))
            : false;
        // }
        // print(f.data);
        // print('doesn\'t need to retreive notfs');
        //  });
      }).catchError((e) {
        print(e.toString() + ' error while retreieving notfs fro  internet');
        error = 'Error';
        return false;
      }); /*.whenComplete(() {
        // for (var i in post) {
        //   if(notfication.containsKey(i.uid)){
        //     notfication.update(i.uid, i.value);
        //   }
        //   else{
        //     notfication., ifAbsent)
        //   }
        // print(notfication);
        return error == null ?  writeContent('snt',json.encode(notfication)).whenComplete(() => v= 'true')  : v = 'Error'; 
        
        
      })*/
          // ;
    }
    // return v;
  }).catchError((var e) {
    print(e);
     v = 'Error';
     return false;
  });
  // print(getDoc);

  /*return getDoc != 'Error'?await writeContent('snt', json.encode(notfication))/*.whenComplete((){
    readContent('snt').then((var value){
      // print(value);
      // var v = value['timeStamp'];
      
      
      value.keys.forEach((key){
        // if(timenots.containsKey(DateTime.parse(value[key]['timeStamp'].toString()))){
        //    timenots.update(DateTime.parse(value[key]['timeStamp'].toString()), (var v) {
        //    var v = value[key];
        //   //  v['timeStamp'] = (v['timeStamp'] as Timestamp).toDate().toIso8601String();
        //   //  print(v['timeStamp']);
        //    return v;
        //  } );
        //  }
        //  timenots.putIfAbsent(DateTime.parse(value[key]['timeStamp'].toString()), () {
        //    var v = value[key];
           
        //   //  v['timeStamp'] = (v['timeStamp'] as Timestamp).toDate().toIso8601String();
        //   //  print(v['timeStamp']);
        //    return v;
        //  });
        // v = value[key]
       var v= DateTime.parse('2020-03-23T17:26:56.295')  ;
        if(v.compareTo(DateTime.parse(value[key]['timeStamp'].toString() )) > 0 ){
          // print((value[key]['timeStamp']).toString() + 'timeStamp');
        }
        
        if(value.containsKey(key)){
          if(value[key]['exists'] == false){
            print(value[key]);
            value.remove(key);
          }
        }
        // timenots = value;
      });
    });
  })*/:false;*/
}*/
//  2020-03-23T17:26:18.261timeStamp
// I/flutter (28706): 2020-03-23T17:26:52.087timeStamp
// I/flutter (28706): 2020-03-23T17:26:56.295timeStamp
// I/flutter (28706): 2020-03-23T17:26:58.423timeStamp
// I/flutter (28706): 2020-03-23T17:27:00.400timeStamp
