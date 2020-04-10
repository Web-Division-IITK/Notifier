import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/screens/posts/createposts.dart';
import 'package:notifier/screens/posts/update/editupdate.dart';
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
  bool _load;
  Map<String, dynamic> _post;
  bool _loadingDelete = false;

  makeUpdatePost() async {
    return await readPeople().then((var v) {
      print(v);
      if (v != null && v['posts'] != null && v['posts'].length != 0) {
        loadPostsUsers(v['posts']).then((bool status) {
          print(status.toString() + 'stauts line39 upadate.dart');
          // print(docById.keys.length != 0);
          if (docById != null && docById.keys.length!=0 ) {
            setState(() {
              var i = 0;
              docById.keys.forEach((key) {
                
                if (docById[key]['exists']!=null && docById[key]['exists']) {
                  if(update==null){
                    update = [];
                  }update.insert(0, UpdatePostsFormat(uid: key, value: docById[key]));
                      i++;
                } else if (update!=null && update.contains(
                    UpdatePostsFormat(uid: key, value: docById[key]))) {
                  update
                      .remove(UpdatePostsFormat(uid: key, value: docById[key]));
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
                  _post = docById;
                _load = false;
               }
               else if(i == 0){
                 update = [];
                 _post = null;
                 _load = false;
               }
              });
            }
            });
           
          }else{
            setState(() {
              update =[];
            _post = null;
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
    String url =
        'https://us-central1-notifier-snt.cloudfunctions.net/deletePost';
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
                        itemCount: update.length,
                        itemBuilder: (BuildContext context, int index) {
                          // _post.
                          // print(_exists);
                          // print(_load);
                          return update[index].value['exists'] != null &&
                                  update[index].value['exists'] == true
                              ? Column(
                                  children: <Widget>[
                                    ListTile(
                                      // dense: ,
                                      title: Text(
                                          update[index].value['title'].toString()),
                                      subtitle: Text(update[index].value['message']
                                          .toString()),
                                      trailing: Wrap(
                                        direction: Axis.vertical,
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            tooltip: 'Edit Post',
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(builder:
                                                      (BuildContext context) {
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
                                                  title: Text(
                                                      'Delete Confirmation'),
                                                  content: Column(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text('Do you really want to permanently delete this file',
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      SizedBox(height: 5.0),
                                                      Text(
                                                          'Note: You will not be able to recover this file later',
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
                                                    // CupertinoButton.filled(child: Text('Dismiss'), onPressed: null),
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
                                                      setState(() {
                                                      update[index].value['exists'] = false;
                                                      _post[update[index].uid]['exists'] = false;
                                                      _post.remove(update[index].uid);
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
                                                  });
                                                } else {
                                                  setState(() {
                                                      _loadingDelete = false;
                                                      Fluttertoast.showToast(msg: 'Deletion Failed!!');
                                                      Navigator.pop(context);
                                                  });
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
                                                
                                              })
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                    )
                                  ],
                                )
                              : Container();
                        },
                      )),
                      _loadingDelete ? Center(child: CircularProgressIndicator(),) :Container()
                  ],
                ));
  }

  // Widget cardForUpdate() {}
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
