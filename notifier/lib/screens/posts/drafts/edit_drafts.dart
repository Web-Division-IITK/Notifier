import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/screens/posts/createposts.dart';
import 'package:notifier/screens/posts/update/updateposts.dart';
// import 'package:notifier/screens/posts/updateposts.dart';
import 'package:notifier/services/databse.dart';
import 'package:notifier/shared/preview.dart';
import 'package:notifier/widget/chips.dart';
import 'package:path/path.dart' as Path;
class EditDraft extends StatefulWidget {
  final String _id;
  final UpdatePostsFormat _update;
  final int index;
  final List<String> _subs;
  EditDraft(this._update, this._id, this._subs, this.index);
  @override
  _EditDraftState createState() => _EditDraftState();
}

class _EditDraftState extends State<EditDraft> {
  final _formKey = GlobalKey<FormState>();
  String _title;
  String _body;
  List<dynamic> tags = List();
  // String _subtitile;
  String _tag;
  String _url;
  String _council;
   String _subs;
  String _author;
  String _message;
  File _image;
  bool _loadSubmit = false;
  final _tagController = TextEditingController();  
  final _imgController = TextEditingController();  
  // bool _firstSelected = true;
  bool _loadingWidget = false;
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
       Fluttertoast.showToast(msg: 'Svaing file');
  return await fileExists('drafts').then((var _exists) async {
      print(_exists.toString() + 'exists in drafts.dart line 87');
      if (_exists) {
        return await readContentDrafts('drafts').then((var val) async{
          print(val);

          if (val != null && val.length != 0) {
            val.add(widget._update.value);
          }
          else{
            val =[widget._update.value];
          }
          return await writeContentDrafts(json.encode(val)).then((var b){
            if(b){

              Fluttertoast.showToast(msg: 'File Saved successfully');
              Navigator.pop(context);
              Navigator.pop(context);
              return true;
            }else{
              Fluttertoast.showToast(msg: 'Failed');
              return false;
              // Navigator.pop(context);
              // Navigator.pop(context);
            }

            
          });
        });
      }
      else{
        return await writeContentDrafts(json.encode(widget._update.value)).then((var b){
            if(b){

              Fluttertoast.showToast(msg: 'File Saved successfully');
              Navigator.pop(context);
              Navigator.pop(context);
              return true;
            }else{
              Fluttertoast.showToast(msg: 'Failed');
              return false;
              // Navigator.pop(context);
              // Navigator.pop(context);
            }
        });
      }
  });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _loadSubmit = false;
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
        _imgController.text = fileURL;
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
    super.initState();
    buildsubs();
    // _tagController.addListener((){
         _url = widget._update.value['url'];
      _tagController.text = converToString(widget._update.value['tags']);
      _imgController.text = (widget._update.value['url']);
    //   );
    // });
  }
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> _selectItem = [];
    for (var i in selectCouncil) {
      _selectItem.add(DropdownMenuItem(
        child: Text(i),
        value: i,
      ));
    }
    // if(widget._update.value['council'] !=null) { 
    //   buildsubs();
    //   _firstSelected = true;}
    // else{
    //   _firstSelected = false;
    // }
 
    tags = widget._update.value['tags'];
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Edit Drafts'),
          // actions: <Widget>[
          //   new FlatButton(
          //       child: new Text('Logout',
          //           style: new TextStyle(fontSize: 17.0, color: Colors.white)),
          //       onPressed: signOut)
          // ],
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
                  //         keyboardType: TextInputType.text,
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
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                            child: new TextFormField(
                              maxLines: 1,
                              readOnly: true,
                              enabled: false,
                              controller: _imgController,
                              // initialValue: 'ghjjg',
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              // onChanged: (value) {
                              //   // return _url;
                              //   _url = value;
                              // },
                              decoration: new InputDecoration(
                                labelText: 'Image Url',
                                // icon: new Icon(
                                //   Icons.mail,
                                //   color: Colors.grey,
                                // )
                              ),
                              // validator: (value) =>
                              //     value.isEmpty ? 'Images Field can\'t be empty' : null,
                              onSaved: (_url) => _url,
                            ),
                        ),
                            // child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: <Widget>[
                            //       _url != null
                            //           ? SizedBox(
                            //               height: 15.0,
                            //             )
                            //           : SizedBox(height: 5.0),
                            //       _url != null
                            //           ? Text('Image Url',
                            //               style: TextStyle(
                            //                   fontSize: 12.0, color: Colors.grey))
                            //           : Text(''),
                            //       SizedBox(
                            //         height: 5.0,
                            //       ),
                            //       _url == null
                            //           ? Text(
                            //               'Image Url',
                            //               style: TextStyle(
                            //                   color: Colors.grey, fontSize: 16),
                            //             )
                            //           : Text(
                            //               _url,
                            //               maxLines: 1,
                            //               overflow: TextOverflow.ellipsis,
                            //               style: TextStyle(fontSize: 16),
                            //             ),
                            //       _url != null
                            //           ? SizedBox(
                            //               height: 5.0,
                            //             )
                            //           : SizedBox(height: 10.0),
                            //       Divider(color: Colors.grey)
                            //     ])),
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
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.0)),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
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
                                                                  
                                                                  await ImagePicker.pickImage(
                                                                          source:
                                                                              ImageSource
                                                                                  .gallery)
                                                                      .then((image) {
                                                                    setState(() {
                                                                      _image = image;
                                                                      print(_image);
                                                                    });
                                                                  });
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
                                                                },
                                                                color: Colors.cyan,
                                                              )
                                                            : Container(),
                                                        _image != null || _url == null
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
                                                                        // _url ='mnkfb';
                                                                        _loadingWidget =false;
                                                                        Fluttertoast.showToast(msg: 'Upload Successful!!');
                                                                        Navigator.of(context).pop();
                                                                      });
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
                                                                  if ( _image != null &&_url == null) {
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
                              }),
                        ),
                      ],
                    ),
                  ),
                  //council dropdown to make
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      // child: ListView.builder(
                      //     shrinkWrap: true,
                      //     itemCount: selectCouncil.length,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       // var _selected;
                      //       _council = 'SnT';
                      //       return DropdownButton(
                      //         itemHeight: 60.0,
                      //         hint: Text(
                      //             'Choose Council'), // Not necessary for Option 1
                      //         value: _council,
                      //         onChanged: (newValue) {
                      //           setState(() {
                      //             _council = newValue;
                      //           });
                      //         },
                      //         items: selectCouncil.map((location) {
                      //           return DropdownMenuItem(
                      //             child: new Text(location),
                      //             value: location,
                      //           );
                      //         }).toList(),
                      //       );
                      //     })
                      child: DropdownButtonFormField(
                        isDense: true,
                        items: _selectItem,
                        onChanged: (newValue) {
                          setState(() {
                            print(widget._update.value['council']);
                            // buildsubs();
                            // _firstSelected = true;
                            _council = newValue;
                          });
                        },
                        hint: Text('Choose Council'),
                        value: widget._update.value['council'] == 'snt'||widget._update.value['council'] =='SnT' ? 'SnT' : null,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Council Field can\'t be empty'
                            : null,
                        onSaved: (value) => _council = value,
                      )),
                      Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
                  child: DropdownButtonFormField(
                    items: _selectSub, 
                    isDense: true,
                    onChanged: (newValue){
                      // print(_council);
                      setState(() {
                        _subs = newValue;
                      });
                    },
                    hint: Text(
                              'Choose Club'),
                    value: widget._update.value['sub']!=null? widget._update.value['sub'][0]:_subs,
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
                            keyboardType: TextInputType.multiline,
                            autofocus: false,
                            enabled: false,
                            // initialValue: converToString(widget._update.value['tags']),
                            decoration: new InputDecoration(
                              labelText: 'Tags',
                              hintText: 'Click \'+\' button to add tags',
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
                      keyboardType: TextInputType.text,
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
                        // color: Colors.blue,
                        onPressed: () {
                          // Fluttertoast.showToast(msg: 'Updating post');
                          // Fluttertoast.cancel();
                          // setState(() {
                          //   _loadSubmit = true;
                          // });
                          if(validateAndSave()){
                            Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return Preview(0, {
                            'title': _title,
                            'tags': tags,
                            'council': _council.toLowerCase(),
                            'sub': [_subs],
                            'body': _body,
                            'author': _author,
                            'url': _url,
                            'owner': widget._id,
                            'message': _message,
                          },'create');
                        }));
                          }
                          
                        },
                        child: Text('Preview',
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
  addingTag() {
    return showModalBottomSheet(
        context: (context),
        builder: (BuildContext context) {
          final _formKey = GlobalKey<FormState>();
          String addTag;
          print(tags);
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
                    ),),
                    onPressed: () {
                      showDialog(context: context, builder: (BuildContext context){
                        return CupertinoAlertDialog(
                          content: Form(
                            key: _formKey,
                              child:  Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
                      padding: EdgeInsets.only(bottom: 5.0, top: 25.0),
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
                                padding: const EdgeInsets.only(right: 15.0),
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
                                          tags.add(addTag);
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
            message: CreateChips(this._tag,this.tags),
            cancelButton: Column(
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    setState(() {
                      
                      // print(tagsForChips);
                      _tag??='';
                      _tag!=null || _tag != ''? _tag =_tag:_tag = '';
                      for (var i in tags) {
                        _tag += i + '; ';
                      }
                      // _tag = tagForChip;
                      // tags = tagsForChips;
                      _tagController.text = _tag;
                      print(_tag + ':tags line807');
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Done',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          );
        });
}

}
