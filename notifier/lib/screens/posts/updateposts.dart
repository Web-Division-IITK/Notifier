import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/screens/posts/createposts.dart';
import 'package:path/path.dart' as Path;
import 'package:notifier/services/databse.dart';

  List<UpdatePostsFormat> update = List();
class UpDatePosts extends StatefulWidget {
  final String _id;
  final List<String> _subs;
  UpDatePosts(this._id, this._subs);
  @override
  _UpDatePostsState createState() => _UpDatePostsState();
}

class _UpDatePostsState extends State<UpDatePosts> {
  bool _load;
  Map<String, dynamic> _post;
  // String _title;
  // String _body;

  updateposts() async {
    setState(() {
      _load = true;
    });
    await fileExists('posts').then((var _exists) async {
      print(_exists);
      if (_exists) {
        await readContent('posts').then((var value) {
          print(value);
          if (value != null) {
            update.clear();
            value.keys.forEach((key) {
              if (value[key]['exists']) {
                update.add(UpdatePostsFormat(uid: key, value: value[key] as dynamic));
              } else if (update
                  .contains(UpdatePostsFormat(uid: key, value: value[key]))) {
                update.remove(UpdatePostsFormat(uid: key, value: value[key]));
              }
            });
            print(update[0].value);

            if (update != null) {
              setState(() {
                _post = value;
                _load = false;
              });
            } else if (update == null) {
              setState(() {
                _post = null;
                _load = false;
              });
            }
          }
        });
      } else {
        await readPeople().then((var v) {
          print(v);
          if (v != null && v['posts'] != null) {
            for (var i in v['posts']) {
              docById.clear();
              getDocByID(i).then((bool status) {
                print(status);
                if (docById != null) {
                  setState(() {
                    var i=0;
                    docById.keys.forEach((key) {
                      if (docById[key]['exists']) {
                        update.add(
                            UpdatePostsFormat(uid: key, value: docById[key]));
                      } else if (update.contains(
                          UpdatePostsFormat(uid: key, value: docById[key]))) {
                        update.remove(
                            UpdatePostsFormat(uid: key, value: docById[key]));
                      }
                      print(update[i]);
                      i++;
                    });
                  });
                  if (docById != null && update != null) {
                    setState(() {
                      
                      
                      writeContent('posts', json.encode(docById)).then((var v){
                        if(v){
                          print('writing posts done line87 in updatepost.dart');
                        }
                        else{
                          print('writing posts failed line87 in updatepost.dart');
                        }
                      });
                      _post = docById;
                      _load = false;
                    });
                  }
                }
              });
            }
            // print(docById);

          } else {
            setState(() {
              _post = null;
              _load = false;
            });
          }
        });
      }
    });
  }

  Future<int> deletePost(
    UpdatePostsFormat _update,
    String _id,
    List<String> _subs,
  ) async {
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
            : _post == null
                ? Container(
                    child: Center(
                      child: Text('You have not created any posts'),
                    ),
                  )
                : Container(
                    child: ListView.builder(
                    itemCount: update.length,
                    itemBuilder: (BuildContext context, int index) {
                      // _post.
                      // print(_exists);
                      // print(_load);
                      return update[index].value['exists'] != null &&
                              update[index].value['exists'] == true
                          ? ListTile(
                              // dense: ,
                              title: Text(
                                  update[index].value['title'].toString()),
                              subtitle: Text(
                                  update[index].value['message'].toString()),
                              trailing: Wrap(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return UpdateN(update[index],
                                            widget._id, widget._subs,index);
                                      }));
                                    },
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        int statusCode = await deletePost(
                                          update[index],
                                          widget._id,
                                          widget._subs,
                                        );
                                        if (statusCode == 200) {
                                          setState(() {
                                            update[index].value['exists'] =
                                                false;
                                            _post[update[index].uid]['exists'] = false;
                                            print(_post[update[index].uid]);
                                            writeContent(
                                                'posts', json.encode(_post)).then((var v){
                                                  if(v){
                                                    Fluttertoast.showToast(
                                                msg: 'Delete Successful');
                                                  }
                                                  else{
                                                    Fluttertoast.showToast(
                                                msg: 'Delete Failed');
                                                  }
                                                });
                                            
                                          });
                                        } else {
                                          setState(() {
                                            Fluttertoast.showToast(
                                                msg: 'Deletion Failed!!');
                                          });
                                        }
                                      })
                                ],
                              ),
                            )
                          : Container();
                    },
                  )));
  }

  // Widget cardForUpdate() {}
}

