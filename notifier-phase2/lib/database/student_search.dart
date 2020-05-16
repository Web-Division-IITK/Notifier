
import 'dart:io';

import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/model/posts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class StuSearchDatabase{
  static String databaseName = 'ss';
  static String table = 'search';

  static Database _database;

  Future<Database> get database async{
    if(_database != null){
      return _database;
    }
    _database  = await initDB();
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
  Future<Database> initDB() async{
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path,databaseName,'.db');
    String data = """ CREATE TABLE $table
    (rollno TEXT PRIMARY KEY,
      name TEXT,username TEXT,
      bloodGroup TEXT,hall TEXT,
      dept TEXT, gender TEXT,hometown TEXT,
      program TEXT,room TEXT,
      year TEXT)""";
    try {
      return await openDatabase(
        path,version: 1,onCreate: (db,version)async{
          return await db.execute(data);
        }
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<int> insertStuData(SearchModel value) async{
    final db = await database;
    var values= value.toMap();
    try {
      var res = await db.insert(table,values,conflictAlgorithm: ConflictAlgorithm.replace);
      return res;
    } catch (e) {
      print(e);
      return -1;
    }
  }
  Future<List<SearchModel>> getAllStuData() async{
    final db = await database;
    try {
      var res = await db.query(table);
      List<SearchModel> v=[];
      if(res.isNotEmpty){
        return v..addAll(res.map((f) => SearchModel.fromMap(f)));
      }else{
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<SearchModel>> getAllPostswithQuery(QueryDatabase query)async{
    try {
      final db= await database;
      String whereString = "";
      if(query.queryColumn.length == 1){
        whereString = "${query.queryColumn[0]} = ?";
      }else{
        for (var i in query.queryColumn) {
          whereString += "$i = ?";
          if (query.queryColumn.last != i ) {
            whereString += " AND WHERE ";
          }
        }
      }
      var res = await db.query("$table",where: whereString,whereArgs: query.queryData,);
      print(res);
      
      List<SearchModel> v = [];
      if(res.isNotEmpty){
        return v..addAll( res.map((f) => SearchModel.fromMap(f)));
      }
      else{
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
  updateQuery(GetPosts query)async{
    try {
      final db= await database;
    var res = await db.rawUpdate(
      '''UPDATE $table
      SET ${query.queryColumn} = ?
      WHERE rollno = ?
      ''',
      [query.queryData,query.id]
    );
    return res;
    } catch (e) {
      print(e);
    }
  }
  updatePosts(SearchModel searchModel)async{
    try {
        final db= await database;
      var res= await db.update(
        "$table",searchModel.toMap(),
        where:"rollno = ?",whereArgs: [searchModel.rollno],
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
        return db.delete("$table",where:"roolno = ?",whereArgs: [id]);
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
      db.rawDelete("Delete * from $table");
    } catch (e) {
      print(e);
    }
  }
 }

 class QueryDatabase{
  final List<String> queryColumn;
  final List<dynamic> queryData;
  QueryDatabase(this.queryColumn,this.queryData);
 }