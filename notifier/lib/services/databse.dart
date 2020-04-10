import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'dart:async';
// import 'package:flutter/material.dart';
import 'package:http/http.dart';
// import 'package:notifier/data/data.dart';
// import 'package:notifier/screens/home/home.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  // print(directory.path);
  return directory.path;
}

Future<File> get _localFile async {
  print('users');
  final path = await _localPath;
  return File('$path' + '/' + 'users' + '.txt');
}

Future<File> get _localFileSNT async {
  final path = await _localPath;
  print('snt');
  return File('$path' + '/' + 'snt' + '.txt');
}

Future<File> get _localFilePeople async {
  print('people');
  final path = await _localPath;
  return File('$path' + '/' + 'people' + '.txt');
}

Future<File> get _localFilePosts async {
  print('posts');
  final path = await _localPath;
  return File('$path' + '/' + 'posts' + '.txt');
}
Future<File> get _localFileDrafts async {
  print('drafts');
  final path = await _localPath;
  return File('$path' + '/' + 'drafts' + '.txt');
}

Future<bool> fileExists(String fileName) async {
  final path = await _localPath;
  final file = File('$path' + '/' + '$fileName' + '.txt');
  return file.exists();
}

Future<File> createFile(String fileName) async {
  try {
    final path = await _localPath;
    final file = File('$path' + '/' + '$fileName' + '.txt');
    return file.create();
  } catch (e) {
    print('error ' + e.toString());
    return null;
  }
}

Future<Map<String, dynamic>> readPeople() async {
  try {
    final file = await _localFilePeople;
    // Read the file
    String content = await file.readAsString();
    // print(content);
    var contents = json.decode(content);
    // Returning the contents of the file
    print(contents.toString());
    return contents;
  } catch (e) {
    print('Error' + e.toString());
    // If encountering an error, return
    return null;
  }
}
Future<List<dynamic>> readContentDrafts(String fileName)async{
  try{
    final file = await _localFileDrafts;
    var contents=  await file.readAsString();
    return await json.decode(contents);

  }
  catch(e){
    print(e);
    return null;
  }
}
Future<Map<String, dynamic>> readContent(String fileName) async {
  try {
    final file = (fileName == 'snt')
        ? await _localFileSNT
        : (fileName == 'posts' ? await _localFilePosts : (fileName == 'drafts' ? await _localFileDrafts :await _localFile));
    // Read the file
    String content = await file.readAsString();
    // print(content);
    var contents = json.decode(content);
    // Returning the contents of the file
    // print(contents.toString());
    return await contents;
  } catch (e) {
    print(e);
    // If encountering an error, return
    return null;
  }
}
Future<bool> writeContentDrafts(var content)async{
  return await fileExists('drafts').then((var v)async{
    if(v){
      final file = await _localFileDrafts;
      var val=  await file.writeAsString(content);
      return val!=null?true:false;
    }else{
       final file = await createFile('drafts');
    var v = file != null ? await file.writeAsString(content) : null;
    return v != null ? true : false;
    }
  });
}
Future<bool> writeContent(String fileName, var contentToWrite) async {
  final existence = await fileExists(fileName);
  // print(existence);

  if (existence) {
    var v;
    switch (fileName) {
      case 'people':
        final file = await _localFilePeople;
        v = await file.writeAsString(contentToWrite);
        break;
      case 'users':
        final file = await _localFile;
        v = await file.writeAsString(contentToWrite);
        break;
      case 'snt':
        final file = await _localFileSNT;
        v = await file.writeAsString(contentToWrite);
        break;
      case 'drafts':
        final file = await _localFileDrafts;
        v = await file.writeAsString(contentToWrite);
        break;
      default:
        final file = await _localFilePosts;
        v = await file.writeAsString(contentToWrite);
        break;
    }
    //  final file = (fileName == ' people' ? await _localFilePeople : (fileName == 'users' ? await _localFile : (await _localFileSNT)));

    return v != null ? true : false;
  } else {
    final file = await createFile(fileName);
    var v = file != null ? await file.writeAsString(contentToWrite) : null;
    return v != null ? true : false;
  }
  // var jsonData = json.encode(contentToWrite);
  // print(jsonData);
}

Future<File> deleteContent(String fileName) async {
  try {
    final exitstence = await fileExists(fileName);

    if (exitstence) {
      print('$fileName' + 'exists');
      final file = ((fileName == 'people')
          ? await _localFilePeople
          : (fileName == 'users'
              ? await _localFile
              : (fileName == 'posts'
                  ? await _localFilePosts
                  : (fileName =='drafts'?
                    await _localFileDrafts:
                    await _localFileSNT))));
      return await file.delete();
    } else {
      return null;
    }
  } catch (e) {
    if (e ==
        '[ERROR:flutter/lib/ui/ui_dart_state.cc(157)] Unhandled Exception: FileSystemException: Cannot delete file, path = \'/data/user/0/com.sntcouncil.notifier/app_flutter/data.json\' (OS Error: No such file or directory, errno = 2') {
      return null;
    }
    print(e);
    return null;
  }
}

