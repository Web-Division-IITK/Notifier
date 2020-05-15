// To parse this JSON data, do
//
//     final Posts = PostsFromMap(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/functions.dart';

Posts postsFromJson(String str) => Posts.fromMap(json.decode(str));
PostsSort postsSortFromJson(String str) => PostsSort.fromMap(json.decode(str));
PostsSort copyPost(PostsSort postsSort) => PostsSort.copy(postsSort);
String poststoMap(Posts data) => json.encode(data.toMap());

class Posts {
    String id;
    String author;
    String council;
    String owner;
    String sub;
    String tags;
    int timeStamp;
    String title;
    String message;
    String body;
    String url;
    String type;
    int startTime;
    int endTime;
    bool bookmark;
    bool reminder;

    Posts({
        this.id,
        this.author,
        this.council,
        this.owner,
        this.sub,
        this.tags,
        this.timeStamp,
        this.title,
        this.message,
        this.body,
        this.url,
        this.type,
        this.endTime,
        this.startTime,
        this.bookmark,
        this.reminder = false 
    });

    factory Posts.fromMap(Map<String, dynamic> json) => Posts(
        id: json["id"],
        author: json["author"],
        council: json["council"],
        owner: json["owner"],
        sub: json["sub"],
        tags: json["tags"]??"",
        timeStamp: json['timeStamp'],
        title: json["title"],
        message: json["message"],
        body: json["body"],
        url: json["url"]??"",
        /// rememberForzero
        startTime: json['startTime']??0,
        endTime: json['endTime']??0,
        // startTime: json["url"]??"",
        // endTime: ,
        type: json['type']??'create',
        // reminder: json.containsKey('reminder')?(),
        bookmark: json.containsKey('bookmark')? (json['bookmark'] == 1):false, /// would be 1 or 0 
        reminder: json.containsKey('reminder')? (json['reminder'] == 1):false /// would be 1 or 0 
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "author": author,
        "council": council,
        "owner": owner,
        "sub": [sub],
        "tags": tags??"",
        "timeStamp": timeStamp,
        "title": title,
        "message": message,
        "body": body,
        "url": url??"",
        "type": type??'create',
        "startTime" :startTime??0,
        "endTime":endTime??0,
        "bookmark": bookmark == true ?1:0,
        "reminder":reminder == true ?1:0
    };
    Map<String, dynamic> toMapData() => {
        "id": id,
        "author": author,
        "council": council,
        "owner": owner,
        "sub": sub,
        "tags": tags??"",
        "timeStamp": timeStamp,
        "title": title,
        "message": message,
        "body": body,
        "url": url??"",
        "type": type??'create',
        "startTime" :startTime??0,
        "endTime":endTime??0,
        "bookmark": bookmark == true ?1:0,
        "reminder": reminder == true ?1:0
    };
    
}
class PostsSort{
    String id;
    String author;
    String council;
    String owner;
    String sub;
    String tags;
    int timeStamp;
    String title;
    String message;
    String body;
    String url;
    String type;
    String dateAsString;
    int startTime;
    int endTime;
    bool bookmark;
    bool reminder;

    PostsSort({
        this.id,
        this.author,
        this.council,
        this.owner,
        this.sub,
        this.tags,
        this.timeStamp,
        this.title,
        this.message,
        this.body,
        this.url,
        this.type,
        this.dateAsString,
        this.startTime,
        this.endTime,
        this.bookmark,
        this.reminder = false
    });
    factory PostsSort.fromMap(Map<String, dynamic> json) {
      // String data;
      // print(json['startTime']);
      return PostsSort(
        id: json["id"],
        author: json["author"],
        council: json["council"],
        owner: json["owner"],
        sub: json["sub"],
        tags: json["tags"] ?? "",
        timeStamp: (json['timeStamp'] is String)? double.parse(json['timeStamp']).round():json['timeStamp'],
        title: json["title"],
        message: json["message"],
        body: json["body"],
        url: json["url"]??"",
        type: json['type']??"create",
        dateAsString: convertDateToString(DateTime.fromMillisecondsSinceEpoch((json['timeStamp'] is String)? double.parse(json['timeStamp']).round():json['timeStamp'])),
        startTime: (json['startTime'] is String)?(json['startTime'] == ''? 0:  int.parse(json['startTime'].trim())): (json['startTime']??0),
        endTime: json['endTime']is String?(json['endTime'] == ''? 0: int.parse(json['endTime'].trim())): (json['endTime']??0),
        bookmark: json.containsKey('bookmark')? (json['bookmark'] == 1):false, /// would be 1 or 0 
        reminder: json.containsKey('reminder')? (json['reminder'] == 1):false /// would be 1 or 0 
      );
    }
    Map<String, dynamic> toMapData() => {
        "id": id,
        "author": author,
        "council": council,
        "owner": owner,
        "sub": [sub],
        "tags": tags??"",
        "timeStamp": timeStamp,
        "title": title,
        "message": message,
        "body": body,
        "url": url??"",
        "type": type??'create',
        "startTime" :startTime??0,
        "endTime":endTime??0,
        "bookmark": bookmark == true ?1:0,
        "reminder":reminder == true ?1:0
    };
    Map<String, dynamic> toMap() => {
        "id": id,
        "author": author,
        "council": council.toLowerCase(),
        "owner": owner,
        "sub": sub,
        "tags": tags??"",
        "title": title,
        "message": message,
        "timeStamp":timeStamp,
        "body": body,
        "url": url??"",
        "type": type??'create',
        "startTime" :startTime??0,
        "endTime":endTime??0,
        "bookmark":bookmark == true ?1:0,
        "reminder":reminder == true ?1:0
    };
    static copy(PostsSort postsSort) {
      // String data;
        
      return PostsSort(
        id: postsSort.id,
        author: postsSort.author,
        council: postsSort.council,
        owner: postsSort.owner,
        sub: postsSort.sub,
        tags: postsSort.tags,
        timeStamp: postsSort.timeStamp,
        title: postsSort.title,
        message: postsSort.message,
        body: postsSort.body,
        url: postsSort.url,
        type: postsSort.type,
        dateAsString: postsSort.dateAsString,
        startTime: postsSort.startTime,
        endTime: postsSort.endTime,
        bookmark: postsSort.bookmark,
        reminder: postsSort.reminder
        // dateAsString: convertDateToString(DateTime.fromMillisecondsSinceEpoch(json['timeStamp'])),
        
      );
    }
    Map<String, dynamic> toMapSave() => {
        "author": author??name,
        "id":id,
        "council": council.toLowerCase(),
        "owner": owner,
        "sub": sub,
        "tags": tags??'',
        "title": title,
        "message": message,
        "body": body,
        "url": url??"",
        "timeStamp": timeStamp??DateTime.now().millisecondsSinceEpoch,
        "type": type??'create',
        "startTime" :startTime??0,
        "endTime":endTime??0,
        "bookmark":bookmark == true? 1: 0,
        "reminder":reminder == true? 1: 0
    };
}
class GetPosts{
final String queryColumn;
final dynamic queryData;
/// required for updateing post
final String id;
GetPosts({@required this.queryColumn, @required this.queryData,this.id});
}