converToString(List<dynamic>tags){
  String v ='';
  for(var i=0;i<tags.length;i++){
    if(i==0){
      v= tags[i].toString();
      continue;
    }
    v = v + ';' + tags[i].toString();
    // print(i);
  }
  print(v);
  return v;
}
class UpdateN extends StatefulWidget {
  final String _id;
  final UpdatePostsFormat _update;
  final int index;
  final List<String> _subs;
  UpdateN(this._update, this._id, this._subs,this.index);
  @override
  _UpdateNState createState() => _UpdateNState();
}

class _UpdateNState extends State<UpdateN> {
  final _formKey = GlobalKey<FormState>();
  String _title;
  String _body;
  List<String> tags = List();
  // String _subtitile;
  String _tag;
  String _url;
  String _council ;
  String _author ;
  String _message;
  File _image;
  // String _uid;
  createMake(var _response) async {
    await readContent('posts').then((var v) async {
      if (v != null) {
        if (v.containsKey(_response.uid)) {
          v[_response.uid] = _response.value as dynamic;
          setState(() {
              update[widget.index] = UpdatePostsFormat(uid: _response.uid,value: _response.value);
            });
        } else {
          v.putIfAbsent(_response.uid, () {
            return _response.value as dynamic;
          });
        }
        await writeContent('posts', jsonEncode(v)).then((bool mk) {
          if (mk) {
            readContent('posts').then((var v){
              print(v[_response.uid]);
            });
            
            Navigator.of(context).pop();
            return Fluttertoast.showToast(msg: 'Success');
          } else {
            return Fluttertoast.showToast(msg: 'Failed!');
          }
        });
      } else {
        Map<String, dynamic> _value = {_response.uid: _response.value};
        await writeContent('posts', jsonEncode(_value)).then((var v) {
          if (v) {
            Navigator.of(context).pop();
            return Fluttertoast.showToast(msg: 'Success');
          } else {
            return Fluttertoast.showToast(msg: 'Failed!');
          }
        });
      }
    });
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  var _errorMessage;
  validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      // _isLoading = true;
    });
    if (validateAndSave()) {
      // String userId = "";widget._
      try {
        tags = _tag.split(';');
        var _response = await upPostForNotifs(_title, _body, tags, widget._id,
            _url, _council, _author, _message, widget._subs, widget._update.uid);
        if (_response.statusCode != 200) {
          return Fluttertoast.showToast(
              msg: 'Can\'t process request at this time');
        } else {
          var fileExis = await fileExists('posts');
          if (!fileExis) {
            Map<String, dynamic> _value = {_response.uid: _response.value};
            print(_value);
            await writeContent('posts', jsonEncode(_value));
            Navigator.of(context).pop();
            return Fluttertoast.showToast(msg: 'Success');
          } else {
            createMake(_response);
          }
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          // _isLoading = false;
          _errorMessage = e.message;
          Fluttertoast.showToast(
              backgroundColor: Colors.grey[300],
              timeInSecForIos: 3,
              msg: _errorMessage,
              textColor: Colors.red,
              fontSize: 13.0);
          _formKey.currentState.reset();
          // Fluttertoast(

          // );
        });
      }
    }
  }
Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('upload_image/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        print(fileURL);
        _url = fileURL;
      });
      Fluttertoast.showToast(msg: 'Upload Successful!!');
      Navigator.of(context).pop();
    });
  }

  Future clearSelection() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('$_url');
    storageReference.delete().then((_) {
      Fluttertoast.showToast(msg: 'Removed Successfully');
    });
    // StorageUploadTask uploadTask = storageReference.putFile(_image);
  }
  @override
  Widget build(BuildContext context) {
    _url = widget._update.value['url'];
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Edit Posts'),
          // actions: <Widget>[
          //   new FlatButton(
          //       child: new Text('Logout',
          //           style: new TextStyle(fontSize: 17.0, color: Colors.white)),
          //       onPressed: signOut)
          // ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            //
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: new TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                initialValue: widget._update.value['title'],
                decoration: new InputDecoration(
                  labelText: 'Title',
                  hintText: 'Title of the Post',
                  // icon: new Icon(
                  //   Icons.mail,
                  //   color: Colors.grey,
                  // )
                ),
                validator: (value) =>
                    value.isEmpty ? 'Title can\'t be empty' : null,
                onSaved: (value) => _title = value,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: new TextFormField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                autofocus: false,
                initialValue: widget._update.value['body'],
                decoration: new InputDecoration(
                  labelText: 'Body',
                  hintText: 'Body of the post',
                  // icon: new Icon(
                  //   Icons.mail,
                  //   color: Colors.grey,
                  // )
                ),
                validator: (value) =>
                    value.isEmpty ? 'body can\'t be empty' : null,
                onSaved: (value) => _body = value,
              ),
            ),
            // Row(
            //   children: <Widget>[
            //     Container(
            //       width: 60.0,
            //       padding: const EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 0.0),
            //       child: new TextFormField(
            //         maxLines: 1,
            //         keyboardType: TextInputType.emailAddress,
            //         autofocus: false,
            //          readOnly: true,
            //         enabled: false,
            //         initialValue: widget._update.value['url'],
            //         decoration: new InputDecoration(
            //           labelText: 'Image Url',
            //           // icon: new Icon(
            //           //   Icons.mail,
            //           //   color: Colors.grey,
            //           // )
            //         ),
            //         validator: (value) =>
            //             value.isEmpty ? 'Images Field can\'t be empty' : null,
            //         onSaved: (value) => _url = value,
            //       ),
            //     ),
            //   ],
            // ),
            Container(
              // width: 100.0,
              // height: 100.0,
              width: MediaQuery.of(context).size.width,
              // padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: Wrap(
                children: <Widget>[
                  Container(
                      width: 250.0,
                      //image url to displayed and image tobe uploaded
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                      // child: new TextFormField(
                      //   maxLines: 1,
                      //   readOnly: true,
                      //   enabled: false,
                      //   initialValue: 'ghjjg',
                      //   keyboardType: TextInputType.emailAddress,
                      //   autofocus: false,
                      //   // onChanged: (_url) {
                      //   //   return _url;
                      //   // },
                      //   decoration: new InputDecoration(
                      //     labelText: 'Image Url',
                      //     // icon: new Icon(
                      //     //   Icons.mail,
                      //     //   color: Colors.grey,
                      //     // )
                      //   ),
                      //   validator: (value) =>
                      //       value.isEmpty ? 'Images Field can\'t be empty' : null,
                      //   onSaved: (_url) => _url,
                      // ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _url != null
                                ? SizedBox(
                                    height: 13.0,
                                  )
                                : SizedBox(height: 5.0),
                            _url != null
                                ? Text('Image Url',
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.grey))
                                : Text(''),
                            SizedBox(
                              height: 3.0,
                            ),
                            _url == null
                                ? Text(
                                    'Image Url',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  )
                                : Text(
                                    _url,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                            _url != null
                                ? SizedBox(
                                    height: 5.0,
                                  )
                                : SizedBox(height: 10.0),
                            Divider(color: Colors.grey)
                          ])),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15.0,
                    ),
                    child: IconButton(
                        icon: Icon(
                          Icons.add,
                          size: 30.0,
                        ),
                        onPressed: () {
                          return showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          _image != null
                                              ? Text('Selected Image',
                                                  style:
                                                      TextStyle(fontSize: 20.0))
                                              : Container(),
                                          _image != null
                                              ? SizedBox(
                                                  height: 10.0,
                                                )
                                              : SizedBox(),
                                          _image != null
                                              ? Container(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10.0),
                                                  height: 250.0,
                                                  child: Image.asset(
                                                      _image.path,
                                                      fit: BoxFit.fill))
                                              : Container(),
                                          _url == null
                                              ? RaisedButton(
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  30.0)),
                                                  child: Text(
                                                    _url == null &&
                                                            _image == null
                                                        ? 'Choose Image'
                                                        : 'Choose another',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  onPressed: () async {
                                                    await ImagePicker.pickImage(
                                                            source: ImageSource
                                                                .gallery)
                                                        .then((image) {
                                                      setState(() {
                                                        _image = image;
                                                      });
                                                    });
                                                  },
                                                  color: Colors.cyan,
                                                )
                                              : Container(),
                                          _image != null && _url == null
                                              ? RaisedButton(
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  30.0)),
                                                  child: Text(
                                                    'Upload Image',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  onPressed: uploadFile,
                                                  color: Colors.cyan,
                                                )
                                              : Container(),
                                          _image != null
                                              ? RaisedButton(
                                                  color: Colors.white,
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  30.0)),
                                                  child: Text(
                                                    'Clear Selection',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  onPressed: () {
                                                    print(_image.path);
                                                    if (_url == null) {
                                                      setState(() {
                                                        _image = null;
                                                        _url = null;
                                                      });
                                                    } else {
                                                      StorageReference
                                                          storageReference =
                                                          FirebaseStorage
                                                              .instance
                                                              .ref()
                                                              .child(
                                                                  'upload_image/${Path.basename(_image.path)}}');
                                                      storageReference
                                                          .delete()
                                                          .then((_) {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                'Removed Successfully');
                                                        setState(() {
                                                          _image = null;
                                                          _url = null;
                                                        });
                                                      });
                                                    }
                                                  })
                                              : Container(),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              });
                          // return UploadIMage(chooseFile, uploadFile);
                          // child:
                        }),
                  ),
                ],
              ),
            ),
            //council dropdown to make
           Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectCouncil.length,
                    itemBuilder: (BuildContext context, int index) {
                      // var _selected;
                      _council = 'SnT';
                      return DropdownButton(
                        itemHeight: 60.0,
                        hint: Text(
                            'Choose Council'), // Not necessary for Option 1
                        value: _council,
                        onChanged: (newValue) {
                          setState(() {
                            _council = newValue;
                          });
                        },
                        items: selectCouncil.map((location) {
                          return DropdownMenuItem(
                            child: new Text(location),
                            value: location,
                          );
                        }).toList(),
                      );
                    })),
            //tags to made
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: new TextFormField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                autofocus: false,
                initialValue: converToString(widget._update.value['tags']),
                decoration: new InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Separate all columns by semicolon',
                  // icon: new Icon(
                  //   Icons.mail,
                  //   color: Colors.grey,
                  // )
                ),
                validator: (value) =>
                    value.isEmpty ? 'Tags can\'t be empty' : null,
                onSaved: (value) {
                  _tag = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: new TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                initialValue: widget._update.value['message'],
                decoration: new InputDecoration(
                  labelText: 'Messsage',
                  hintText:
                      'Subtitile to be displayed in the notifications panel ',
                  // icon: new Icon(
                  //   Icons.mail,
                  //   color: Colors.grey,
                  // )
                ),
                validator: (value) =>
                    value.isEmpty ? 'Message can\'t be empty' : null,
                onSaved: (value) => _message = value,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: new TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                initialValue: widget._update.value['author'],
                decoration: new InputDecoration(
                  labelText: 'Uploader',
                  hintText: 'Name of the Uploader',
                  // icon: new Icon(
                  //   Icons.mail,
                  //   color: Colors.grey,
                  // )
                ),
                validator: (value) =>
                    value.isEmpty ? 'Name field can\'t be empty' : null,
                onSaved: (value) => _author = value,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: EdgeInsets.fromLTRB(100.0, 20.0, 100.0, 0.0),
              child: RaisedButton(
                
                shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.blue,
                  onPressed: () {
                    Fluttertoast.showToast(msg: 'Creating post');
                    // Fluttertoast.cancel();
                    validateAndSubmit();
                  },
                  child: Text('Update Post',
                  style:TextStyle(
                    color:Colors.white
                  ))),
            )
          ]),
        ));
  }
}

