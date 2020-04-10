import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/screens/posts/createposts.dart';
import 'package:notifier/screens/posts/update/editupdate.dart';
import 'package:notifier/services/function.dart';
import 'package:notifier/widget/chips.dart';
import 'package:path/path.dart' as Path;
import 'package:notifier/services/databse.dart';



class UpDatePosts extends StatefulWidget {
  final String _id;
  final List<String> _subs;
  UpDatePosts(this._id, this._subs);
  @override
  _UpDatePostsState createState() => _UpDatePostsState();
}

  List<UpdatePostsFormat> update = List();
class _UpDatePostsState extends State<UpDatePosts> {
  final _myListKey = GlobalKey<AnimatedListState>();
  bool _load;
  Map<String, dynamic> _post;
  bool _loadingDelete = false;

  makeUpdatePost() async {
    return await readPeople().then((var v) {
      // print(v);
      if (v != null && v['posts'] != null && v['posts'].length != 0) {
        loadPostsUsers(v['posts']).then((bool status) {
          print(status.toString() + 'stauts line39 upadate.dart');
          // print(docById.keys.length != 0);
          if (status) {
            if (docById != null && docById.keys.length!=0 ) {
              var i = 0;
                docById.keys.forEach((key) {
                  
                  if (docById[key]['exists']!=null && docById[key]['exists']) {
                    if(update==null){
                      setState(() {
                        update = [];
                      });
                    }
                    // _myListKey.currentState.insertItem(0);
                    update.insert(0, UpdatePostsFormat(uid: key, value: docById[key]));
                        i++;
                  } else if (update!=null && update.contains(
                      UpdatePostsFormat(uid: key, value: docById[key]))) {
                    update.remove(UpdatePostsFormat(uid: key, value: docById[key]));
                  }
                  // print(update[i]);
                  // i++;
                });
                if (docById != null &&
                  update != null &&
                  docById.length == v['posts'].length) {
                setState(() {
                  writeContent('posts', json.encode(docById)).then((var v) {
                    if (v) {
                      print('writing posts done line87 in updatepost.dart');
                    } else {
                      print('writing posts failed line87 in updatepost.dart');
                    }
                  });
                  if(i!=0){
                    setState(() {
                        _post = docById;
                    _load = false;
                    });
                  }
                  else if(i == 0){
                    setState(() {
                      update = [];
                      _post = null;
                      _load = false;
                    });
                  }
                });
              }
              // });
            
            }else{
              setState(() {
                update =[];
                _post = null;
                _load = false;
              });
            }
          } else {
            setState(() {
              update = null;
              _load = false;
            });
          }
        });
        // }
        // print(docById);

      } else {
        setState(() {
          update = [];
          _post = null;
          _load = false;
        });
      }
    });
  }

  updateposts() async {
    setState(() {
      _load = true;
    });
    return await fileExists('posts').then((var _exists) async {
      print(_exists.toString() + 'exists in update.dart line 87');
      if (_exists) {
        await readContent('posts').then((var value) {
          print(value);

          if (value != null && value.length != 0) {
            if(update != null){update.clear();}
            var i=0;
            value.keys.forEach((key) {
              if (value[key]['exists']) {
                // _myListKey.currentState.insertItem(0);
                update.insert(0,
                    UpdatePostsFormat(uid: key, value: value[key] as dynamic));
                    i++;
              } else if (update!=null && update
                  .contains(UpdatePostsFormat(uid: key, value: value[key]))) {
                update.remove(UpdatePostsFormat(uid: key, value: value[key]));
              }
            });
            // print(update[0].value);
            print(i);
            if (update != null && i!=0) {
              setState(() {
                _post = value;
                _load = false;
              });
            } else if (update == null|| i==0) {
              setState(() {
                update =[];
                _post = null;
                _load = false;
              });
            }
          } else {
            setState(() {
              update = [];
              _post = null;
              _load = false;
            });
          }
        });
      } else {
        return makeUpdatePost();
      }
    });
  }

