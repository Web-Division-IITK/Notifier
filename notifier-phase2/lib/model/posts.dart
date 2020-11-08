// To parse this JSON data, do
//
//     final Posts = PostsFromMap(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/functions.dart';

Posts postsFromJson(String str) => Posts.fromMap(json.decode(str));
// PostsSort postsSortFromJson(String str) => PostsSort.fromMap(json.decode(str));
// PostsSort copyPost(PostsSort postsSort) => PostsSort.copy(postsSort);
String poststoMap(Posts data) => json.encode(data.toMap());

class Posts {
    String id;
    String author;
    String council;
    String owner;
    List<dynamic> sub;
    String tags;
    int timeStamp;
    String title;
    String message;
    String body;
    String url;
    String type;
    int startTime;
    int endTime;
    String dateAsString;
    bool isFeatured;
    bool bookmark;
    bool reminder;
    /// if `TRUE` it means that the post is fetched from the database
    bool isFetched;

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
        this.dateAsString,
        this.endTime,
        this.startTime,
        this.bookmark,
        this.reminder = false,
        this.isFetched = true,
        this.isFeatured = false 
    });

    factory Posts.fromMap(Map<String, dynamic> json) {
      // print(".............FEATAURED .........." + (json.containsKey(IS_FETCHED)? (json[IS_FETCHED]): 'this is not valid').toString());
      return Posts(
        id: json[ID],
        author: json[AUTHOR],
        council: json[COUNCIL],
        owner: json[OWNER],
        sub: (json[SUB]is List)? json[SUB] : (jsonDecode(json[SUB]) is List ? jsonDecode(json[SUB]): [jsonDecode(json[SUB])]),
        tags: json[TAGS]??"",
        timeStamp: (json[TIMESTAMP] is String)? double.parse(json[TIMESTAMP]).round():json[TIMESTAMP],
        title: json[TITLE],
        message: json[MESSAGE],
        body: json[BODY],
        url: json[URL]??"",
        startTime: (json[STARTTIME] is String) ?
          (json[STARTTIME] == null || json[STARTTIME] == ''?
          0 : int.parse(json[STARTTIME])) : json[STARTTIME]??0 ,
        endTime: (json[ENDTIME] is String) ?
          (json[ENDTIME] == null || json[ENDTIME] == ''?
          0 : int.parse(json[ENDTIME]) ) : json[ENDTIME]??0,
        dateAsString: convertDateToString(DateTime.fromMillisecondsSinceEpoch((json['timeStamp'] is String)? double.parse(json['timeStamp']).round():json['timeStamp'])),
        type: json[TYPE]??NOTF_TYPE_CREATE,
        isFeatured: json.containsKey(IS_FEATURED)?
          (json[IS_FEATURED] is String ? json[IS_FEATURED].round() == 'true'
          : (json[IS_FEATURED] is bool? json[IS_FEATURED] == true
         : json[IS_FEATURED] == 1)) :false,
        bookmark: json.containsKey(BOOKMARK)? (json[BOOKMARK] == 1):false, /// would be 1 or 0 
        reminder: json.containsKey(REMINDER)? (json[REMINDER] == 1):false, /// would be 1 or 0,
        isFetched: json.containsKey(IS_FETCHED)? (json[IS_FETCHED] == 1):true,
    );}
    Map<String, dynamic> toMap() => {
        ID : id,
        AUTHOR : author,
        COUNCIL : council.toLowerCase(),
        OWNER : owner,
        SUB : json.encode(sub),
        TAGS : tags??"",
        TIMESTAMP : timeStamp,
        TITLE : title,
        MESSAGE : message,
        BODY : body,
        URL : url??"",
        TYPE : type??NOTF_TYPE_CREATE,
        STARTTIME :startTime??0,
        ENDTIME :endTime??0,
        BOOKMARK : bookmark == true ?1:0,
        IS_FEATURED : isFeatured == true ?1:0,
        REMINDER: reminder == true ?1:0,
        IS_FETCHED: isFetched == true ?1:0
    };
    Map<String, dynamic> toPostMap() => {
        ID : id,
        AUTHOR : author,
        COUNCIL : council.toLowerCase(),
        OWNER : owner,
        SUB : (sub),
        TAGS : tags??"",
        TIMESTAMP : timeStamp,
        TITLE : title,
        MESSAGE : message,
        BODY : body,
        URL : url??"",
        TYPE : type??NOTF_TYPE_CREATE,
        STARTTIME :startTime == null ? '0' : startTime.toString(),
        ENDTIME :endTime == null ?'0' : endTime.toString(),
        BOOKMARK : bookmark == true,
        IS_FEATURED : isFeatured == true ,
        REMINDER: reminder == true,
        IS_FETCHED: isFetched == true,
    };
    Map<String, dynamic> toDraftsMap() => {
        ID : id??DateTime.now().millisecondsSinceEpoch,
        AUTHOR : author??name??owner,
        COUNCIL : council.toLowerCase(),
        OWNER : owner,
        SUB : json.encode(sub),
        TAGS : tags??"",
        TIMESTAMP : timeStamp??DateTime.now().millisecondsSinceEpoch,
        TITLE : title,
        MESSAGE : message,
        BODY : body,
        URL : url??"",
        TYPE : type??NOTF_TYPE_CREATE,
        STARTTIME :startTime??0,
        ENDTIME :endTime??0,
        BOOKMARK : bookmark == true ?1:0,
        IS_FEATURED : isFeatured == true ?1:0,
        REMINDER: reminder == true ?1:0,
        IS_FETCHED: isFetched == true ?1:0
    };
    static copy(Posts posts) {
      // String data;
        
      return Posts(
        id: posts.id,
        author: posts.author,
        council: posts.council,
        owner: posts.owner,
        sub: posts.sub,
        tags: posts.tags,
        timeStamp: posts.timeStamp,
        title: posts.title,
        message: posts.message,
        body: posts.body,
        url: posts.url,
        type: posts.type,
        dateAsString: posts.dateAsString,
        startTime: posts.startTime,
        isFeatured: posts.isFeatured,
        endTime: posts.endTime,
        bookmark: posts.bookmark,
        reminder: posts.reminder,
        isFetched: posts.isFetched,
        // dateAsString: convertDateToString(DateTime.fromMillisecondsSinceEpoch(json['timeStamp'])),
        
      );
    }
}
/*
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
        "id":id??DateTime.now().millisecondsSinceEpoch,
        "council": council.toLowerCase()??"",
        "owner": owner??"",
        "sub": sub??"",
        "tags": tags??'',
        "title": title??"",
        "message": message??"",
        "body": body??"",
        "url": url??"",
        "timeStamp": timeStamp??DateTime.now().millisecondsSinceEpoch,
        "type": type??'create',
        "startTime" :startTime??0,
        "endTime":endTime??0,
        "bookmark":bookmark == true? 1: 0,
        "reminder":reminder == true? 1: 0
    };
}*/
class GetPosts{
final String queryColumn;
final dynamic queryData;
/// required for updateing post
final String id;
GetPosts({@required this.queryColumn, @required this.queryData,this.id});
}