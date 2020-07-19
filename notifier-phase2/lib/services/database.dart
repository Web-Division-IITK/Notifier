import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/model/hive_models/hive_model.dart';
import 'package:notifier/model/hive_models/people_hive.dart';
import 'package:notifier/model/posts.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifier/services/functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


Future<File> file(String filename) async {
  Directory dir = await getApplicationDocumentsDirectory();
  String pathName = join(dir.path, filename);
  return File(pathName);
}
class DBProvider {
  final String databaseName = 'posts';
  // DBProvider();
  // static final DBProvider db = DBProvider();
  
  static Database _database;

  Future<Database> get database async {
    if (_database != null){
      return _database;
    }

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }
  deleteData()async{
     try {
       Directory documentsDirectory = await getApplicationDocumentsDirectory();
        var exists;
        print( exists = await databaseExists(join(documentsDirectory.path,databaseName,'.db')));
        return await deleteDatabase(join(documentsDirectory.path,databaseName,'.db')).then((_)async{
          _database = null;
          if(exists !=  await databaseExists(join(documentsDirectory.path,databaseName,'.db'))){
            return true;
          }else{
            return false;
          }
        });
     } catch (e) {
       print(e);
     }
    
    // db.close();
  }
  Future<Database> initDB()async{
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path,databaseName,'.db');
      // String data;
      // switch (path) {
      //   case 'posts':
      //     data = "CREATE TABLE Posts("
      //         "id TEXT PRIMARY KEY,"
      //         "council TEXT,"
      //         "owner TEXT,"
      //         "sub TEXT,"
      //         "tags TEXT,"
      //         "timeStamp INTEGER,"
      //         "title TEXT,"
      //         "message TEXT,"
      //         "body TEXT,"
      //         "author TEXT,"
      //         "url TEXT,"
      //       ")";
      //     break;
      //   default: data = "CREATE TABLE User("
      //         "id TEXT PRIMARY KEY,"
      //         "uid TEXT,"
      //         "name TEXT,"
      //         "rollno INTEGER,"
      //         "admin INTEGER,"
      //         "email TEXT,"
      //       ")";
      // }
      return await openDatabase(
        path,version:1,
        onCreate: (db,version)async{
          return  db.execute("""CREATE TABLE Posts 
          (id TEXT PRIMARY KEY,bookmark INTEGER,
          council TEXT,sub TEXT,
          type TEXT,owner TEXT,
          tags TEXT,timeStamp INTEGER,
          title TEXT,message TEXT,
          startTime INTEGER,
          reminder INTEGER,
          endTime INTEGER,
          body TEXT,author TEXT,
          url TEXT)""",);
        }
      );
    } catch (e) {
      print(e);
      return null ;
    }
    
  }

  /// this functionn returns 1,0 and null
  newPost(Posts newPosts) async{
    final db = await database;
    try{
      return await db.insert('Posts',newPosts.toMapData(),conflictAlgorithm: ConflictAlgorithm.replace);
    }
    catch(e){
      print(e);
      return null;
    }
    // var raw= await db.rawInsert(
    //   "INSERT INTO Posts (id,council,owner,tags,timeStamp,title,message,body,author,url)"
    //   " VALUES ('${newPosts.id}',${newPosts.council},${newPosts.owner},${newPosts.tags},${newPosts.timeStamp},${newPosts.title},${newPosts.message},${newPosts.body},'${newPosts.author}',${newPosts.url})"
    // );
    // return raw;
  }

  Future<PostsSort>getPosts(GetPosts query) async{
    final db = await database;
    var res = await db.query("Posts",where: "${query.queryColumn} = ?",whereArgs: [query.queryData]);
    // printPosts(Posts.fromMap(res.first));
    return res.isNotEmpty ? PostsSort.fromMap(res.first):Null;

  }
  /// return null when exception occurs
  Future<List<PostsSort>>getAllPosts({ orderBy}) async{
    try{
      final db = await database;
      var res = await db.query("Posts",orderBy: "timeStamp DESC");
      List<PostsSort> v = [];
      // print(res);
      // Map<String,PostsSort> list = {};
      // if(res.isNotEmpty) {
      //   res.forEach((f){
      //   list.update(f['id'], (_)=>PostsSort.fromMap(f),ifAbsent: ()=>PostsSort.fromMap(f));
      // });
      // }
      if(res.isNotEmpty){
      //   res.forEach((value){
      //   v.add(PostsSort.fromMap(value));
      // });
      // }
        return v..addAll( res.map((f) => PostsSort.fromMap(f)));
      }
      else{
        return [];
      }
      // print(list);
      // return res.isNotEmpty?list:null;
    }
    catch(e){
      print(e);
      return [];
    }
  }
  Future<List<PostsSort>> getAllPostswithQuery(GetPosts query,{orderBy = "timeStamp",type = 'update'})async{
    try {
      final db= await database;
      List<Map<String,dynamic>> res;
      switch (type) {
        case 'update':
          res = await db.query("Posts",where: "${query.queryColumn} = ? AND owner = ?",whereArgs: [query.queryData,query.id],orderBy:orderBy );
      //     List<PostsSort> v = [];
      //   if(res.isNotEmpty){
      // //   res.forEach((value){
      // //   v.add(PostsSort.fromMap(value));
      // // });
      // // }
      //   return v..addAll(res.map((f) => PostsSort.fromMap(f)));
      // }
          break;
        default: res = await db.query("Posts",where: "${query.queryColumn} = ?",whereArgs: [query.queryData],orderBy:orderBy );
        // List<PostsSort> v = [];
      //   if(res.isNotEmpty){
      // //   res.forEach((value){
      // //   v.add(PostsSort.fromMap(value));
      // // });
      // // }
      //   return v..addAll(res.map((f) => PostsSort.fromMap(f)));
      // }
        break;
      }
      
      // Map<String,PostsSort> list = {};
      // if(res.isNotEmpty) {
        // print('res $res');
      //   res.forEach((f){
      //   list.update(f['id'], (_)=>PostsSort.fromMap(f),ifAbsent: ()=>PostsSort.fromMap(f));
      // });
      // }
      List<PostsSort> v = [];
        if(res.isNotEmpty){
      //   res.forEach((value){
      //   v.add(PostsSort.fromMap(value));
      // });
      // }
        return v..addAll(res.map((f) => PostsSort.fromMap(f)));
      }
      else{
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<PostsSort>> getPostInPrefs(GetPosts query)async{
    try {
      final db = await database;
      // var res = await db.query('Posts',where: "sub=ANY?x",whereArgs: prefs.getRange(0, 10).toList());
      var res = await db.rawQuery(
        "SELECT * FROM Posts WHERE council = ? ? ORDER",[query.queryData,query.id]
      );
      print(res);
      List<PostsSort> v = [];
        if(res.isNotEmpty){
        return v..addAll( res.map((f) => PostsSort.fromMap(f)));
        }else{
          return  [];
        }
    } catch (e) {
      print(e);
      return [];
    }
  }
  //id is necessary
  updateQuery(GetPosts query)async{
    try {
      final db= await database;
      var res = await db.rawUpdate(
        '''UPDATE Posts
        SET ${query.queryColumn} = ?
        WHERE id = ?
        ''',
        [query.queryData,query.id]
      );
    } catch (e) {
      print(e);
    }
  }

  updatePosts(Posts newPosts)async{
    try {
      final db= await database;
      var res= await db.update("Posts",newPosts.toMap(),where:"id = ?",whereArgs: [newPosts.id],conflictAlgorithm: ConflictAlgorithm.replace);
      return res;
    } catch (e) {
      print(e);
    }
  }
  deletePost(String id) async{
    final db = await database;
    try {
      db.delete("Posts",where:"id = ?",whereArgs: [id]);
    } catch (e) {
      return 0;
    }
  }
  deleteAllPosts() async{
    try {
      final db = await database;
      db.rawDelete("Delete * from Posts");
    } catch (e) {
      print(e);
    }
  }
}

// Future<bool> writeContentDrafts(var content)async{
//   return await fileExists('drafts').then((var v)async{
//     if(v){
//       final file = await _localFileDrafts;
//       var val=  await file.writeAsString(content);
//     // Dat
//       // file.openWrite(
//       //   mode: FileMode.write
//       // ).write(obj);
//       return val!=null?true:false;
//     }else{
//        final file = await createFile('drafts');
//     var v = file != null ? await file.writeAsString(content) : null;
//     return v != null ? true : false;
//     }
//   });
// }
// Future<bool> writeContent(String fileName, var contentToWrite) async {
//   final existence = await fileExists(fileName);
//   // print(existence);

//   if (existence) {
//     var v;
//     switch (fileName) {
//       case 'people':
//         final file = await _localFilePeople;
//         v = await file.writeAsString(contentToWrite);
//         break;
//       // case '':
//       //   final file = await _localFileNots;
//       //   v= await file.writeAsString(contentToWrite);
//       //   break;
//       case 'users':
//         final file = await _localFile;
//         v = await file.writeAsString(contentToWrite);
//         break;
//       case 'allPosts':
//         final file = await _localFileAllPosts;
//         v = await file.writeAsString(contentToWrite);
//         break;
//       case 'drafts':
//         final file = await _localFileDrafts;
//         v = await file.writeAsString(contentToWrite);
//         break;
//       case 'allData':
//         final file = await _localFileAllData;
//         v = await file.writeAsString(contentToWrite);
//         break;
//       default:
//         final file = await _localFilePosts;
//         v = await file.writeAsString(contentToWrite);
//         break;
//     }
//     //  final file = (fileName == ' people' ? await _localFilePeople : (fileName == 'users' ? await _localFile : (await _localFileSNT)));

//     return v != null ? true : false;
//   } else {
//     final file = await createFile(fileName);
//     var v = file != null ? await file.writeAsString(contentToWrite) : null;
//     return v != null ? true : false;
//   }
//   // var jsonData = json.encode(contentToWrite);
//   // print(jsonData);
// }
// /// return [null]( when an error has occured
// /// ) or  with a [file ](if fileexists and deletion is successful or with [false] (if file doesnt exists))
// Future<dynamic> deleteContent(String fileName) async {
//   try {
//     final exitstence = await fileExists(fileName);

//     if (exitstence) {
//       print('$fileName' + 'exists');
//       final file = ((fileName == 'people')
//           ? await _localFilePeople
//           : (fileName == 'users'
//               ? await _localFile
//               : (fileName == 'posts'
//                   ? await _localFilePosts
//                   : (fileName =='drafts'?
//                     await _localFileDrafts:
//                     (fileName == 'allPosts' ?
//                     await _localFileAllPosts:
//                     await _localFileAllData)))));
//       return await file.delete();
//     } else {
//       return false;
//     }
//   } catch (e) {
//     if (e ==
//         '[ERROR:flutter/lib/ui/ui_dart_state.cc(157)] Unhandled Exception: FileSystemException: Cannot delete file, path = \'/data/user/0/com.sntcouncil.notifier/app_flutter/data.json\' (OS Error: No such file or directory, errno = 2') {
//       return null;
//     }
//     print(e);
//     return null;
//   }
// }
final databaseReference = Firestore.instance;
Future<bool> populateUsers(String uid) async{
  return await databaseReference.collection('users').document(uid).get().then((snapshot)async{
    Box userData;
    userData = await HiveDatabaseUser().hiveBox;
     if(snapshot.data == null || snapshot.data==null){
        return false;
      }else{
        try {
          print(snapshot.data);
          print(snapshot.data['id']);
          var data = snapshot.data['council'];
          var prefs = [];
          data.forEach((key,value){
            prefs += value['entity'] + value['misc'];
          });
          // return await writeContent('users', json.encode(snaphot.data));
          UserModel user= UserModel(
            id: snapshot.data['id'],
            name: snapshot.data['name'],
            rollno: snapshot.data['rollno'],
            uid: snapshot.data['uid'],
            prefs: prefs.cast<String>(),
            admin: snapshot.data['admin'],
          );
          userData.add(user);
          return true;
        } catch (e) {
          print(e);
          return false;
        }
      }
  }).catchError((onError){
      print('error in populateUsers ' '$onError ');
      return false;
    });
}
/// returns are false null and true
Future<dynamic> populateAppData(String uid) async{
  Box userData;
    userData = await HiveDatabaseUser().hiveBox;
  return await populateUsers(uid).then((status)async{
    if(status == true){
      return await p1('5',owner:userData.toMap()[0].id);
    }else{
      return false;
    }
  });
  // return await databaseReference.collection('posts').document('council').get().then((var value){
  //     if(value.data!=null){
  //       return loadAllPosts(value.data);
  //     }else if(value.data == null){
  //       return null;
  //     }else{
  //       return  false;
  //     }
  //   }).catchError((var e){
  //     print('line245 of database.dart' + '$e');
  //     return false;
  //   });
  
}

Future<bool> populatePeople(String id)async{
  return await databaseReference.collection('people').document('$id').get().then((var value)async{
    if(value !=null && value.data!=null){
      Box box = await HiveDatabaseUser(databaseName: 'people').hiveBox;
      PeopleModel model = PeopleModel.fromMap(value.data);
      print(model.councils);
      box.add(model);
      return true;
    }else{
      return false;
    }
    // return await writeContent('people',json.encode(value.data)).then((status){
    //   if(status){
    //     return People(value.data, status);
    //   }else{
    //     return People(value.data, status);
    //   }
    // });
  }).catchError((onError){
    print(onError);
    return false;
  });
}

Future<bool> updateUserDataInFirebase(String uid,dynamic type,dynamic data)async{
   return await databaseReference.collection('users').document(uid).updateData({'$type': data}).then((_){
    return true;
  }).catchError((var e){
    print('Error in updateusersdata:' + e.toString());
    return false;
  });
}
Future<bool> updatePrefsInFirebase(String uid,dynamic data)async{
   return await databaseReference.collection('users').document(uid).updateData({'council': data}).then((_){
    return true;
  }).catchError((var e){
    print('Error in prefsusersdata:' + e.toString());
    return false;
  });
}
final FirebaseMessaging _fcm = FirebaseMessaging();
void subscribeUnsubsTopic(var subscribe, var unsubscribe) {
 
  for (var i in unsubscribe) {
    if(i!=null && i!= ""){
    _fcm.unsubscribeFromTopic(checkSpace(i).toString());
    }
  }
  for (var i in subscribe) {
    
    if(i!=null && i!= ""){
      _fcm.subscribeToTopic(checkSpace(i).toString());
    }
  }
}
checkSpace(String name) {
  name = name.replaceAll("\'", '');
  return name.replaceAll(' ', '_');
}
Future<int> submit(String id, var council,var value) async {
  Map<String, String> headers = {"Content-type": "application/json"};
  // value = json.encode(value);
  // String json = '{
  //   "id": "$id";
  //   "councils":"$value["councils"]",
  //   "snt":"$value["snt"]","ss":"$value["ss"]","mnc":"$value["mnc"],
  
  // }';
  String jsonDataBody = json.encode({
    'id': id,
    'council':council,
    'por':value,
  });
  print(jsonDataBody);
  // try{
  String url =
      'https://us-central1-notifier-phase-2.cloudfunctions.net/elevatePerson';
  // //   // }catch(e){
  // //   //   print(e.toString());
  // //   // }
  try {
    Response response = await post(url, headers: headers, body: jsonDataBody);
    int statusCode = response.statusCode;
    print(statusCode);
    print(response.body.toString());
    return statusCode;
  } catch (e) {
    print(e);
    return 1;
  }
}