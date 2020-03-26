import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/services/databse.dart';
import 'package:path/path.dart' as Path;
import 'package:notifier/services/function.dart';

class CreatePosts extends StatefulWidget {
  final String _id;
  final List<String> _subs;
  CreatePosts(this._id, this._subs);
  @override
  _CreatePostsState createState() => _CreatePostsState();
}

var selectCouncil = ['SnT'];
File _image;

class _CreatePostsState extends State<CreatePosts> {
  final _formKey = GlobalKey<FormState>();
  String _title;
  String _body;
  List<String> tags = List();
  String _tag;
  // String _subtitile;
  String _url;
  String _council;
  String _author;
  String _message;

  // String

  Future<int> createMake(Res _response) async {
    return await readContent('posts').then((var v) async {
      if (v != null) {
        if (v.containsKey(_response.uid)) {
          v.update(_response.uid, _response.value);
        } else {
          v.putIfAbsent(_response.uid, () {
            return _response.value;
          });
        }
        return await writeContent('posts', jsonEncode(v)).then((bool mk) async {
          if (mk) {
            return await readPeople().then((var v) async {
              print(v);
              if (v != null) {
                v['posts'].add(_response.uid);
                print(v['posts']);
                await writeContent('people', json.encode(v)).then((bool vb) {
                  if (vb) {
                    Fluttertoast.showToast(msg: 'Success');
                    return 0;
                  } else {
                    Fluttertoast.showToast(msg: 'Failed!');
                    return 1;
                  }
                });
              }
              return 1;
            });
          } else {
            Fluttertoast.showToast(msg: 'Failed!');
            return 1;
          }
        });
      } else {
        Map<String, dynamic> _value = {_response.uid: _response.value};
        return await writeContent('posts', jsonEncode(_value))
            .then((var v) async {
          if (v) {
            return await readPeople().then((var v) async {
              print(v);
              if (v != null) {
                v['posts'].add(_response.uid);
                print(v['posts']);
                await writeContent('people', json.encode(v)).then((bool vb) {
                  if (vb) {
                    Fluttertoast.showToast(msg: 'Success');
                    return 0;
                  } else {
                    Fluttertoast.showToast(msg: 'Failed!');
                    return 0;
                  }
                });
              }
              return 1;
            });
          } else {
            Fluttertoast.showToast(msg: 'Failed!');
            return 0;
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
  Future<int> validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      // _isLoading = true;
    });
    if (validateAndSave()) {
      // String userId = "";
      try {
        tags = _tag.split(';');
        var _response = await createPostForNotifs(_title, _body, tags,
            widget._id, _url, _council, _author, _message, widget._subs);
        if (_response.statusCode != 200) {
          Fluttertoast.showToast(
              msg: 'Can\'t process request at now please try again later');
          return 1;
        } else {
          await fileExists('posts').then((bool fileExis) async {
            print(fileExis);
            if (!fileExis) {
              Map<String, dynamic> _value = {_response.uid: _response.value};
              print(_value);
              await writeContent('posts', jsonEncode(_value))
                  .whenComplete(() async {
                await readPeople().then((var v) async {
                  print(v);
                  if (v != null) {
                    v['posts'].add(_response.uid);
                    print(v['posts']);
                    await writeContent('people', json.encode(v));
                  }
                });
              });

              Fluttertoast.showToast(msg: 'Success');
              return 0;
            } else {
              return createMake(_response);
            }
          });

          return 0;
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
          return 1;
          // );
        });
      }
    }
    return 1;
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
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Create Posts'),
          // actions: <Widget>[
          //   new FlatButton(
          //       child: new Text('Logout',
          //           style: new TextStyle(fontSize: 17.0, color: Colors.white)),
          //       onPressed: signOut)
          // ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(shrinkWrap: true, children: <Widget>[
            //
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: new TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
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
                // maxLines: 1,
                // textInputAction: TextInputAction.newline,
                maxLines: null,
                // expands: true,
                keyboardType: TextInputType.multiline,
                autofocus: false,
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
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: new TextFormField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                autofocus: false,

                decoration: new InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Separate all columns by semicolon',
                ),
                // validator: (value) => value.isEmpty
                //     ? 'Tags can\'t be empty'
                //     : null,
                onSaved: (value) {
                  // tags.clear();
                  // if (value == null || value.replaceAll(' ', '') == null ){
                  //   tags = [
                  //     '',
                  //   ];
                  // }
                  // else{
                  _tag = value;
                  // }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: new TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
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
              padding: EdgeInsets.fromLTRB(100.0, 20.0, 100.0, 0.0),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(16.0),
              // ),
              child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.blue,
                  onPressed: () async {
                    
                    // Fluttertoast.cancel();
                    // print(createTagsToList(tags[0]));
                    // tags = _tag.split(';');
                    if(validateAndSave()){
                      confirmPage();
                    }
                  },
                  child: Text('Create Post',
                    style: TextStyle(
                      color:Colors.white
                    ),
                  )),
            )
          ]),
        ));
  }

  confirmPage() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return card();
        });
  }

  Widget card() {
    var time = DateFormat('d MMMM, yyyy : kk:mm').format(DateTime.now());
    // print((DateTime.parse(timenot['timeStamp']));
    // print()
    // print(time);

    return  Dialog(
      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.white,
        ),
        height:420.0,
        width: 450.0,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Title(color: Colors.black, child: Text('Preview',
              style: TextStyle(
                fontSize: 30.0
              ),
              )),
            Card(
                  elevation: 5.0,
                  margin: EdgeInsets.symmetric(vertical: 16.0),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  clipBehavior: Clip.antiAlias,
                  // child: Padding(
                  // padding: const EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 0.0),
                  child: Container(
                      height: 300.0,
                      width: 250.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Hero(
                                tag: 'tag',
                                // child: Image.network(
                                //   timenot['url'],
                                //   fit: BoxFit.fill,
                                // ),
                                child: Image.asset(_image.path, fit: BoxFit.fill)),
                          ),
                          // Positioned(
                          Positioned(
                            top: 20.0,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          16.0, 0.0, 10.0, 0.0),
                                      // padding: EdgeInsets.symmetric(horizontal: 10.0),

                                      child: Text(
                                        _title,
                                        style: TextStyle(
                                            fontSize: 20.0, color: Colors.white),
                                      ),
                                    ),
                                    Chip(
                                      backgroundColor: Colors.green[900],
                                      label: Row(
                                        children: <Widget>[
                                          // Icon(
                                          //   Icons.attachment,
                                          //   size: 20.0,
                                          // ),
                                          Text(
                                            widget._subs[0],
                                            style: TextStyle(color: Colors.white,
                                              fontSize: 10.0
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 00.0,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 10.0),
                                color: Colors.black.withOpacity(0.4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        child: Text(
                                          _message,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxHeight: 100.0,
                                          minWidth: 300.0,
                                          maxWidth: 300.0),

                                      // color: Colors.blue,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            5.0, 5.0, 0.0, 0.0),
                                        child: Text('Tags : ' + _tag,
                                            style: TextStyle(color: Colors.white,
                                            fontSize: 12.0)),
                                        // ),
                                      ),
                                    ),
                                    Container(
                                      // color: Colors.black.withOpacity(0.4),
                                      padding: const EdgeInsets.fromLTRB(
                                          2.0, 15.0, 0.0, 0.0),
                                      child: Text(
                                        time,
                                        style: TextStyle(color: Colors.white,
                                        fontSize: 10.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Positioned(
                          //     bottom: 40.0,
                          //     child: Container(
                          //       height:80.0,
                          //       width: 295.0,
                          //       // color: Colors.blue,
                          //       child: Wrap(
                          //         // child: Text('jhfgv')
                          //         children: _buildChoice(timenot),
                          //       ),
                          //     )),
                          // Align(
                          //   alignment:Alignment.bottomLeft
                          // )
                          // Positioned(
                          //   bottom: 10.0,
                          //   child: Container(
                          //     color: Colors.black.withOpacity(0.4),
                          //      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 0.0),
                          //     child: Text(time,style: TextStyle(
                          //              color: Colors.white),
                          //       ),),
                          // )
                        ],
                      )
                      // )
                      ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  // color: Colors.blue,
                  onPressed: () {
                    // Fluttertoast.showToast(msg: 'Creating post');
                    // Fluttertoast.cancel();
                    // print(createTagsToList(tags[0]));
                    // tags = _tag.split(';');
                    Navigator.of(context).pop();
                    // if(validateAndSave()){
                    //   confirmPage();
                    // }
                  },
                  child: Text('Dismiss')),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: RaisedButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.blue,
                    onPressed: () async {
                      Fluttertoast.showToast(msg: 'Creating post');
                      // Fluttertoast.cancel();
                      // print(createTagsToList(tags[0]));
                      // tags = _tag.split(';');
                      if(validateAndSave()){
                        confirmPage();
                      }
                    },
                    child: Text('Create Post',
                      style: TextStyle(
                        color: Colors.white
                      ),
                    )),
                  ),
              ]
            )
          ],
        ),
      ),
    );
  }
}

