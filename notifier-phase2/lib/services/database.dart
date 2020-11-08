import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/model/hive_models/hive_model.dart';
import 'package:notifier/model/hive_models/people_hive.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home.dart';
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
  static const String tableName = 'Posts';
  static Database _database;

  Future<Database> get database async {
    if (_database != null){
      return _database;
    }
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
          isFeatured INTEGER,
          body TEXT,author TEXT,
          isFetched INTEGER,
          url TEXT)""",);
        }
      );
    } catch (e) {
      print(e);
      return null ;
    }
    
  }

  /// this functionn returns 1,0 and null
  insertPost(Posts newPosts) async{
    final db = await database;
    try{
      return await db.insert('Posts',newPosts.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    }
    catch(e){
      print(e);
      return null;
    }
  }

  Future<Posts>getPosts(GetPosts query) async{
    try{
      final db = await database;
    var res = await db.query("Posts",where: "${query.queryColumn} = ?",whereArgs: [query.queryData]);
    print("...POSTS WITH ID.... " + res.toString());
    return res.isNotEmpty ? Posts.fromMap(res.first): Posts(isFetched: false);
    }catch(e){
      print(e);
      return Posts(isFetched: false);
    }

  }
  /// return null when exception occurs
  // Future<List<Posts>>getAllPosts({ orderBy}) async{
  //   try{
  //     final db = await database;
  //     var res = await db.query("Posts",orderBy: "timeStamp DESC");
  //     List<Posts> v = [];
  //     if(res.isNotEmpty){
  //       return v..addAll( res.map((f) => Posts.fromMap(f)));
  //     }
  //     else{
  //       return [];
  //     }
  //   }
  //   catch(e){
  //     print(e);
  //     return [];
  //   }
  // }

  /// return List<Posts> if isfeatured == 0 & Map<String,List<Posts>> if isFeatured == 1
  Future<List<Posts>>getAllPostsWithoutPermissions(
    {int isFeatured = 0,bool map = false, String council = "snt"}
  ) async{
    try{
      print(council);
      final db = await database;
      var res = isFeatured == 0 && map == false ?
      await db.query("Posts",where: "$TYPE = ? AND $IS_FEATURED = ?",
        whereArgs: [NOTF_TYPE_CREATE, isFeatured], orderBy: "timeStamp DESC")
     : await db.query("Posts", where: " $TYPE = ? AND $IS_FEATURED = ? AND $COUNCIL = ?",
        whereArgs: [NOTF_TYPE_CREATE, isFeatured,council], orderBy: "timeStamp DESC") ;
      
      List<Posts> v = [];
      Map<String,List<Posts>> postMap = {};
      postMap = Map.fromIterables(allCouncilData.subCouncil.keys, 
        Iterable.generate(allCouncilData.subCouncil.keys.length, (v)=>[]));
      // print(res);
      if(res.isNotEmpty){
        // if(isFeatured == 1 || map == true){
        //   res.forEach((post){
        //     postMap.update(post[COUNCIL], (value){
        //       if(value == null || value.isEmpty)
        //         return [Posts.fromMap(post)];
        //       value.add(Posts.fromMap(post));
        //       return value;
        //     },ifAbsent: () =>[Posts.fromMap(post)]);
        //   });
        //   return postMap;
        // }
        return v..addAll( res.map((f) => Posts.fromMap(f)));
      }
      else{
        return  [];
      }
    }
    catch(e){
      print("..... ERROR WHILE RETREIVING POSTS WITHOUT PERMISSION .....");
      print(e);
      return [];
    }
  }
  
  // Future<List<Posts>> getAllPostswithDate(DateTime date)async{
  //   try {
  //     final db= await database;
  //     final startDate = DateTime(date.year,date.month,date.day,).millisecondsSinceEpoch;
  //     final endDate = DateTime(date.year,date.month,date.day,23,59,59).millisecondsSinceEpoch;
  //     var res = await db.rawQuery(
  //       ''' SELECT * FROM $Posts
  //           WHERE startTime BETWEEN 
  //           $startDate AND $endDate
  //           ORDER BY startTime
  //       '''
  //     );
  //     List<Posts> v = [];
  //     if(res.isNotEmpty){
  //       return v..addAll( res.map((f) => Posts.fromMap(f)));
  //     }
  //     else{
  //       return [];
  //     }
  //   } catch (e) {
  //     print(e);
  //     return [];
  //   }
  // }
  Future<List<Posts>> getAllPostswithQuery(GetPosts query,{orderBy = "timeStamp",type = 'update'})async{
    try {
      final db= await database;
      List<Map<String,dynamic>> res;
      switch (type) {
        case 'update':
          res = await db.query("Posts",where: "${query.queryColumn} = ? AND owner = ? AND type = ?",whereArgs: [query.queryData,query.id,NOTF_TYPE_CREATE],orderBy:orderBy );
          break;
        default: res = await db.query("Posts",where: "${query.queryColumn} = ? AND type = ?",whereArgs: [query.queryData, NOTF_TYPE_CREATE],orderBy:orderBy );
        break;
      }
      List<Posts> v = [];
      if(res.isNotEmpty)
        return v..addAll(res.map((f) => Posts.fromMap(f)));
      else
        return [];
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<Posts>> getPostInPrefs(GetPosts query)async{
    try {
      final db = await database;
      // var res = await db.query('Posts',where: "sub=ANY?x",whereArgs: prefs.getRange(0, 10).toList());
      var res = await db.rawQuery(
        "SELECT * FROM Posts WHERE council = ? ? ORDER",[query.queryData,query.id]
      );
      print(res);
      List<Posts> v = [];
        if(res.isNotEmpty){
        return v..addAll( res.map((f) => Posts.fromMap(f)));
        }else{
          return  [];
        }
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<Posts>> getAllApprovalPost(GetPosts query, bool islevel2,String id)async{
    try {
      final db = await database;
      var res = islevel2?
      await db.query("Posts",where: "$COUNCIL = ? AND $TYPE = ?",whereArgs: [query.queryData,NOTF_TYPE_PERMISSION],orderBy: "timeStamp DESC")
       : await db.query("Posts",where: "owner = ?",whereArgs: [id], orderBy: "timeStamp DESC");
      // print(res);
      List<Posts> v = [];
        if(res.isNotEmpty){
        return v..addAll( res.map((f) => Posts.fromMap(f)));
        }else{
          return  [];
        }
    } catch (e) {
      print(e);
      return [];
    }
  }
  
  /// id is necessary
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

  // updatePosts(Posts newPosts)async{
  //   try {
  //     final db= await database;
  //     var res= await db.update("Posts",newPosts.toMap(),where:"id = ?",whereArgs: [newPosts.id],conflictAlgorithm: ConflictAlgorithm.replace);
  //     return res;
  //   } catch (e) {
  //     print(e);
  //   }
  // }
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
/// return false for any error while true for evrything alright and saves data in hive database
Future<bool> populateUsers() async{
  // final String url = FETCH_USERDATA_API;
  try{
    print("FETCHING USERDATA ...");
    Box userBox = await HiveDatabaseUser().hiveBox;
    print(auth);
    Response res = await post(FETCH_USERDATA_API,headers: HEADERS, body: json.encode({'auth': auth}));
    print(res.statusCode);
    print("BODY "+res.body);
    if(res == null || res.statusCode != 200){
      return false;
    }else{
      try {
        var userData = json.decode(res.body);
          print(userData[ID]);
          var data = userData[USER_PREFS];
          var prefs = [];
          data.forEach((key,value){
            prefs += value['entity'] + value['misc'];
          });
          // return await writeContent('users', json.encode(snaphot.data));
          UserModel user= UserModel(
            id: userData[ID]??"",
            name: userData['name']??"",
            rollno: userData['rollno']??"",
            uid: userData['uid']??"",
            prefs: prefs.cast<String>()??[],
            admin: (userData['admin'] is bool) ?userData['admin']?? false : userData['admin'] == "true",
          );
          // print(user.admin);
          userBox.add(user);
          return true;
        } catch (e) {
          print("ERROR IN POPULATING USER FUNCTION line 461!!!");
          print(e);
          return false;
        }
    }
  }catch(e){
    print("ERROR IN POPULATING USER FUNCTION !!!");
    print(e);
    return false;
  }
}
/// returns are false null and true
Future<dynamic> populateAppData(String uid) async{
  Box userData;
    userData = await HiveDatabaseUser().hiveBox;
  return await populateUsers().then((status)async{
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
  try{
    Box box = await HiveDatabaseUser(databaseName: 'people').hiveBox;
    print("FETCHING  FROM PEOPLE ... $auth");
    Response res = await post(FETCH_PEOPLE_DATA_API,headers: HEADERS, body: json.encode({'auth': auth}));
    print(res.statusCode);
    print(res.body);
    if(res == null || res.statusCode != 200|| res.body == null || res.body.isEmpty){
      return false;
    }else{
      PeopleModel model = PeopleModel.fromMap(json.decode(res.body));
      print(model.councils);
      box.add(model);
      return true;
    }
  }catch(e){
    print("ERROR IN POPULATING PEOPLE FUNCTION ...");
    print(e);
    return false;
  }
}

// Future<bool> updateUserDataInFirebase(String uid,dynamic type,dynamic data)async{
//    return await databaseReference.collection('users').document(uid).updateData({'$type': data}).then((_){
//     return true;
//   }).catchError((var e){
//     print('Error in updateusersdata:' + e.toString());
//     return false;
//   });
// }
// TODO add auth
Future<bool> updatePrefsInFirebase(String uid,dynamic data)async{
  try {
    print("UPDATING PREFERNCES....");
    Response res = await post(
      UPDATE_PREFERENCES_API,
      headers: HEADERS,
      body: json.encode({'auth': auth, "council" : data}));
    if(res.statusCode == 200)
      return true;
    return false;
  } catch (e) {
    print("ERROR WHILE UPDATING PERFERENCES");
    print(e);
    return false;
  }
  
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
  String jsonDataBody = json.encode({
    'auth': auth,
    'id': id,
    'council':council,
    'por':value,
  });
  print(jsonDataBody);
  try {
    Response response = await post(MAKE_COORDINATOR_API, headers: HEADERS, body: jsonDataBody);
    int statusCode = response.statusCode;
    print(statusCode);
    print(response.body.toString());
    return statusCode;
  } catch (e) {
    print(e);
    return 1;
  }
}