Future<Res> upPostForNotifs(
    String _title,
    String _body,
    List<String> tags,
    // String _subtitile,
    String _id,
    String _url,
    String _council,
    String _author,
    String _message,
    List<String> _subs,
    String uid) async {
  Map<String, String> headers = {"Content-type": "application/json"};
  // value = jsonEncode(value);
  var value = jsonEncode({
    'title': _title,
    'tags': tags,
    'council': _council.toLowerCase(),
    'sub': _subs,
    'body': _body,
    'author': _author,
    'url': _url,
    'owner': _id,
    'message': _message,
    // 'exists':true,
    // 'timeStamp': DateTime.now().toIso8601String(),
    'id': uid,
  });
  print(value);
  String json = '$value';
  String url = 'https://us-central1-notifier-snt.cloudfunctions.net/editPost';
  try {
    Response response = await post(url, headers: headers, body: json);
    int statusCode = response.statusCode;
    print(statusCode);
    print(response.body.toString());
    var value = jsonEncode({
      'title': _title,
      'tags': tags,
      'council': _council,
      'sub': _subs,
      'body': _body,
      'author': _author,
      'url': _url,
      'owner': _id,
      'message': _message,
      'exists': true,
      'timeStamp': DateTime.now().toIso8601String(),
      'id': response.body.toString(),
    });
    return Res(
        uid: response.body.toString(),
        statusCode: statusCode,
        value: jsonDecode(value));
  } catch (e) {
    print(e);
    return null;
  }
}
