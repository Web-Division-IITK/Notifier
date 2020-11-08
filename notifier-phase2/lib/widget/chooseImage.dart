
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notifier/colors.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/model/options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:notifier/widget/showtoast.dart';
import 'package:path/path.dart' as Path;


class AddImage extends StatefulWidget {
  final TextEditingController imageController;
  final AddingImage addingImage;
  final File image;
  /// has only two types `CREATE`, `EDIT`
  final PostDescType type;
  AddImage({@required this.imageController,@required this.addingImage,@required this.type,this.image});
  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  bool _loadingWidget = false;
  final ImagePicker picker = ImagePicker();
  AddingImage _newImage;
  Future<bool> uploadFile() async {
    setState(() {
      _loadingWidget = true;
    });
    showInfoToast('Uploading Image');
    try{
      Reference storageReference = FirebaseStorage.instance.ref()
        .child('upload_image/${Path.basename(widget.addingImage.image.path)}');
        UploadTask uploadTask = storageReference.putFile(widget.addingImage.image);
        // await uploadTask.onComplete;
        print('File Uploaded');
        return storageReference.getDownloadURL().then((fileURL) {
          // setState(() {
            print(fileURL);
            // _url = fileURL;
            // widget.addingImage.url = fileURL;
            widget.imageController.text = fileURL;
            _loadingWidget = false;
          // });
          return true;
        });
    }catch(onError){
      print(onError);
      showErrorToast('Uploading failed !!!');
      return false;
    }
  }

