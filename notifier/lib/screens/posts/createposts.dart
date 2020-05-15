import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/shared/preview.dart';
import 'package:notifier/widget/add_image.dart';
import 'package:notifier/widget/adding_tags.dart';
import 'package:notifier/widget/chips.dart';
import 'package:path/path.dart' as Path;
import 'package:notifier/services/function.dart';

class CreatePosts extends StatefulWidget {
  final String _id;
  final List<String> _subs;
  final String name;
  CreatePosts(this._id, this._subs,this.name);
  @override
  _CreatePostsState createState() => _CreatePostsState();
}

class _CreatePostsState extends State<CreatePosts> {
  String tagForChip;
List<String> tagsForChips =[];
  final _formKey = GlobalKey<FormState>();
  String _title;
  String _body;
  List<String> tags = List();
  String _tag;
  final _tagController = TextEditingController();  // String _subtitile;
  final _imageController = TextEditingController();  
  String _url;
  String _council;
  String _subs;
  String _author;
  String _message;
  File _image = null;
  // bool _firstSelected = false;
  bool _loadingWidget = false;
  // bool _loadingSubmit = false;
  Repository repo = Repository(allCouncilData);
  List<String> _councilList = [];
  List<String> _entityList = [];
  List<DropdownMenuItem<String>> _selectSub = [];
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // var _errorMessage;

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
    Fluttertoast.showToast(msg: 'Uploading Image');
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
        _imageController.text = fileURL;
        _loadingWidget = false;
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
  // void buildsubs(){
@override
  void initState() {
    _councilList = List.from(_councilList)..addAll(repo.getCoordiCouncil());
    super.initState();
    _tagController.addListener((){
      _tagController.value = _tagController.value.copyWith(
        text:_tag
      );
    });
    _imageController.addListener((){
      _imageController.value = _imageController.value.copyWith(
        text: _url
      );
    });
  }
  @override
  void dispose() {
    super.dispose();
    _tagController.dispose();
  }
  // }
  @override
  Widget build(BuildContext context) {
    _selectSub.clear();
    // print(widget._subs);
    for (var i in widget._subs) {
      // print(i);
      if (_selectSub.length != 0) {
        _selectSub.forEach((f) {
          if (f.value != i) {
            print(i);

            // _selectSub.remove(f);
          }
        });
      }
      if (!_selectSub.contains(DropdownMenuItem(
        child: Text(i),
        value: i,
      ))) {
        _selectSub.add(DropdownMenuItem(
          child: Text(i),
          value: i,
        ));
      }
    }
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Create Posts'),
        ),
        body: Form(
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
                  decoration: new InputDecoration(
                    labelText: 'Title',
                    hintText: 'Title of the Post',
                  ),
                  validator: (value) =>
                      value.isEmpty ? 'Title can\'t be empty' : null,
                  onSaved: (value) => _title = value,
                  onChanged: (value) => _title = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                child: new TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  onChanged: (value) {
                    _message = value;
                  },
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
                  decoration: new InputDecoration(
                    labelText: 'Body',
                    hintText: 'Body of the post',
                  ),
                  validator: (value) =>
                      value.isEmpty ? 'body can\'t be empty' : null,
                  onSaved: (value) => _body = value,
                  onChanged: (value) => _body = value,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                  child: DropdownButtonFormField(
                    items: _councilList.map((location) {
                    return DropdownMenuItem(
                      child: new Text(convertToCouncilName(location)),
                      value: location,
                    );
                  }).toList(),
                    isDense: true,
                    onChanged: (newValue) => _onSelectedCouncil(convertFromCouncilName(newValue)),
                    hint: Text('Choose Council'),
                    value: _council,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Council Field can\'t be empty'
                        : null,
                    onSaved: (value) => _council = convertFromCouncilName(value),
                  )),
              // _firstSelected ?
              _council!=null ?Padding(
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
                    hint: Text('Choose Entity'),
                    value: _subs,
                    validator: (value) => value == null || value.isEmpty
                        ? 'This field is required'
                        : null,
                    onSaved: (value) => _subs = value,
                )):Container(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                child: Row(
                  children: <Widget>[
                    // Text
                    Container(
                      width: MediaQuery.of(context).size.width - 150.0,
                      child: new TextFormField(
                        // textInputAction: ,
                        maxLines: null,
                        controller: _tagController,
                        keyboardType: TextInputType.multiline,
                        autofocus: false,
                        readOnly: true,
                        // initialValue: _tag,
                        onChanged: (value) {
                          // _tag = value;
                          return _tag;
                        },
                        decoration: new InputDecoration(
                          labelText: 'Tags',
                          // prefixText:  _tag == null ||_tag.trim() == null? null : _tag,
                          // filled: ,
                          // enabled: false,
                          hintText: _tag == null || _tag.trim() == null?'Click \'+\' button to add tags' : null,
                        ),
                        onSaved: (value) {
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
                            // BottomSheet(onClosing: null, builder: null)
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
                          ),),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                      ),
                      child: IconButton(
                          icon: Icon(
                            Icons.add_a_photo,
                            // size: 30.0,
                          ),
                          onPressed: () {
                            return showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  print(_url);
                                  print(_image);
                                  return /*StatefulBuilder(
                                    builder: (context, setState) {
                                      return*/ AddImage(_image,
                                        _imageController,
                                        // uploadFile: ,
                                      _url,addingImage
                                      );
                                      // return WillPopScope(
                                      //   onWillPop: () async {
                                      //     return Navigator.of(context).pop(_loadingWidget);
                                      //   },
                                      //   child: AlertDialog(
                                      //     content: Column(
                                      //       mainAxisSize: MainAxisSize.min,
                                      //       mainAxisAlignment: MainAxisAlignment.end,
                                      //       children: <Widget>[
                                      //         Stack(
                                      //           alignment:
                                      //               AlignmentDirectional.center,
                                      //           children: <Widget>[
                                      //             Column(
                                      //               mainAxisSize:
                                      //                   MainAxisSize.min,
                                      //               children: <Widget>[
                                      //                 SizedBox(
                                      //                   height: 20.0,
                                      //                 ),
                                      //                 _image != null
                                      //                     ? Text(
                                      //                         'Selected Image',
                                      //                         style: TextStyle(
                                      //                             fontSize:
                                      //                                 20.0))
                                      //                     : Container(),
                                      //                 _image != null
                                      //                     ? SizedBox(
                                      //                         height: 10.0,
                                      //                       )
                                      //                     : SizedBox(),
                                      //                 _image != null
                                      //                     ? Container(
                                      //                         padding: EdgeInsets.only(bottom:10.0),
                                      //                         height: 250.0,
                                      //                         child: Image.file(_image),
                                      //                       )
                                      //                     : Container(),
                                      //                 _url == null
                                      //                     ? RaisedButton(
                                      //                         shape: new RoundedRectangleBorder(
                                      //                             borderRadius:
                                      //                                 new BorderRadius
                                      //                                         .circular(
                                      //                                     30.0)),
                                      //                         child: Text(
                                      //                           _url == null &&
                                      //                                   _image ==
                                      //                                       null
                                      //                               ? 'Choose Image'
                                      //                               : 'Choose another',
                                      //                           style: TextStyle(
                                      //                               color: Colors
                                      //                                   .white),
                                      //                         ),
                                      //                         onPressed:
                                      //                             () async {
                                      //                           await ImagePicker.pickImage(
                                      //                                   source: ImageSource
                                      //                                       .gallery)
                                      //                               .then(
                                      //                                   (image) {
                                      //                             setState(() {
                                      //                               _image =image;
                                      //                             });
                                      //                           });
                                      //                         },
                                      //                         color:
                                      //                             Colors.cyan,
                                      //                       )
                                      //                     : Container(),
                                      //                 _image != null &&
                                      //                         _url == null
                                      //                     ? RaisedButton(
                                      //                         shape: new RoundedRectangleBorder(
                                      //                             borderRadius:
                                      //                                 new BorderRadius
                                      //                                         .circular(
                                      //                                     30.0)),
                                      //                         child: Text(
                                      //                           'Upload Image',
                                      //                           style: TextStyle(
                                      //                               color: Colors
                                      //                                   .white),
                                      //                         ),
                                      //                         onPressed: () {
                                      //                           setState(() {
                                      //                             _loadingWidget =
                                      //                                 true;
                                      //                           });
                                      //                           uploadFile().then((bool status) {
                                      //                             if (status) {
                                      //                               Fluttertoast.showToast(
                                      //                                       msg:
                                      //                                           'Upload Successful!!');
                                      //                               Navigator.of(context).pop();
                                      //                               setState(() {
                                      //                                 _loadingWidget =false;
                                      //                               });
                                      //                             }
                                      //                           });
                                      //                         },
                                      //                         color:Colors.cyan,
                                      //                       )
                                      //                     : Container(),
                                      //                 _image != null
                                      //                     ? RaisedButton(
                                      //                         color:
                                      //                             Colors.white,
                                      //                         shape: new RoundedRectangleBorder(
                                      //                             borderRadius:
                                      //                                 new BorderRadius
                                      //                                         .circular(
                                      //                                     30.0)),
                                      //                         child: Text(
                                      //                           'Clear Selection',
                                      //                           style: TextStyle(
                                      //                               color: Colors
                                      //                                   .black),
                                      //                         ),
                                      //                         onPressed: () {
                                      //                           print(_image
                                      //                               .path);
                                      //                           if (_url ==
                                      //                               null) {
                                      //                             setState(() {
                                      //                               _image =
                                      //                                   null;
                                      //                               _url = null;
                                      //                               _imageController.text = null;
                                      //                             });
                                      //                           } else {
                                      //                             StorageReference
                                      //                                 storageReference =
                                      //                                 FirebaseStorage.instance.ref().child(
                                      //                                         'upload_image/${Path.basename(_image.path)}');
                                      //                             storageReference
                                      //                                 .delete()
                                      //                                 .then(
                                      //                                     (_) {
                                      //                               Fluttertoast
                                      //                                   .showToast(
                                      //                                       msg:
                                      //                                           'Removed Successfully');
                                      //                               setState(
                                      //                                   () {
                                      //                                 _image =null;
                                      //                                 _url =null;
                                      //                                 _imageController.text = null;
                                      //                               });
                                      //                             });
                                      //                           }
                                      //                         })
                                      //                     : Container(),
                                      //               ],
                                      //             ),
                                      //             _loadingWidget
                                      //                 ? Center(
                                      //                     child:Container(
                                      //                       child: CircularProgressIndicator()),
                                      //                   )
                                      //                 : Container(),
                                      //           ],
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // );
                                  //   },
                                  // );
                                });
                            // return UploadIMage(chooseFile, uploadFile);
                            // child:
                          }),
                    ),
                      ]
                    )
                    ),
              //council dropdown to make
              
              widget.name ==null? Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                child: new TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.text,
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
                  onChanged: (value) => _author = value,
                ),
              ):Container(),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0,0.0),
              //   child :RaisedButton(onPressed: (){
              //     return showDatePicker(context: context,
              //      initialDate: DateTime.now(),
              //       firstDate: DateTime(2020), lastDate: DateTime(2030),
              //       builder: (BuildContext context,Widget wigd){
              //         // return Theme(data: ThemeData.dark(), 
              //         // child: wigd);
              //         return CupertinoActionSheet(
              //           title:Text('Select Date'),
              //           message: Container(
              //             height:MediaQuery.of(context).size.height*0.4,
              //             child: CupertinoDatePicker(
              //               minimumDate: DateTime.now(),
              //               initialDateTime: DateTime.now(),
              //               onDateTimeChanged: (v){

              //             }),
              //           ),
              //         );
              //       }
              //       );
              //   })
                
                
                 
              // ),
              // Padding(padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0,0.0),
              //   child : CupertinoDatePicker(
              //     initialDateTime: DateTime.now(),
              //     onDateTimeChanged: (DateTime v){
              //       var time = v;
              //       print(v);
              //   },
              //   )
              // ),
              Container(
                padding: EdgeInsets.fromLTRB(100.0, 20.0, 100.0, 0.0),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(16.0),
                // ),
                child: RaisedButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    // color: Colors.blue,
                    onPressed: () async {
                      if (validateAndSave()) {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return Preview(0, {
                            'title': _title,
                            'tags': tags,
                            'council': _council.toLowerCase(),
                            'sub': [_subs],
                            'body': _body,
                            'author': widget.name??_author,
                            'url': _url,
                            'owner': widget._id,
                            'message': _message,
                          },'create');
                        }));
                      }
                      // validateAndSubmit();
                    },
                    child: Text(
                      'Preview',
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ]),
          ),
        ));
  }
  void addingImage(File image,String url){
    setState(() {
      _image = image;
      _url = url;
      _imageController.text = url;
    });
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
  // void addingvalue(List<dynamic>_tags,String tag){
  //   setState(() {
  //     _tag ??= '';
  //     _tag != null || _tag != ''
  //     ? _tag = tag??''
  //     : _tag = '';
  //     for (var i in _tags) {
  //       if(i.toString()!=null){
  //         _tag += i.toString() + '; ';
  //       }
  //     }
  //     _tagController.text = _tag;
  //   });
  // }
  addingTag() {
    List<dynamic> newTag = [];
    setState(() {
       newTag = tags;
    });
    return showModalBottomSheet(
        context: (context),
        builder: (context) {
          // print(_tag.toString()+ ' \'\' tags value');
          // return AddingTags(this._tag, this.tags, _tagController,addingvalue);
          final _formKey = GlobalKey<FormState>();
          String addTag;
          
          return CupertinoActionSheet(
            actions: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 100.0),
                child: RaisedButton(
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                    child: Text('Add Tags',
                    style: TextStyle(
                      color: Colors.white
                    )),
                    onPressed: () {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: Text('Add tag'),
                          content: Form(
                            key: _formKey,
                              child:  Container(

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: Material(
                        color: Colors.transparent,
                          child: TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            decoration: new InputDecoration(
                              labelText: 'Tag',
                            ),
                            validator: (value) => value.isEmpty
                              ?'Tags can\'t be empty'
                                : null,
                            onSaved: (value) {
                              addTag = value;
                              // _tag = value.toString() + ' ;';
                              // tags.add(value);
                            }
                          ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 0.0, top: 25.0,left:0.0),
                      // height: 100.0,
                      child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              FlatButton(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  // color: Colors.blue,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Dismiss')),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: RaisedButton(
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0)),
                                    // color: Colors.blue,
                                    onPressed: () {
                                      // Fluttertoast.showToast(msg: 'Creating post');
                                      // Fluttertoast.cancel();
                                      // print(createTagsToList(tags[0]));
                                      // tags = _tag.split(';');
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();
                                        setState(() {
                                          // tagForChip!=null?tagForChip += addTag + ' ;' : tagForChip = addTag + ' ;';
                                          tagsForChips.add(addTag);
                                          newTag = tagsForChips;
                                        });
                                        Navigator.of(context).pop();
                                        // confirmPage();
                                      }
                                    },
                                    child: Text(
                                      'Add Tag',
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            ]),
                    )
                    // )
                  ],
                  // )
                ),
              ), 
                          ),
                        );
                      });
                    }),
              ),
            ],
            message: CreateChips(tagForChip,newTag),
            cancelButton: Column(
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    setState(() {
                      tagsForChips = newTag;
                      print(tagsForChips);
                      _tag = '';
                      for (var i in tagsForChips) {
                        _tag += i + '; ';
                      }
                      // _tag = tagForChip;
                      tags = tagsForChips;
                      _tagController.text = _tag;
                      print(_tag + ':tags line807');
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Done',
                  style: TextStyle(
                      color: Colors.white
                    ),),
                ),
              ],
            ),
          );
        });
  }
  // confirmPage() {
  //   var time = DateFormat('d MMMM, yyyy : kk:mm').format(DateTime.now());
  //   return showCupertinoDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(builder: (context,setState){

  //   // print((DateTime.parse(timenot['timeStamp']));
  //   // print()
  //   // print(time);

  //   return  CupertinoAlertDialog(
  //     // shape:
  //     //                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  //     title: Text('Preview',
  //                     style: TextStyle(
  //                       fontSize: 30.0
  //                     ),
  //                     ),
  //     content:
  //         Container(

  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(16.0),

  //           ),
  //           // height:420.0,
  //           // width: 450.0,
  //           child: Stack(
  //             children: <Widget>[
  //               Column(
  //                 mainAxisSize: MainAxisSize.max,
  //                 children: <Widget>[
  //                   // Icon(Icons.pu)
  //                   Card(
  //                         elevation: 5.0,
  //                         margin: EdgeInsets.symmetric(vertical: 16.0),
  //                         shape:
  //                             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  //                         clipBehavior: Clip.antiAlias,
  //                         // child: Padding(
  //                         // padding: const EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 0.0),
  //                         child: Container(
  //                             height: 300.0,
  //                             width: 250.0,
  //                             decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(16.0),
  //                             ),
  //                             child: Stack(
  //                               fit: StackFit.expand,
  //                               children: <Widget>[
  //                                 ClipRRect(
  //                                   borderRadius: BorderRadius.circular(16.0),
  //                                   child: Hero(
  //                                       tag: 'tag',
  //                                       // child: Image.network(
  //                                       //   timenot['url'],
  //                                       //   fit: BoxFit.fill,
  //                                       // ),
  //                                       child: Image.file(_image, fit: BoxFit.fill)),
  //                                 ),
  //                                 // Positioned(
  //                                 Positioned(
  //                                   top: 0.0,
  //                                   child: Container(
  //                                     padding: EdgeInsets.fromLTRB(0.0, 10.0, 10000.0, 0.0),
  //                     color: Colors.black.withOpacity(0.6),
  //                                     child: Align(
  //                                       alignment: Alignment.topLeft,
  //                                       child: Container(
  //                                         margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
  //                                         child: Column(
  //                                           crossAxisAlignment: CrossAxisAlignment.start,
  //                                           children: <Widget>[
  //                                             Container(
  //                                               width: 250 -48.0,
  //                                               // height: 40.0,
  //                                               constraints: BoxConstraints(
  //                                                 maxHeight:40.0
  //                                               ),
  //                                               // padding: EdgeInsets.symmetric(horizontal: 10.0),
  //                                               // child: FittedBox(
  //                                               //   fit: BoxFit.scaleDown,
  //                                                 // child: RichText(
  //                                                 //   // textScaleFactor: ,
  //                                                 //   text: TextSpan(
  //                                                 //     text:_title,
  //                                                 //     style: TextStyle(
  //                                                 //       color: Colors.white),
  //                                                 //     ),
  //                                                 //   maxLines: 2,
  //                                                 //   // softWrap: false,
  //                                                 //   overflow: TextOverflow.ellipsis
  //                                                 // ),
  //                                               // ),

  //                                 //               child: FittedBox(
  //                                 //                 alignment: Alignment.topLeft,
  //                                 // fit: BoxFit.scaleDown,
  //                                                 child: AutoSizeText(
  //                                                   _title,
  //                                                   maxFontSize: 18.0,
  //                                                   minFontSize: 8.0,
  //                                                   overflow: TextOverflow.ellipsis,
  //                                                   maxLines:2,
  //                                                   style: TextStyle(
  //                                                       fontSize: 18.0, color: Colors.white),
  //                                                 ),
  //                                               // ),
  //                                             ),
  //                                             FittedBox(
  //                                               alignment: Alignment.topLeft,
  //                                               fit: BoxFit.scaleDown,
  //                                               child: Chip(
  //                                                 padding: EdgeInsets.all(0),
  //                                                 backgroundColor: Colors.green[900],
  //                                                 label:
  //                                                     // Icon(
  //                                                     //   Icons.attachment,
  //                                                     //   size: 20.0,
  //                                                     // ),
  //                                                     Text(
  //                                                       widget._subs[0],
  //                                                       maxLines:1,
  //                                                       style: TextStyle(color: Colors.white,
  //                                                         fontSize: 10.0

  //                                                       ),
  //                                                     ),

  //                                               ),
  //                                             )
  //                                           ],
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 Positioned(
  //                                   bottom: 00.0,
  //                                   child: Align(
  //                                     alignment: Alignment.bottomLeft,
  //                                     child: Container(
  //                                       padding:
  //                                           const EdgeInsets.fromLTRB(10.0, 0.0, 1000.0, 10.0),
  //                                       color: Colors.black.withOpacity(0.4),
  //                                       child: Column(
  //                                         crossAxisAlignment: CrossAxisAlignment.start,
  //                                         children: <Widget>[
  //                                           Container(
  //                                              width: 252 - 64.0,
  //                                               padding: const EdgeInsets.only(top: 5.0),
  //                                               child: AutoSizeText(
  //                                                 _message,
  //                                                 maxLines: 1,
  //                                                 minFontSize: 10.0,
  //                                                 overflow: TextOverflow.ellipsis,
  //                                                 style: TextStyle(
  //                                                   fontSize: 13.0,
  //                                                   color: Colors.white,
  //                                                 ),
  //                                               ),
  //                                             ),

  //                                           Container(
  //                                             constraints: BoxConstraints(
  //                                                 maxHeight: 100.0,
  //                                                 minWidth: 250.0-48,
  //                                                 maxWidth: 250.0-48),

  //                                             // color: Colors.blue,
  //                                             // child: Container(
  //                                               padding: const EdgeInsets.fromLTRB(
  //                                                   0.0, 5.0, 0.0, 0.0),
  //                                               child: AutoSizeText('Tags : ' + _tag,
  //                                                   maxLines: 3,
  //                                                   maxFontSize: 10.0,
  //                                                   minFontSize: 8.0,
  //                                                   style: TextStyle(color: Colors.white,
  //                                                   fontSize: 10.0)),
  //                                               // ),
  //                                             ),

  //                                           Container(
  //                                             // color: Colors.black.withOpacity(0.4),
  //                                             padding: const EdgeInsets.fromLTRB(
  //                                                 0.0, 10.0, 0.0, 0.0),
  //                                             child: Text(
  //                                               time,
  //                                               style: TextStyle(color: Colors.white,
  //                                               fontSize: 8.0),
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 // Positioned(
  //                                 //     bottom: 40.0,
  //                                 //     child: Container(
  //                                 //       height:80.0,
  //                                 //       width: 295.0,
  //                                 //       // color: Colors.blue,
  //                                 //       child: Wrap(
  //                                 //         // child: Text('jhfgv')
  //                                 //         children: _buildChoice(timenot),
  //                                 //       ),
  //                                 //     )),
  //                                 // Align(
  //                                 //   alignment:Alignment.bottomLeft
  //                                 // )
  //                                 // Positioned(
  //                                 //   bottom: 10.0,
  //                                 //   child: Container(
  //                                 //     color: Colors.black.withOpacity(0.4),
  //                                 //      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 0.0),
  //                                 //     child: Text(time,style: TextStyle(
  //                                 //              color: Colors.white),
  //                                 //       ),),
  //                                 // )
  //                               ],
  //                             )
  //                             // )
  //                             ),
  //                   ),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: <Widget>[
  //                       FlatButton(
  //                         shape: new RoundedRectangleBorder(
  //                             borderRadius: new BorderRadius.circular(30.0)),
  //                         // color: Colors.blue,
  //                         onPressed: () {
  //                           // Fluttertoast.showToast(msg: 'Creating post');
  //                           // Fluttertoast.cancel();
  //                           // print(createTagsToList(tags[0]));
  //                           // tags = _tag.split(';');
  //                           Navigator.of(context).pop();
  //                           // if(validateAndSave()){
  //                           //   confirmPage();
  //                           // }
  //                         },
  //                         child: Text('Dismiss')),
  //                         Padding(
  //                           padding: const EdgeInsets.only(right: 15.0),
  //                           child: RaisedButton(
  //                           shape: new RoundedRectangleBorder(
  //                               borderRadius: new BorderRadius.circular(30.0)),
  //                           // color: Colors.blue,
  //                           onPressed: () async {
  //                             setState((){
  //                               _loadingSubmit = true;
  //                             });
  //                             Fluttertoast.showToast(msg: 'Creating post');
  //                             // Fluttertoast.cancel();
  //                             // print(createTagsToList(tags[0]));
  //                             // tags = _tag.split(';');
  //                             // if(validateAndSave()){
  //                             //   confirmPage();
  //                             // }
  //                             validateAndSubmit().then((int v){
  //                               if(v==0){
  //                                 setState((){
  //                                   _loadingSubmit = false;
  //                                 });
  //                                 Navigator.pop(context);Navigator.pop(context);
  //                               }
  //                             });
  //                           },
  //                           child: Text('Create Post',
  //                             style: TextStyle(
  //                               color: Colors.white
  //                             ),
  //                           )),
  //                         ),
  //                     ]
  //                   )
  //                 ],
  //               ),
  //             _loadingSubmit?Center(child: CircularProgressIndicator(),):Container()
  //             ],
  //           ),
  //         ),
  //   );
  //   });
  //       });
  // }

  // }
}