var peopleArr;
var jsonData;
final databaseReference = Firestore.instance;
Map<String, dynamic> docById = {};
Future<bool> loadPostsUsers(var _posts) async{
  var j=0;
  for (var i in _posts) {
   await getDocByID(i).then((bool status){
     if(status){
       j++;
     }
   }); 
  }
  if(j==_posts.length && docById.length == _posts.length ){
    return true;
  }else{
    return false;
  }
  
} 


Future<bool> getDocByID(String uid) async {
  // var v;
  return await databaseReference
      .collection('snt')
      .document(uid).get()
      .then((DocumentSnapshot snapshot) {
        docById.update(snapshot.documentID, (v){
          var data = snapshot.data;
              data['timeStamp'] = (data['timeStamp'] as Timestamp).toDate().toIso8601String();
              return data;
          },
            ifAbsent: () {
              var data = snapshot.data;
              data['timeStamp'] = (data['timeStamp'] as Timestamp).toDate().toIso8601String();
              //  data['timeStamp'] = DateFormat('kk:mm dd-MM-yyyy')
              //   .format(DateTime.parse(data['timeStamp'])).toIso8601String();
              return data;
        });
    print(docById);
    return true;
  });
  // return v != null ? true : false;
}

Future<bool> populateUsers(String uid, bool loading) async {
  // bool people = false;
  // databaseReference.collection('users');
  // await databaseReference
  //     .collection('users')
  //     .getDocuments()
  //     .then((QuerySnapshot snapshots) {
  //   snapshots.documents.forEach((f) {
  //     // print(f.data['uid']);
  //     print(uid);
  //     if (f.documentID == uid) {
  //       jsonData = json.encode(f.data);
  //       print('retreieving data fro  internet');
  //       // jsonData = f.data;
  //       // print(f.data);
  //     }
  //   });
  //   print(jsonData.toString() + ' usersData');
  //   return people;
  // });

  // return (jsonData != null)
  //     ? await writeContent('users', jsonData).whenComplete(() {
  //         // readContent('users').then((var v){
  //         //   print(v['id']);
  //         // });
  //         print('done!! users');

  //         loading = false;
  //         people = true;
  //       })
  //     : null;
  return await databaseReference.collection('users').document(uid).get().then((DocumentSnapshot snapshot)async{
    return await writeContent('users', jsonEncode(snapshot.data)).then((var v){
      if(v){
        return true;
      }else{
        return false;
      }
    });
  });
  // return db;
}
// return  await databaseReference.collection('users').document(uid).snapshots().listen((DocumentSnapshot snapshot)async{
//     print(snapshot.data);
//     jsonData = jsonEncode(snapshot.data);
   
//   },onDone: ()async{
//     return await writeContent('users', jsonData);
//   },

//   ).asFuture();

Future<bool> populatePeople(String id) async {
  // bool people =

  return await databaseReference
      .collection('people').document(id).get().then((DocumentSnapshot snapshots) async{
    // snapshots.documents.forEach((f) {
      // if (f.documentID == id) {
        print('retreieving people fro  internet');
        peopleArr = snapshots.data;
        print(snapshots.data);
         return peopleArr != null
      ? await writeContent('people', json.encode(peopleArr))
      : false;
      // }
      // return false;
      // print('doesn\'t need to retreive');
    // });
    // print(peopleArr);
    // print(json.encode(peopleArr));
  });
  
}

Future<bool> updateInFireBase(String uid, var council) async {
  // var error;
  return await databaseReference
      .collection('users')
      .document(uid)
      .updateData({'council': council}).then((_) => true);
}
Future<void> updateNameinFirebase(String uid,String name)async{
  await databaseReference
      .collection('users')
      .document(uid)
      .updateData({'name': name});
}
Future<void> updateRollNoinFirebase(String uid,String rollno)async{
  await databaseReference
      .collection('users')
      .document(uid)
      .updateData({'rollno': rollno});
}
Future<int> submit(String id, var council,var value) async {
  Map<String, String> headers = {"Content-type": "application/json"};
  // value = jsonEncode(value);
  // String json = '{
  //   "id": "$id";
  //   "councils":"$value["councils"]",
  //   "snt":"$value["snt"]","ss":"$value["ss"]","mnc":"$value["mnc"],
  
  // }';
  String jsonDataBody = jsonEncode({
    'id': id,
    'councils':council,
    'snt': value['snt'].length!=0? value['snt'][0]:null,
    'mnc':value['mnc'].length!=0? value['mnc'][0]:null,
    'anc':value['anc'].length!=0? value['anc'][0]:null,
    'ss':value['ss'].length!=0? value['ss'][0]:null,
    'gnc':value['gnc'].length!=0? value['gnc'][0]:null,
  });
  print(jsonDataBody);
  // try{
  String url =
      'https://us-central1-notifier-snt.cloudfunctions.net/elevatePerson';
  // //   // }catch(e){
  // //   //   print(e.toString());
  // //   // }
  try {
    Response response = await post(url, headers: headers, body: json);
    int statusCode = response.statusCode;
    print(statusCode);
    print(response.body.toString());
    return statusCode;
  } catch (e) {
    print(e);
    return 1;
  }
}