  Future<bool> clearSelection() async {
    try{
      Reference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl('${widget.imageController.text}');
        return await storageReference.delete().then((_) {
          return true;
        }).catchError((onError){
          print(onError);
          showErrorToast('Failed!!!');
          return false;
        });
    }catch(e){
      print(e);
      showErrorToast('Failed!!!');
      return false;
    }
    // StorageUploadTask uploadTask = storageReference.putFile(_image);
  }
  @override
  void initState() {
    super.initState();
    _newImage = AddingImage(image: widget.addingImage.image, url: widget.addingImage.url);
    if(widget.imageController.text.trim() == null || widget.imageController.text == '' || widget.imageController.text.trim() == ''){
      setState(() {
        if(mounted){
          widget.imageController.clear();
        widget.addingImage.url = null;
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: ()async {
         return !_loadingWidget;
      },
      child:AbsorbPointer(
        absorbing: _loadingWidget,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height:5.0),
                      if(_newImage != null && 
                        (_newImage.url != null || _newImage.image != null))
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 15.0,
                              ),
                              Text(
                                'Selected Image',
                                style: TextStyle(fontSize: 20.0)
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: 10.0),
                                height: 250.0,
                                child: _newImage.image != null ?
                                  Image.memory(_newImage.image.readAsBytesSync(),)
                                  : CachedNetworkImage(
                                    imageUrl: widget.addingImage.url,
                                    errorWidget: (context,url,value){
                                      return Container(
                                        child: Center(
                                          child: Text('An error occured while loading Image',
                                          textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      );
                                    },
                                    progressIndicatorBuilder: (context,value,progress){
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Loading Image.....'),
                                          SizedBox(height: 25,),
                                          CircularProgressIndicator(),
                                        ],
                                      );
                                    },
                                  ),
                              ),
                          ],),

                      /*_newImage != null || widget.addingImage.image != null?
                      SizedBox(
                        height: 15.0,
                      ):Container(),
                      widget.addingImage.url != null || widget.addingImage.image != null?
                      Text(
                        'Selected Image',
                        style: TextStyle(fontSize: 20.0)
                      )
                      :Container(),
                      widget.addingImage.url != null || widget.addingImage.image != null? 
                      SizedBox(
                        height: 10.0,
                      )
                      : SizedBox(),
                      widget.addingImage.image != null || widget.addingImage.url != null
                      ? Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        height: 250.0,
                        child: widget.addingImage.image != null ?
                          // Image.file(widget.addingImage.image,
                            
                          // )
                          Image.memory(widget.addingImage.image.readAsBytesSync(),)
                          : CachedNetworkImage(
                            imageUrl: widget.addingImage.url,
                            errorWidget: (context,url,value){
                              return Container(
                                child: Center(
                                  child: Text('An error occured while loading Image',
                                  textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                            },
                            progressIndicatorBuilder: (context,value,progress){
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Loading Image.....'),
                                  SizedBox(height: 25,),
                                  CircularProgressIndicator(),
                                ],
                              );
                            },
                          ),
                      )
                      : Container(),*/
                      RaisedButton.icon(
                        color: Colors.lightBlue,
                        splashColor: Colors.blueAccent,
                        textColor: Colors.white,
                        onPressed: ()async{
                          await picker.getImage(
                            source: ImageSource.gallery).then((image){
                              setState((){
                                if(image != null)
                                  _newImage.image = File(image.path);
                                else showInfoToast('No image was selected');
                              });
                            });
                        }, 
                        icon: Icon(EvilIcons.image), 
                        label: Text(
                          _newImage.image == null && _newImage.url == null?
                          'Choose Image'
                          :'Select Another Image'
                        )
                      ),
                      _newImage.image!=null || (_newImage.url != null && _newImage.url.isNotEmpty)?
                        RaisedButton.icon(
                          onPressed: ()async{
                            if(_newImage.image == widget.addingImage.image) return null;
                            if(_newImage.url != null && _newImage.url.isNotEmpty){
                              await clearSelection().then((bool status)async {
                                if(status){
                                  setState(() {
                                    widget.addingImage.url = null;
                                    _newImage.url = null;
                                    widget.imageController.clear();
                                  });
                                  showSuccessToast('Removed Successfully'); //TODO remove when completed debugging
                                  return await uploadFile().then((onValue){
                                    if(onValue){
                                      Navigator.pop(context);
                                      showSuccessToast('Image Uploaded Successfully');
                                    }else{
                                      showErrorToast('Image Upload Failed!!!!');
                                    }
                                  });
                                }
                              });
                            }
                            return await uploadFile().then((onValue){
                              if(onValue){
                                Navigator.pop(context);
                                showSuccessToast('Image Uploaded Successfully');
                              }else{
                                showErrorToast('Image Upload Failed!!!!');
                              }
                            });
                          }, 
                          icon: Icon(SimpleLineIcons.cloud_upload), 
                          label: Text(
                            'Upload Image'
                          )
                        ):Container(),
                      _newImage.image!=null || (_newImage.url != null && _newImage.url.isNotEmpty)?
                        RaisedButton.icon(
                          color: Colors.grey,
                          splashColor: Colors.black,
                          textColor: Colors.white,
                          onPressed: ()async{
                            if(_newImage.url != null && _newImage.url.isNotEmpty){
                              await clearSelection().then((bool status){
                                if(status){
                                  setState(() {
                                    widget.addingImage.url = null;
                                    widget.addingImage.image = null;
                                    _newImage.url = null;
                                    _newImage.image = null;
                                    widget.imageController.clear();
                                  });
                                  showSuccessToast('Removed Successfully');
                                  // Navigator.of(context).pop();
                                }else{
                                  setState(() {
                                    // widget.addingImage.url = null;
                                    widget.addingImage.image = null;
                                    // _newImage.url = null;
                                    _newImage.image = null;
                                    // widget.imageController.clear();
                                  });
                                }
                              });
                            }
                            else{
                              setState(() {
                                widget.addingImage.url = null;
                                widget.addingImage.image = null;
                                _newImage.url = null;
                                _newImage.image = null;
                                widget.imageController.clear();
                              });
                              // Navigator.pop(context);
                            }
                          }, 
                          icon: Icon(MaterialIcons.clear), 
                          label: Text(
                            'Remove Selected Image'
                          )
                        ):Container(),
                    ],
                  ),
                  _loadingWidget?
                  Container(
                    height: 100,width: 100,
                    decoration: BoxDecoration(
                      color: CustomColors(context).textColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16)),
                    child: Center(
                    child: CircularProgressIndicator(),
                  ))
                  :Container()
                ],
              ),
            ]
          )
        ),
      ),
    );
  }
}