  Future<int> deletePost(UpdatePostsFormat _update,String _id,List<String> _subs,) async {
    setState(() {
      _loadingDelete = true;
    });
    Map<String, String> headers = {"Content-type": "application/json"};
    var value = jsonEncode({
      'title': _update.value['title'],
      'tags': _update.value['tags'],
      'council': _update.value['council'].toString().toLowerCase(),
      'sub': _subs,
      'body': _update.value['body'],
      'author': _update.value['author'],
      'url': _update.value['url'],
      'owner': _id,
      'message': _update.value['message'],
      'id': _update.uid,
    });
    print(value);
    String json = '$value';
    String url = 'https://us-central1-notifier-phase-2.cloudfunctions.net/deletePost';
    try {
      Response response = await post(url, headers: headers, body: json);
      int statusCode = response.statusCode;
      print(statusCode);

      return statusCode;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _load = true;
    });
    updateposts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Update Posts'),
        ),
        body: _load
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : update == null || update.length ==0
                ? Container(
                    child: Center(
                      child: Text('You have not created any posts'),
                    ),
                  )
                : Stack(
                  children: <Widget>[
                    Container(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 16.0),
                        itemCount: update.length,
                        itemBuilder: (BuildContext context, int index) {
                          // _myListKey.currentState.insertItem(index);
                          return update[index].value['exists'] != null &&
                                  update[index].value['exists'] == true
                              ? Column(
                                  children: <Widget>[
                                    itemsAndContent(index)
                                    // cardItem(index,animation),
                                    // Divider(
                                    //   color: Colors.grey,
                                    // )
                                  ],
                                )
                              : Container();
                        },
                      )),
                      _loadingDelete ? Center(child: CircularProgressIndicator(),) :Container()
                  ],
                ));
  }
  cardItem(index,animation){
    // _myListKey.currentState.insertItem(index);
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(update[index].value['title'].toString()),
        subtitle: Text(update[index].value['message'].toString()),
        trailing: Wrap(
          direction: Axis.vertical,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: 'Edit Post',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder:(BuildContext context) {
                    return UpdateN(
                      update[index],
                      widget._id,
                      widget._subs,
                      index);
                }));
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Delete Post',
              onPressed: () async {
                                                    
                showCupertinoDialog(context: context, builder:(context){
                  return  AlertDialog(
                    title: Row(
                      children: <Widget>[
                        Icon(Icons.warning),
                        Text('Delete Confirmation ?',
                          style: TextStyle(
                            color: Colors.red
                          )
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Do you really want to permanently delete this file',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5.0),
                        Text('Note: You will not be able to recover this file later',
                          style:TextStyle(
                            fontSize: 10.0
                          )
                        ),
                                                      //   ],
                                                      // ),
                        SizedBox(height: 10.0),
                        Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                                                          // width:  *0.5,
                            child: FlatButton(
                              onPressed: () =>
                                Navigator.pop(context),
                                child: Text('Dismiss'),
                            ),
                          ),
                        SizedBox(width:10.0),
                        Container(
                          // width: MediaQuery.of(context).size.height*0.5,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                            ),
                            onPressed: () async {
                              setState(() {
                                _loadingDelete = true;
                              });
                              // Navigator.pop(context);
                              int statusCode = await deletePost(
                                update[index],
                                widget._id,
                                widget._subs,
                              );
                              if (statusCode == 200) {
                                                          // if (sortedarray.contains(sortedarray.indexOf(SortDateTime(
                                                          //             update[index].uid,
                                                          //             DateTime.parse(update[index].value['timeStamp']).toUtc().millisecondsSinceEpoch,
                                                          //             update[index].value, update[index].value['sub'][0],'')))) {
                                                          //   setState(() {
                                                          //     sortedarray[sortedarray.indexOf(SortDateTime(
                                                          //                 update[index].uid,
                                                          //                 update[index].value['timeStamp'],
                                                          //                 update[index].value,update[index].value['sub'][0]))].value['exists'] = false;
                                                          //   });
                                                          // }
                                                          
                                // setState(() {
                                  update[index].value['exists'] = false;
                                  _post[update[index].uid]['exists'] = false;
                                // });
                                AnimatedListRemovedItemBuilder builder = (context,animation){
                                  return cardItem(index, animation);
                                };
                                _post.remove(update[index].uid);
                                _myListKey.currentState.removeItem(index,builder);
                                update.remove(update[index]);
                                // print(_post[update[index].uid]);
                                writeContent('posts',json.encode(_post))
                                    .then((var v) {
                                  if (v) {
                                    setState((){
                                      _loadingDelete = false;
                                      
                                    });
                                    if(update.length==0){
                                      update = [];
                                    }
                                    Fluttertoast.showToast(msg:'Delete Successful');
                                    
                                  } else {
                                    setState((){
                                      _loadingDelete = false;
                                    });
                                    Fluttertoast.showToast(msg: 'Delete Failed');
                                  }
                                });
                                                          // setState(() {
                                                          //   _loadingDelete =false;
                                                          // });
                                
                              } else {
                                setState(() {
                                    _loadingDelete = false;
                                    
                                });
                                Fluttertoast.showToast(msg: 'Deletion Failed!!');
                                    // Navigator.pop(context);
                              }
                            },
                            child: Text('Confirm',
                              style: TextStyle(color:Colors.white),
                            ),
                          ),
                        ),
                                  // CupertinoDialogAction(child: Text('Confirm')),
                                  // CupertinoDialogAction(child: Text('Dismiss'))
                      ],
                  )
                  ]
                      ));
                  });
                                                    
              }
            )
          ],
        ),
      ),
    );
  }
