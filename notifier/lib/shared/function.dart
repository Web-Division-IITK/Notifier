import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notifier/data/data.dart';
import 'package:notifier/screens/home/home.dart';
import 'package:path_provider/path_provider.dart';


String fieName = 'data';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  // print(directory.path);
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path' + '/' + 'data' + '.txt');
}
Future<File> get _localFilePeople async {
  final path = await _localPath;
  return File('$path' + '/' + 'people' + '.txt');
}

Future<Map<String, dynamic>> readContent(String name) async {
  try {
    final file  = name == 'people' ? await _localFilePeople :
     await _localFile;
    // Read the file
    String content = await file.readAsString();
    // print(content);
    var contents = json.decode(content);
    // Returning the contents of the file
    // print(contents.toString());
    return contents;
  } catch (e) {
    print(e);
    // If encountering an error, return
    return null;
  }
}

Future<File> writeContent(String fileName,var contentToWrite) async {
  final file = fileName == ' people' ? await _localFilePeople: await _localFile;
  // Write the fil
  // var contentToWrite =  fileName == 'people'? null : jsonContent;
  var jsonData = json.encode(contentToWrite);
  // print(jsonData);
  return file.writeAsString(jsonData);
}

Future<File> deleteContent(String fileName)async{
  try{
    final file = fileName == ' people' ? await _localFilePeople: await _localFile;
  return file.delete();
  }catch(e){
    if(e == '[ERROR:flutter/lib/ui/ui_dart_state.cc(157)] Unhandled Exception: FileSystemException: Cannot delete file, path = \'/data/user/0/com.sntcouncil.notifier/app_flutter/data.json\' (OS Error: No such file or directory, errno = 2'){
      return null;
    }
    print(e);
  }
}