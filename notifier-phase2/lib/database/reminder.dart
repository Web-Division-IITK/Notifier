import 'dart:io';

import 'package:notifier/constants.dart';
import 'package:notifier/model/posts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider{
  final String databaseName;
  final String tableName;
  DatabaseProvider({this.databaseName = 'reminder',this.tableName = 'Reminder'});
  // const table = 'Reminder';
  static Database _database;
  static Database _db;
  static Database _dbPermission;
  Future<Database> get database async{
    if(databaseName == 'drafts'){
      if(_db!=null){
        return _db;
      }
        // deleteData();
        _db = await initDB();
        return _db;
    }
    else if(databaseName == 'permission'){
      if(_dbPermission!=null){
        return _dbPermission;
      }
        // deleteData();
        _dbPermission = await initDB();
        return _dbPermission;
    }
    // }
      else{
        if(_database!=null){
          return _database;
        }
      // deleteData();
      _database = await initDB();
      return _database;
    }
  }
  deleteData()async{
     try {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
      var exists;
      print( exists = await databaseExists(join(documentsDirectory.path,databaseName,'.db')));
      return await deleteDatabase(join(documentsDirectory.path,databaseName,'.db')).then((_)async{
        if(databaseName == 'drafts'){
          _db = null;
        }else if(databaseName == 'permission'){
          _dbPermission = null;
        }
        else{
          _database = null;
        }
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
  Future<Database> initDB() async{
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path,databaseName,'.db');
    String data = """ CREATE TABLE $tableName 
    (id TEXT PRIMARY KEY,bookmark INTEGER,
      council TEXT,sub TEXT,
      type TEXT,owner TEXT,
      tags TEXT,timeStamp INTEGER,
      title TEXT,message TEXT,
      startTime INTEGER,
      endTime INTEGER,
      reminder INTEGER,
      isFeatured INTEGER,
      body TEXT,author TEXT,
      isFetched INTEGER,
      url TEXT)""";
    return await openDatabase(
      path,version: 1,onCreate: (db,version)async{
        return await db.execute(data);
      }
    );
  }
  ///returns null for an error
  Future<int>insertPost(Posts posts) async{
    final db = await database;
    try {
      // printPosts(Posts);
      print(posts.toMap());
      return await db.insert(
        "$tableName", 
        posts.toMap(),conflictAlgorithm: ConflictAlgorithm.replace
      );
    } catch (e) {
      print(e);
      return -1;
    }
  }
  Future<Posts>getPosts(GetPosts query) async{
    final db = await database;
    try {
      var res = await db.query("$tableName",where:"${query.queryColumn} = ?",whereArgs: [query.queryData] ,orderBy: "startTime");
      
      return res.isNotEmpty ? Posts.fromMap(res.first):Posts(reminder: false);
    } catch (e) {
      print(e);
      return Posts(reminder: false);
    }
  }
  Future<List<Posts>> getAllPosts() async{
    final db = await database;
//    print(db);
    try {
      var res = await db.query(
        "$tableName",orderBy: "timeStamp DESC"
      );
      // print(res);
      List<Posts> v = [];
      if(res.isNotEmpty){
        return v..addAll( res.map((f) => Posts.fromMap(f)));
      }
      else{
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<Posts>> getAllPostsForOngoingEvent() async{
    final db = await database;
    try {
      int today = DateTime.now().millisecondsSinceEpoch;
      // int day = DateTime(today.year,today.month,today.day).millisecondsSinceEpoch;
      var res = await db.query(
        "$tableName",where: "$STARTTIME < ? AND $ENDTIME > ? AND $TYPE = ?",whereArgs: [today,today,NOTF_TYPE_CREATE], orderBy: "timeStamp DESC"
      );
      List<Posts> v = [];
      if(res.isNotEmpty){
        return v..addAll( res.map((f) => Posts.fromMap(f)));
      }
      else{
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<int> noOfPosts() async{
    try {
      final db = await database;
      final today = DateTime.now();
      int day = DateTime(today.year,today.month,today.day).millisecondsSinceEpoch;
      var res = await db.query(
        "$tableName", orderBy: "timeStamp DESC"
      );
      if(res != null){
        return res.length;
      }
      else return 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }
  Future<List<Posts>> getAllPostsForUpcomingEvents() async{
    final db = await database;
    try {
      int today = DateTime.now().millisecondsSinceEpoch;
      // int day = DateTime(today.year,today.month,today.day).millisecondsSinceEpoch;
      var res = await db.query(
        "$tableName",where: "$STARTTIME > ? AND $TYPE = ?",whereArgs: [today,NOTF_TYPE_CREATE], orderBy: "timeStamp DESC"
      );
      List<Posts> v = [];
      if(res.isNotEmpty){
        return v..addAll( res.map((f) => Posts.fromMap(f)));
      }
      else{
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<Posts>> getAllPostswithQuery(GetPosts query,{orderBy = "startTime"})async{
    try {
      final db= await database;
      var res = await db.query("$tableName",where: "${query.queryColumn} = ?",whereArgs: [query.queryData],orderBy: orderBy);
      // Map<String,PostsSort> list = {};
      // if(res.isNotEmpty) {
      //   res.forEach((f){
      //   list.update(f['id'], (_)=>PostsSort.fromMap(f),ifAbsent: ()=>Posts.fromMap(f));
      // });
      // }
      // print(res);
      
      List<Posts> v = [];
      if(res.isNotEmpty){
      //   res.forEach((value){
      //   v.add(Posts.fromMap(value));
      // });
      // }
        return v..addAll( res.map((f) => Posts.fromMap(f)));
      }
      else{
        return [];
      }
      // return res.isNotEmpty?list:{};
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<Posts>> getAllEventsWithCouncil(int startTime, int endTime, String type,{orderBy = "startTime"})async{
    try {
      final db= await database;
      var res = await db.query("$tableName",where: "$STARTTIME BETWEEN ? AND ? AND $TYPE = ?",
        whereArgs: [startTime,endTime,type],orderBy: orderBy);
      List<Posts> v = [];
      if(res != null && res.isNotEmpty){
        return v..addAll( res.map((f) => Posts.fromMap(f)));
      }
      else{
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
  
      /// givenWeekday is a weekday whoose date is to be find
      /// 
      /// This is an integer taking `Monday` as 1
  Future<Map<DateTime,List<Posts>>> getAllPostswithDate(DateTime date,{int givenWeekday})async{
    try {
      final db= await database;
      final startDate = DateTime(date.year,date.month,1,).millisecondsSinceEpoch;
      final endDate = DateTime(date.year,date.month,noOfDaysInMonths(date.month, date.year),23,59,59).millisecondsSinceEpoch;
      var res = await db.rawQuery(
        ''' SELECT * FROM $tableName
            WHERE startTime BETWEEN 
            $startDate AND $endDate
            ORDER BY startTime
        '''
      );
      // int firstDateWithGivenWeekDate;
      // if((givenWeekday - date.weekday) %7 == 0)
      //   firstDateWithGivenWeekDate = date.day;
      // else 
      //   firstDateWithGivenWeekDate = (givenWeekday + 8 - date.weekday) % 7;
      
      // var dbRes = await db.query(tableName,where: "council = ?", whereArgs: ['true'], orderBy: "$STARTTIME");
      // int noOfWeekDays = ((date.subtract(Duration(days: givenWeekday)).weekday 
      //     - date.day + noOfDaysInMonths(date.month, date.year))/7).floor();
      Map<DateTime,List<Posts>> v = {};
      // res.forEach((post) {
      //   List.generate(noOfWeekDays, (index){
      //     DateTime _startTime = DateTime.fromMillisecondsSinceEpoch(post["startTime"]);
      //     DateTime startTime = DateTime(
      //       date.year,date.month, firstDateWithGivenWeekDate, _startTime.hour, _startTime.minute
      //     ).add(Duration(days: 7*index));
      //     v.update(
      //       DateTime(startTime.year,startTime.month,startTime.day),
      //       (value){
      //         value.add(Posts.fromMap(post));
      //         return value;
      //       },
      //       ifAbsent: (){
      //         return [Posts.fromMap(post)];
      //       }
      //     );
      //   });
        // 
      // });
      // var res = await db.query("$tableName",where: "${query.queryColumn} = ?",whereArgs: [query.queryData],orderBy: orderBy);
      // print(res);
      
      // List<Posts> v = [];
      // if(res.isNotEmpty){
      //   // print(res.first);
      //   v..addAll( res.map((f) => Posts.fromMap(f)));
      // }
      
      res.forEach((post) {
        DateTime startTime = DateTime.fromMillisecondsSinceEpoch(post["startTime"]);
        v.update(
          DateTime(startTime.year,startTime.month,startTime.day),
          (value){
            if(value == null || value.isEmpty)
              return [Posts.fromMap(post)]  ;
            value.add(Posts.fromMap(post));
            return value;
          },
          ifAbsent: (){
            return [Posts.fromMap(post)];
          }
        );
      });
      // print(v);
      return v;
      // return Map.fromIterable(res,
      //   key: (post) {
      //     DateTime startTime = DateTime.fromMillisecondsSinceEpoch(post["startTime"]);
      //     return DateTime(startTime.year,startTime.month,startTime.day);
      //   },
      //   value: (post) => post
      // );
    } catch (e) {
      print(e);
      return {};
    }
  }
  updateQuery(GetPosts query)async{
    try {
      final db= await database;
    var res = await db.rawUpdate(
      '''UPDATE $tableName
      SET ${query.queryColumn} = ?
      WHERE id = ?
      ''',
      [query.queryData,query.id]
    );
    return res;
    } catch (e) {
      print(e);
    }
  }
  updatePosts(Posts posts)async{
    try {
        final db= await database;
      var res= await db.update(
        "$tableName",posts.toMap(),
        where:"id = ?",whereArgs: [posts.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
      return res;
    } catch (e) {
      print(e);
    }
  }
  deletePost(String id) async{
    try {
      final db = await database;
      if(db.isOpen){
        print('open');
        return db.delete("$tableName",where:"id = ?",whereArgs: [id]);
      }else{
        print('close');
      }
    } catch (e) {
      return 1;
    }
  }
  deleteAllPosts() async{
    try {
      final db = await database;
    db.rawDelete("Delete * from $tableName");
    } catch (e) {
      print(e);
    }
  }
}