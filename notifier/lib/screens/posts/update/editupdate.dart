
import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/posts/createposts.dart';
import 'package:notifier/screens/posts/update/updateposts.dart';
import 'package:notifier/services/databse.dart';
import 'package:notifier/services/function.dart';
import 'package:notifier/widget/adding_tags.dart';
import 'package:notifier/widget/chips.dart';
import 'package:path/path.dart' as Path;

class UpdateN extends StatefulWidget {
  final String _id;
  final UpdatePostsFormat _update;
  final int index;
  
  final List<String> _subs;
  UpdateN(this._update, this._id, this._subs, this.index);
  @override
  _UpdateNState createState() => _UpdateNState();
}

class _UpdateNState extends State<UpdateN> {
  final _formKey = GlobalKey<FormState>();
  String _title;
  String _body;
  List<dynamic> tags = List();
  String _tag;
  String _url;
  String _council;
   String _subs;
  String _author;
  String _message;
  File _image;
  bool _loadSubmit = false;
  final _tagController = TextEditingController();  
  final _imageController = TextEditingController();  
  // bool _firstSelected = true;
  bool _loadingWidget = false;
  Repository repo = Repository(allCouncilData);
  List<String> _councilList = [];
  List<String> _entityList = [];
  List<DropdownMenuItem<String>>_selectSub=[];
  void buildsubs(){
    _selectSub.clear();
    for (var i in widget._subs) {
      _selectSub.add(DropdownMenuItem(child: Text(i),
      value: i,
      ));
    }
  }
  // String _uid;
  createMake(var _response) async {
    await readContent('posts').then((var v) async {
      if (v != null) {
        if (v.containsKey(_response.uid)) {
          v[_response.uid] = _response.value as dynamic;
          setState(() {
            update[widget.index] =
                UpdatePostsFormat(uid: _response.uid, value: _response.value);
          });
        } else {
          v.putIfAbsent(_response.uid, () {
            return _response.value as dynamic;
          });
        }
        await writeContent('posts', jsonEncode(v)).then((bool mk) {
          if (mk) {
            readContent('posts').then((var v) {
              print(v[_response.uid]);
            });
            setState(() {
              _loadSubmit = false;
            });
            Navigator.of(context).pop();
            return Fluttertoast.showToast(msg: 'Success');
          } else {
            setState(() {
              _loadSubmit = false;
            });
            return Fluttertoast.showToast(msg: 'Failed!');
          }
        });
      } else {
        Map<String, dynamic> _value = {_response.uid: _response.value};
        await writeContent('posts', jsonEncode(_value)).then((var v) {
          if (v) {
            setState(() {
              _loadSubmit = false;
            });
            Navigator.of(context).pop();
            return Fluttertoast.showToast(msg: 'Success');
          } else {
            setState(() {
              _loadSubmit = false;
            });
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
    });
    if (validateAndSave()) {
      Fluttertoast.showToast(msg: 'Updating post');
      try {;
        var _response = await upPostForNotifs(
            _title,
            _body,
            tags,
            widget._id,
            _url,
            _council,
            _author,
            _message,
            [_subs],
            // widget._subs,
            widget._update.uid);
        if(_response == null){
          setState(() {
          _loadSubmit = false;
          _errorMessage = 'Error Check your Internet Connection';
          _formKey.currentState.reset();
        });
        
          Fluttertoast.showToast(
              backgroundColor: Colors.grey[300],
              timeInSecForIos: 3,
              msg: _errorMessage,
              textColor: Colors.red,
              fontSize: 13.0);
        }
        else{
          if (_response.statusCode != 200) {
          setState(() {
            _loadSubmit = false;
          });
          return Fluttertoast.showToast(
              msg: 'Can\'t process request at this time');
        } else {
          var fileExis = await fileExists('posts');
          if (!fileExis) {
            Map<String, dynamic> _value = {_response.uid: _response.value};
            print(_value);
            await writeContent('posts', jsonEncode(_value));
            setState(() {
              _loadSubmit = false;
            });
            Navigator.of(context).pop();
            return Fluttertoast.showToast(msg: 'Success');
          } else {
            createMake(_response);
          }
        }
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _loadSubmit = false;
          _errorMessage = e.message??'Error Updating Posts Check your Internet Connection';
          _formKey.currentState.reset();
        });
        
          Fluttertoast.showToast(
              backgroundColor: Colors.grey[300],
              timeInSecForIos: 3,
              msg: _errorMessage,
              textColor: Colors.red,
              fontSize: 13.0);
        
      }
    }else{
      setState(() {
        _loadSubmit = false;
      });
    }
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future<bool> uploadFile() async {
    setState(() {
      _loadingWidget = true;
    });
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('upload_image/${Path.basename(_image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    return storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        print(fileURL);
        _url = fileURL;
      });
      return true;
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
  void initState() {
    _councilList = List.from(_councilList)..addAll(repo.getCoordiCouncil());
     _entityList = List.from(_entityList)..addAll(repo.getEntityofCoordiByCouncil(widget._update.value['council']));
     _url = widget._update.value['url'];
    tags = widget._update.value['tags'];
    super.initState();
    buildsubs();
    
    _council = widget._update.value['council'];
    _subs = widget._update.value['sub'][0];
    // _tagController.addListener((){
      _tagController.text = converToString(widget._update.value['tags']);
      _imageController.text = (widget._update.value['url']);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Edit Posts'),
        ),
        body: Stack(
          children: <Widget>[
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  //
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: new TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      initialValue: widget._update.value['title'],
                      decoration: new InputDecoration(
                        labelText: 'Title',
                        hintText: 'Title of the Post',
                      ),
                      validator: (value) =>
                          value.isEmpty ? 'Title can\'t be empty' : null,
                      onSaved: (value) => _title = value,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: new TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      initialValue: widget._update.value['message'],
                      decoration: new InputDecoration(
                        labelText: 'Messsage',
                        hintText:
                            'Subtitile to be displayed in the notifications panel ',
                      ),
                      validator: (value) =>
                          value.isEmpty ? 'Message can\'t be empty' : null,
                      onSaved: (value) => _message = value,
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
                        helperText: 'ADD <a>...</a> if you want to make that text a link'
                        // counterText: 'ADD <a>...</a> if you want to make that text a link'
                      ),
                      validator: (value) =>
                          value.isEmpty ? 'body can\'t be empty' : null,
                      onSaved: (value) => _body = value,
                    ),
                  ),
                 
                  //council dropdown to make
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
                      child: DropdownButtonFormField(
                        isDense: true,
                        items: _councilList.map((location) {
                    return DropdownMenuItem(
                      child: new Text(convertToCouncilName(location)),
                      value: location,
                    );
                  }).toList(),
                        onChanged: (newValue) => _onSelectedCouncil(convertFromCouncilName(newValue)),
                        
                        hint: Text('Choose Council'),
                        value: _council ,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Council Field can\'t be empty'
                            : null,
                        onSaved: (value) => _council = convertFromCouncilName(value),
                      )),
                      Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
                  child: DropdownButtonFormField(
                    items: _entityList.map((location) {
                    return DropdownMenuItem(
                      child: new Text(location),
                      value: location,
                    );
                  }).toList(),
                    isDense: true,
                    onChanged: (newValue) => _onSelectedEntity(newValue),
                    hint: Text(
                              'Choose Club'),
                    value: _subs ,
                    validator: (value) =>
                     value ==null || value.isEmpty ? 'Club Field can\'t be empty' : null,
                    onSaved: (value)=>_subs = value,
                  )
            ),
                  //tags to made
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width - 150.0,
                          child: new TextFormField(
                            
                            maxLines: null,
                            controller: _tagController,
                            readOnly: true,
                            enabled: false,
                            keyboardType: TextInputType.multiline,
                            autofocus: false,
                            decoration: new InputDecoration(
                              labelText: 'Tags',
                              hintText: 'Click \'+\' button to add tags',
                            ),
                            onSaved: (value) {
                              _tag = value;
                            },
                          ),
                        ),
                        Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: IconButton(
                        tooltip: 'Add tags',
                          icon: Icon(
                            Icons.add,
                            size: 30.0,
                          ),
                          onPressed: () {
                            addingTag();
                          }),
                    )
                      ],
                    ),
                  ),
                   Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                           width: MediaQuery.of(context).size.width - 150.0,
                          child: new TextFormField(
                            maxLines: 1,
                            controller: _imageController,
                            readOnly: true,
                            enabled: false,
                            keyboardType: TextInputType.multiline,
                            autofocus: false,
                            decoration: new InputDecoration(
                              labelText: 'Image',
                              // hintText: 'Click \'+\' button to add Images',
                            ),
                            onSaved: (value) {
                              _url = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                          ),
                          child: IconButton(
                            tooltip: 'Add Image',
                            icon:Icon(
                                    Icons.add_a_photo,
                                    // size: 30.0,
                                  ),
                            // ),
                                onPressed: () {
                                  return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16.0)),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Stack(
                                                    alignment: AlignmentDirectional.center,
                                                    children: <Widget>[
                                                      Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            height: 20.0,
                                                          ),
                                                          _image != null || _url != null
                                                              ? Text('Selected Image',
                                                                  style: TextStyle(
                                                                      fontSize: 20.0))
                                                              : Container(),
                                                          _image != null || _url != null
                                                              ? SizedBox(
                                                                  height: 10.0,
                                                                )
                                                              : SizedBox(),
                                                          _image != null || _url != null
                                                              ? Container(
                                                                  padding: EdgeInsets.only(
                                                                      bottom: 10.0),
                                                                  height: 250.0,
                                                                  child: _url != null &&
                                                                          _image == null
                                                                      ? Image.network(_url,
                                                                          fit: BoxFit.fill)
                                                                      : Image.file(_image,
                                                                          fit: BoxFit.fill))
                                                              : Container(),
                                                          _url != null || _image == null
                                                              ? RaisedButton(
                                                                  shape: new RoundedRectangleBorder(
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
                                                                        color:
                                                                            Colors.white),
                                                                  ),
                                                                  onPressed: () async {
                                                                    if (_url != null) {
                                                                      StorageReference
                                                                          storageReference =
                                                                          await FirebaseStorage
                                                                              .instance
                                                                              .getReferenceFromUrl(
                                                                                  _url);
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
                                                                    await ImagePicker.pickImage(
                                                                            source:
                                                                                ImageSource
                                                                                    .gallery)
                                                                        .then((image) {
                                                                      setState(() {
                                                                        _image = image;
                                                                        print(_image);
                                                                      });
                                                                      // setState(() {

                                                                      // });
                                                                    });
                                                                  },
                                                                  color: Colors.cyan,
                                                                )
                                                              : Container(),
                                                          _image != null && _url != null
                                                              ? RaisedButton(
                                                                  shape: new RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          new BorderRadius
                                                                                  .circular(
                                                                              30.0)),
                                                                  child: Text(
                                                                    'Upload Image',
                                                                    style: TextStyle(
                                                                        color:
                                                                            Colors.white),
                                                                  ),
                                                                  onPressed: (){
                                                                    setState((){
                                                                      _loadingWidget = true;
                                                                    });
                                                                    uploadFile().then((bool status){
                                                                      if(status){
                                                                        setState((){
                                                                          _loadingWidget =false;
                                                                          
                                                                        });
                                                                        if(_url!=null){
                                                                          Fluttertoast.showToast(msg: 'Upload Successful!!');
                                                                          Navigator.of(context).pop();
                                                                        }
                                                                        else{
                                                                          Fluttertoast.showToast(msg: 'Can\'t process request at this time');
                                                                        }
                                                                      }
                                                                      
                                                                    });
                                                                  },
                                                                  color: Colors.cyan,
                                                                )
                                                              : Container(),
                                                          _image != null || _url != null
                                                              ? RaisedButton(
                                                                  color: Colors.white,
                                                                  shape: new RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          new BorderRadius
                                                                                  .circular(
                                                                              30.0)),
                                                                  child: Text(
                                                                    'Clear Selection',
                                                                    style: TextStyle(
                                                                        color:
                                                                            Colors.black),
                                                                  ),
                                                                  onPressed: () async {
                                                                    print(_image);
                                                                    print(_url);
                                                                    if (_image != null &&
                                                                        _url == null) {
                                                                      setState(() {
                                                                        _image = null;
                                                                        _url = null;
                                                                        print(_url);
                                                                      });
                                                                    } else if(_url != null) {
                                                                      StorageReference
                                                                          storageReference =
                                                                         await FirebaseStorage
                                                                              .instance
                                                                              .getReferenceFromUrl(_url);
                                                                      storageReference
                                                                          .delete()
                                                                          .then((_) {
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                'Removed Successfully');
                                                                        setState((){
                                                                          _image=null;
                                                                          _url =null;
                                                                        });
                                                                      });
                                                                    }
                                                                  })
                                                              : Container(),
                                                        ],
                                                      ),
                                                      _loadingWidget?Center(child: CircularProgressIndicator(),):Container()
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      });
                                  // return UploadIMage(chooseFile, uploadFile);
                                  // child:
                                },
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget._update.value['author'] ==null ? Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: new TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      initialValue: widget._update.value['author'],
                      decoration: new InputDecoration(
                        labelText: 'Uploader',
                        hintText: 'Name of the Uploader',
                      ),
                      validator: (value) =>
                          value.isEmpty ? 'Name field can\'t be empty' : null,
                      onSaved: (value) => _author = value,
                    ),
                  
                  ):Container(),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding: EdgeInsets.fromLTRB(100.0, 20.0, 100.0, 0.0),
                    child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        // color: Colors.blue,
                        onPressed: () {
                          
                          // Fluttertoast.cancel();
                          setState(() {
                            _loadSubmit = true;
                          });
                          validateAndSubmit();
                        },
                        child: Text('Update Post',
                            style: TextStyle(color: Colors.white,
                            
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                            ))),
                  )
                ]),
              ),
            ),
            _loadSubmit
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ],
        ));
  }
  void _onSelectedCouncil(String value) {
    if( _council!=value){
      setState(() {
      // _selectedEntity = "Choose ..";
      // _entity = ["Choose .."];
      _council = value;
      _subs = null;
      if(_entityList.length!=0){
        _entityList.clear();
      }
      _entityList = List.from(_entityList)..addAll(repo.getEntityofCoordiByCouncil(value));
    });
    }
  }

  void _onSelectedEntity(String value) {
    setState(() {
      _subs = value;
    });
  }
  addingTag() {
    return showModalBottomSheet(
        context: (context),
        builder: (BuildContext context) {
          return AddingTags(_tag, tags, _tagController);
          // final _formKey = GlobalKey<FormState>();
          // String addTag;
          
          // return CupertinoActionSheet(
          //   actions: <Widget>[
          //     Container(
          //       margin: EdgeInsets.symmetric(horizontal: 100.0),
          //       child: RaisedButton(
          //          shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30.0),
          //         ),
          //           child: Text('Add Tags',
          //           style: TextStyle(
          //             color: Colors.white
          //           )
          //           ),
          //           onPressed: () {
          //             showDialog(context: context, builder: (BuildContext context){
          //               return AlertDialog(
          //                 title: Text('Add tag'),
          //                 content: Form(
          //                   key: _formKey,
          //                     child:  Container(
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         children: <Widget>[
          //           Padding(
          //             padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          //             child: Material(
          //               color: Colors.transparent,
          //                 child: TextFormField(
          //                   maxLines: 1,
          //                   keyboardType: TextInputType.text,
          //                   autofocus: false,
          //                   decoration: new InputDecoration(
          //                     labelText: 'Tag',
          //                   ),
          //                   validator: (value) => value.isEmpty
          //                     ?'Tags can\'t be empty'
          //                       : null,
          //                   onSaved: (value) {
          //                     addTag = value;
          //                     // _tag = value.toString() + ' ;';
          //                     // tags.add(value);
          //                   }
          //                 ),
          //             ),
          //           ),
          //           Container(
          //             padding: EdgeInsets.only(bottom: 5.0, top: 25.0),
          //             // height: 100.0,
          //             child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.end,
          //                   children: <Widget>[
          //                     FlatButton(
          //                         shape: new RoundedRectangleBorder(
          //                             borderRadius:
          //                                 new BorderRadius.circular(30.0)),
          //                         // color: Colors.blue,
          //                         onPressed: () {
          //                           Navigator.of(context).pop();
          //                         },
          //                         child: Text('Dismiss')),
          //                     Padding(
          //                       padding: const EdgeInsets.only(left: 5.0),
          //                       child: RaisedButton(
          //                           shape: new RoundedRectangleBorder(
          //                               borderRadius:
          //                                   new BorderRadius.circular(30.0)),
          //                           // color: Colors.blue,
          //                           onPressed: () {
          //                             // Fluttertoast.showToast(msg: 'Creating post');
          //                             // Fluttertoast.cancel();
          //                             // print(createTagsToList(tags[0]));
          //                             // tags = _tag.split(';');
          //                             if (_formKey.currentState.validate()) {
          //                               _formKey.currentState.save();
          //                               setState(() {
          //                                 // tagForChip!=null?tagForChip += addTag + ' ;' : tagForChip = addTag + ' ;';
          //                                 tags.add(addTag);
          //                               });
          //                               Navigator.of(context).pop();
          //                               // confirmPage();
          //                             }
          //                           },
          //                           child: Text(
          //                             'Add Tag',
          //                             style: TextStyle(color: Colors.white),
          //                           )),
          //                     ),
          //                   ]),
          //           )
          //           // )
          //         ],
          //         // )
          //       ),
          //     ), 
          //                 ),
          //               );
          //             });
          //           }),
          //     ),
          //   ],
          //   message: CreateChips(this._tag,this.tags),
          //   cancelButton: Column(
          //     children: <Widget>[
          //       RaisedButton(
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30.0),
          //         ),
          //         onPressed: () {
          //           setState(() {
                      
          //             // print(tagsForChips);
          //             _tag??='';
          //             _tag!=null || _tag != ''? _tag =_tag:_tag = '';
          //             for (var i in tags) {
          //               _tag += i + '; ';
          //             }
          //             // _tag = tagForChip;
          //             // tags = tagsForChips;
          //             _tagController.text = _tag;
          //             print(_tag + ':tags line807');
          //           });
          //           Navigator.of(context).pop();
          //         },
          //         child: Text('Done',
          //         style: TextStyle(
          //             color: Colors.white
          //           ),),
          //       ),
          //     ],
          //   ),
          // );
        });
}

Future<Res> upPostForNotifs(
    String _title,
    String _body,
    List<dynamic> tags,
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
  String url = 'https://us-central1-notifier-phase-2.cloudfunctions.net/editPost';
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
}