// class UploadIMage extends StatefulWidget {
//   // final String _url;
//   // final File _image;
//   final void Function() chooseFile;
//   final void Function() uploadFile;
//   UploadIMage(this.chooseFile, this.uploadFile);
//   @override
//   _UploadIMageState createState() => _UploadIMageState();
// }

// class _UploadIMageState extends State<UploadIMage> {
//   @override
//   Widget build(BuildContext context) {
//     return SimpleDialog(
//       children: <Widget>[
//         Text('Selected Image'),
//         _image != null
//             ? Image.asset(
//                 _image.path,
//                 height: 150,
//               )
//             : Container(),
//         _image == null
//             ? RaisedButton(
//                 shape: new RoundedRectangleBorder(
//                     borderRadius: new BorderRadius.circular(30.0)),
//                 child: Text(
//                   'Choose File',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onPressed: widget.chooseFile,
//                 color: Colors.blue,
//               )
//             : Container(),
//         _image != null
//             ? RaisedButton(
//                 shape: new RoundedRectangleBorder(
//                     borderRadius: new BorderRadius.circular(30.0)),
//                 child: Text(
//                   'Upload File',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onPressed: widget.uploadFile,
//                 color: Colors.blue[900],
//               )
//             : Container(),
//         _image != null
//             ? RaisedButton(
//                 color: Colors.black,
//                 shape: new RoundedRectangleBorder(
//                     borderRadius: new BorderRadius.circular(30.0)),
//                 child: Text(
//                   'Clear Selection',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _image = null;
//                   });
//                 },
//               )
//             : Container(),
//         // ]
//         // )]
//       ],
//     );
//   }
// }

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