itemsAndContent(index){
  var postTime = DateTime.parse(update[index].value['timeStamp']);
  var day,time;
  if (DateTime.now().day == postTime.day && DateTime.now().month == postTime.month && DateTime.now().year == postTime.year) {
                if (DateTime.now().hour == postTime.hour ||
                    (DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) < 3600000) {
                  switch (DateTime.now().minute - postTime.minute) {
                    case 0:
                      time = 'now';
                      day = 'Today';
                      // return [time,day];
                      break;
                    default:
                      var i = ((DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) /60000)
                          .round();
                      time = '$i minutes ago';
                      day = 'Today';
                      // return [time,day];
                  }
                } else {
                  time = 'Today, ' + DateFormat('kk:mm').format(postTime);
                  day = 'Today';
                  // return [time,day];
                }
              } else {
                time = DateFormat('d MMMM, yyyy : kk:mm').format(postTime);
                day = DateFormat('d MMMM, yyyy').format(postTime);
                // return [time,day];
              }
  // _myListKey.currentState.insertItem(index);
  return  Card(
      shape:RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      
      child:Container(
        padding: EdgeInsets.only(left :16.0,top:10.0),
        height: 100.0,
        width: MediaQuery.of(context).size.width-16.0,
        child: Stack(
          children: <Widget>[
            Container(
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //   )
              // ),
              width:(MediaQuery.of(context).size.width - 16.0)*0.76,
              // height: 60.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                   Container(
                          padding: EdgeInsets.only(top: 4.0),
                          child: AutoSizeText(
                            update[index].value['sub'][0],
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.blueGrey
                                    : Colors.white70,
                                // fontWeight: FontStyle.italic,
                              fontSize: 13.0,
                            ),
                          )),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0.0,5.0,8.0,8.0),
                          child: AutoSizeText(
                            // 'Sint voluptate do sunt proident lore ullamco irure pariatur eiusmod dolore cupidatat culpa ullamco.',
                            update[index].value['title'],
                            minFontSize: 16.0,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                          )),
                        ),
                   Container(
              //   decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //   )
              // ),
                      width: (MediaQuery.of(context).size.width -16.0)*0.65,
                      child: AutoSizeText(
                      // 'Voluptate labore irure non velit ex proident id.Non veniam voluptate est anim elit mollit fugiat eu velit duis.Non ad aute culpa pariatur est Lorem aliquip est dolore culpa dolore exercitation.',
                        update[index].value['message'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Theme.of(context).brightness == Brightness.dark? Colors.white30: Colors.grey
                        )
                      ),
                    ),
                ],
              )
            
            ),
            // Positioned(
            //   top: 65.0,
            //   // alignment: Alignment.bottomLeft,
            //   child:
            // ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                // alignment: Alignment.bottomRight,
              //   decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //   )
              // ),
                      height:20.0,
                      margin:EdgeInsets.only(bottom:0.0,right: 16.0),
                      width: (MediaQuery.of(context).size.width -16.0)*0.3,
                      child: Text(
                        // '35 minutes ago',
                        time,
                        style: TextStyle(
                          fontSize:10.0
                          // minFontSize: 0.0,
                        ),
                        textAlign: TextAlign.end,
                      ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.only(right:8.0),
              //   decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //   )
              // ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                          height:35.0,
                          // width:MediaQuery.of(context).size.width*0.2,
                          padding: EdgeInsets.only(bottom:0.0,top:0.0),
                          child: IconButton(
                            // iconSize: 20.0,
                            padding: const EdgeInsets.all(0.0),
                            icon: Icon(Icons.edit),
                            tooltip: 'Edit Post',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder:(BuildContext context) {
                                  return UpdateN(
                                      update[index],
                                      widget._id,
                                      widget._subs,
                                      index);
                                }));
                              },
                            ),
                          ),
                          Container(
                            height:35.0,
                            child: IconButton(
                              //  iconSize: 20.0,
                              padding: const EdgeInsets.all(0.0),
                              icon: Icon(Icons.delete),
                              tooltip: 'Delete Post',
                              onPressed: () async {
                                                                    
                                showCupertinoDialog(context: context, builder:(context){
                                  return  AlertDialog(
                                    title: Row(
                                      children: <Widget>[
                                        Icon(Icons.warning,
                                          color: Colors.red,
                                        ),
                                        Text(' Delete this Post ?',
                                          style: TextStyle(
                                            color: Colors.red
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text('Doing this will permanently delete this file',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Text('Note: You will not be able to recover this file later',
                                          style:TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold
                                          )
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                            child: FlatButton(
                                              onPressed: () =>
                                                Navigator.pop(context),
                                                child: Text('Dismiss'),
                                            ),
                                          ),
                                        SizedBox(width:10.0),
                                        Container(
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0)
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                _loadingDelete = true;
                                              });
                                              Navigator.pop(context);
                                              int statusCode = await deletePost(
                                                update[index],
                                                widget._id,
                                                widget._subs,
                                              );
                                              if (statusCode == 200) {
                                                                          // if (sortedarray.contains(sortedarray.indexOf(SortDateTime(
                                                                          //             update[index].uid,
                                                                          //             DateTime.parse(update[index].value['timeStamp']).toUtc().millisecondsSinceEpoch,
                                                                          //             update[index].value, update[index].value['sub'][0],'')))) {
                                                                          //   setState(() {
                                                                          //     sortedarray[sortedarray.indexOf(SortDateTime(
                                                                          //                 update[index].uid,
                                                                          //                 update[index].value['timeStamp'],
                                                                          //                 update[index].value,update[index].value['sub'][0]))].value['exists'] = false;
                                                                          //   });
                                                                          // }
                                                                          
                                                // setState(() {
                                                  update[index].value['exists'] = false;
                                                  _post[update[index].uid]['exists'] = false;
                                                // });
                                                // AnimatedListRemovedItemBuilder builder = (context,animation){
                                                //   return cardItem(index, animation);
                                                // };
                                                _post.remove(update[index].uid);
                                                // _myListKey.currentState.removeItem(index,builder);
                                                update.remove(update[index]);
                                                // print(_post[update[index].uid]);
                                                writeContent('posts',json.encode(_post))
                                                    .then((var v) {
                                                  if (v) {
                                                    setState((){
                                                      _loadingDelete = false;
                                                      
                                                    });
                                                    if(update.length==0){
                                                      update = [];
                                                    }
                                                    Fluttertoast.showToast(msg:'Delete Successful');
                                                    
                                                  } else {
                                                    setState((){
                                                      _loadingDelete = false;
                                                    });
                                                    Fluttertoast.showToast(msg: 'Delete Failed');
                                                  }
                                                });
                                                
                                              } else {
                                                setState(() {
                                                    _loadingDelete = false;
                                                    
                                                });
                                                Fluttertoast.showToast(msg: 'Deletion Failed!!');
                                                    // Navigator.pop(context);
                                              }
                                            },
                                            child: Text('Confirm',
                                              style: TextStyle(color:Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]
                                 ));
                                });
                              }
                            )
                          )
                        ],
                      )
                    ),
            )
          ],
        )
      )
    );
}
itemsAnContent(index,animation){
  return Card(
    shape:RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
    
    child:Container(
      padding: EdgeInsets.only(left :16.0,top:8.0),
      height: 100.0,
      width: MediaQuery.of(context).size.width-16.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 61.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              )
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: (MediaQuery.of(context).size.width - 16.0)*0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        // padding: EdgeInsets.only(top: 5.0),
                        child: AutoSizeText(
                          update[index].value['sub'][0],
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.blueGrey
                                  : Colors.white70,
                              // fontWeight: FontStyle.italic,
                            fontSize: 13.0,
                          ),
                        )),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0.0,5.0,8.0,0.0),
                        child: AutoSizeText(
                          // 'Sint voluptate do sunt proident Lorem ullamco irure pariatur eiusmod dolore cupidatat culpa ullamco.',
                          update[index].value['title'],
                          minFontSize: 16.0,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                        )),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                      height: 30.0,
                      padding: EdgeInsets.only(bottom:0.0,top:0.0),
                      child: IconButton(
                        // iconSize: 20.0,
                        padding: const EdgeInsets.all(0.0),
                        icon: Icon(Icons.edit),
                        tooltip: 'Edit Post',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder:(BuildContext context) {
                              return UpdateN(
                                  update[index],
                                  widget._id,
                                  widget._subs,
                                  index);
                            }));
                          },
                        ),
                      ),
                      Container(
                        height:30.0,
                        child: IconButton(
                          //  iconSize: 20.0,
                          padding: const EdgeInsets.all(0.0),
                          icon: Icon(Icons.delete),
                          tooltip: 'Delete Post',
                          onPressed: () async {
                                                                
                            showCupertinoDialog(context: context, builder:(context){
                              return  AlertDialog(
                                title: Text('Delete Confirmation'),
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('Do you really want to permanently delete this file',
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 5.0),
                                    Text('Note: You will not be able to recover this file later',
                                      style:TextStyle(
                                        fontSize: 10.0
                                      )
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        child: FlatButton(
                                          onPressed: () =>
                                            Navigator.pop(context),
                                            child: Text('Dismiss'),
                                        ),
                                      ),
                                    SizedBox(width:10.0),
                                    Container(
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0)
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            _loadingDelete = true;
                                          });
                                          Navigator.pop(context);
                                          int statusCode = await deletePost(
                                            update[index],
                                            widget._id,
                                            widget._subs,
                                          );
                                          if (statusCode == 200) {
                                                                      // if (sortedarray.contains(sortedarray.indexOf(SortDateTime(
                                                                      //             update[index].uid,
                                                                      //             DateTime.parse(update[index].value['timeStamp']).toUtc().millisecondsSinceEpoch,
                                                                      //             update[index].value, update[index].value['sub'][0],'')))) {
                                                                      //   setState(() {
                                                                      //     sortedarray[sortedarray.indexOf(SortDateTime(
                                                                      //                 update[index].uid,
                                                                      //                 update[index].value['timeStamp'],
                                                                      //                 update[index].value,update[index].value['sub'][0]))].value['exists'] = false;
                                                                      //   });
                                                                      // }
                                                                      
                                            // setState(() {
                                              update[index].value['exists'] = false;
                                              _post[update[index].uid]['exists'] = false;
                                            // });
                                            AnimatedListRemovedItemBuilder builder = (context,animation){
                                              return cardItem(index, animation);
                                            };
                                            _post.remove(update[index].uid);
                                            _myListKey.currentState.removeItem(index,builder);
                                            update.remove(update[index]);
                                            // print(_post[update[index].uid]);
                                            writeContent('posts',json.encode(_post))
                                                .then((var v) {
                                              if (v) {
                                                setState((){
                                                  _loadingDelete = false;
                                                  
                                                });
                                                if(update.length==0){
                                                  update = [];
                                                }
                                                Fluttertoast.showToast(msg:'Delete Successful');
                                                
                                              } else {
                                                setState((){
                                                  _loadingDelete = false;
                                                });
                                                Fluttertoast.showToast(msg: 'Delete Failed');
                                              }
                                            });
                                            
                                          } else {
                                            setState(() {
                                                _loadingDelete = false;
                                                
                                            });
                                            Fluttertoast.showToast(msg: 'Deletion Failed!!');
                                                Navigator.pop(context);
                                          }
                                        },
                                        child: Text('Confirm',
                                          style: TextStyle(color:Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ]
                             ));
                            });
                          }
                        )
                      )
                    ],
                  )
                )
              ],
            ),
          ),
          Container(
            // height:25.0,
            padding: EdgeInsets.only(top:0.0),
            width: (MediaQuery.of(context).size.width -16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: (MediaQuery.of(context).size.width -16.0)*0.6,
                  child: AutoSizeText(
                  // 'Voluptate labore irure non velit ex proident id.Non veniam voluptate est anim elit mollit fugiat eu velit duis.Non ad aute culpa pariatur est Lorem aliquip est dolore culpa dolore exercitation.',
                    update[index].value['message'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Theme.of(context).brightness == Brightness.dark? Colors.white30: Colors.grey
                    )
                  ),
                ),
                Container(
                  height:20.0,
                  padding:EdgeInsets.only(bottom:0.0,top:8.0),
                  width: (MediaQuery.of(context).size.width -16.0)*0.25,
                  child: AutoSizeText(
                    '35 minutes ago',
                    // ,
                    minFontSize: 0.0,
                  ),
                )
              ],
            ),
          ),
        ]
      ),
    )
  );
}

}
converToString(List<dynamic> tags) {
  String v = '';
  for (var i = 0; i < tags.length; i++) {
    if (i == 0) {
      v = tags[i].toString();
      continue;
    }
    v = v + ';' + tags[i].toString();
    // print(i);
  }
  print(v);
  return v;
}
