
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notifier/model/options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:notifier/widget/showtoast.dart';
import 'package:path/path.dart' as Path;


class AddImage extends StatefulWidget {
  final TextEditingController imageController;
  final AddingImage addingImage;
  final String type;
  AddImage({@required this.imageController,@required this.addingImage,@required this.type});
  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  bool _loadingWidget = false;
  // Future chooseFile() async {
  //   await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
  //     setState(() {
  //       image = image;
  //     });
  //   });
  // }

  Future<bool> uploadFile() async {
    setState(() {
      _loadingWidget = true;
    });
    // Fluttertoast.showToast(msg: 'Uploading Image');
    StorageReference storageReference = FirebaseStorage.instance.ref()
        .child('upload_image/${Path.basename(widget.addingImage.image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(widget.addingImage.image);
    await uploadTask.onComplete;
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
    }).catchError((onError){
      print(onError);
      return false;
    });
  }

  Future<bool> clearSelection() async {
    StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl('${widget.imageController.text}');
    return await storageReference.delete().then((_) {
      return true;
    }).catchError((onError){
      print(onError);
      showErrorToast('Failed!!!');
      return false;
    });
    // StorageUploadTask uploadTask = storageReference.putFile(_image);
  }
  @override
  void initState() {
    super.initState();
    if(widget.imageController.text.trim() == null || widget.imageController.text == '' || widget.imageController.text.trim() == ''){
      setState(() {
        widget.imageController.clear();
        widget.addingImage.url = null;
      });
    }
  }
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: ()async {
        //  Navigator.of(context).pop();
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
                      widget.addingImage.url != null || widget.addingImage.image != null?
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
                          Image.file(widget.addingImage.image)
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
                          ),
                      )
                      : Container(),
                      RaisedButton.icon(
                        color: Colors.lightBlue,
                        splashColor: Colors.blueAccent,
                        textColor: Colors.white,
                        onPressed: ()async{
                          // if(widget.addingImage.url != null){
                          //   await clearSelection();
                          // }
                          
                          await ImagePicker.pickImage(
                            source: ImageSource.gallery).then((image) {
                              setState(() {
                                widget.addingImage.image = image;
                              });
                            });
                        }, 
                        icon: Icon(EvilIcons.image), 
                        label: Text(
                          widget.addingImage.image == null && widget.addingImage.url == null?
                          'Choose Image'
                          :'Select Another Image'
                        )
                      ),
                      widget.addingImage.image!=null || widget.addingImage.url!=null?
                        RaisedButton.icon(
                          // color: Colors.,
                          onPressed: ()async{
                            if(widget.addingImage.url != null){
                              return await clearSelection().then((bool status)async {
                                if(status){
                                  setState(() {
                                    widget.addingImage.url = null;
                                    widget.imageController.clear();
                                    // widget.addingImage.image = null;
                                    
                                  });
                                  
                                  // showSuccessToast('Removed Successfully'); //TODO remove when completed debugging
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
                      widget.addingImage.image!=null || widget.addingImage.url!=null?
                        RaisedButton.icon(
                          color: Colors.grey,
                          splashColor: Colors.black,
                          textColor: Colors.white,
                          onPressed: ()async{
                            if(widget.addingImage.url != null){
                              await clearSelection().then((bool status){
                                if(status){
                                    setState(() {
                                    widget.addingImage.url = null;
                                    widget.addingImage.image = null;
                                    widget.imageController.clear();
                                  });
                                  showSuccessToast('Removed Successfully');
                                  // Navigator.of(context).pop();
                                }
                              });
                            }
                            else{
                              setState(() {
                                widget.addingImage.url = null;
                                widget.addingImage.image = null;
                                widget.imageController.clear();
                              });
                              // Navigator.pop(context);
                            }
                          }, 
                          icon: Icon(MaterialIcons.clear), 
                          label: Text(
                            'Clear Selected Image'
                          )
                        ):Container(),
                    ],
                  ),
                  _loadingWidget?
                  CircularProgressIndicator()
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