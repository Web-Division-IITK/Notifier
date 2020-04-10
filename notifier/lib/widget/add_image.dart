import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class AddImage extends StatefulWidget {
  File image;
  String url;
  final TextEditingController imageController;
  final Function addingImage;
  AddImage(this.image, this.imageController, this.url,this.addingImage);

  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  bool _loadingWidget = false;
  Future<bool> uploadFile() async {
    setState(() {
      _loadingWidget = true;
    });
    Fluttertoast.showToast(msg: 'Uploading Image');
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('upload_image/${Path.basename(widget.image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(widget.image);
    await uploadTask.onComplete;
    print('File Uploaded');
    return storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        print(fileURL);
        widget.url = fileURL;
        widget.imageController.text = fileURL;
        _loadingWidget = false;
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                  widget.image != null
                      ? Text('Selected Image', style: TextStyle(fontSize: 20.0))
                      : Container(),
                  widget.image != null
                      ? SizedBox(
                          height: 10.0,
                        )
                      : SizedBox(),
                  widget.image != null
                      ? Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          height: 250.0,
                          child: Image.file(widget.image),
                        )
                      : Container(),
                  widget.url == null
                      ? RaisedButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: Text(
                            widget.url == null && widget.image == null
                                ? 'Choose Image'
                                : 'Choose another',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            await ImagePicker.pickImage(
                                    source: ImageSource.gallery)
                                .then((image) {
                              setState(() {
                                widget.image = image;
                              });
                            });
                          },
                          color: Colors.cyan,
                        )
                      : Container(),
                  widget.image != null && widget.url == null
                      ? RaisedButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: Text(
                            'Upload Image',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _loadingWidget = true;
                            });
                            uploadFile().then((bool status) {
                              if (status) {
                                Fluttertoast.showToast(
                                    msg: 'Upload Successful!!');
                                
                                setState(() {
                                  widget.addingImage(widget.image,widget.url);
                                  _loadingWidget = false;
                                });
                                Navigator.of(context).pop();
                              }
                            });
                          },
                          color: Colors.cyan,
                        )
                      : Container(),
                  widget.image != null
                      ? RaisedButton(
                          color: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: Text(
                            'Clear Selection',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            print(widget.image.path);
                            if (widget.url == null) {
                              setState(() {
                                widget.addingImage(null,null);
                                widget.image = null;
                                widget.url = null;
                                widget.imageController.text = null;
                              });
                            } else {
                              StorageReference storageReference =
                                  FirebaseStorage.instance.ref().child(
                                      'upload_image/${Path.basename(widget.image.path)}');
                              storageReference.delete().then((_) {
                                Fluttertoast.showToast(
                                    msg: 'Removed Successfully');
                                setState(() {
                                  widget.addingImage(null,null);
                                  widget.image = null;
                                  widget.url = null;
                                  widget.imageController.text = null;
                                });
                              });
                            }
                          })
                      : Container(),
                ],
              ),
              _loadingWidget
                  ? Center(
                      child: Container(child: CircularProgressIndicator()),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
      // ),
    );
  }
}