class UploadIMage extends StatefulWidget {
  // final String _url;
  // final File _image;
  final void Function() chooseFile;
  final void Function() uploadFile;
  UploadIMage(this.chooseFile, this.uploadFile);
  @override
  _UploadIMageState createState() => _UploadIMageState();
}

class _UploadIMageState extends State<UploadIMage> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        Text('Selected Image'),
        _image != null
            ? Image.asset(
                _image.path,
                height: 150,
              )
            : Container(),
        _image == null
            ? RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                child: Text(
                  'Choose File',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: widget.chooseFile,
                color: Colors.blue,
              )
            : Container(),
        _image != null
            ? RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                child: Text(
                  'Upload File',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: widget.uploadFile,
                color: Colors.blue[900],
              )
            : Container(),
        _image != null
            ? RaisedButton(
                color: Colors.black,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                child: Text(
                  'Clear Selection',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    _image = null;
                  });
                },
              )
            : Container(),
        // ]
        // )]
      ],
    );
  }
}

Future<Res> createPostForNotifs(
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
) async {
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
  });
  print(value);
  String json = '$value';
  String url = 'https://us-central1-notifier-snt.cloudfunctions.net/makePost';
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
      'uid': response.body.toString(),
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

//https://us-central1-notifier-snt.cloudfunctions.net/editPost
//https://us-central1-notifier-snt.cloudfunctions.net/deletePost
