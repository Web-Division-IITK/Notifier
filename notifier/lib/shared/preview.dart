

import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/services/databse.dart';
import 'package:notifier/services/function.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:notifier/screens/posts/notification/notification.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class Preview extends StatefulWidget {
  final int index;
  final dynamic value;
  final String type;
  Preview(this.index,this.value,this.type);
  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
String _errorMessage ='';
var tags = [];
bool _loadSubmit = false;

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
   var tagList=[];
Future<bool> saveAsDraft(value)async{
  Fluttertoast.showToast(msg: 'Saving file');
  return await fileExists('drafts').then((var _exists) async {
      print(_exists.toString() + 'exists in drafts.dart line 87');
      if (_exists) {
        return await readContentDrafts('drafts').then((var val) async{
          print(val);

          if (val != null && val.length != 0) {
            val.add(value);
          }
          else{
            val =[value];
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
        return await writeContentDrafts(json.encode(value)).then((var b){
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
}
 
  Future<int> validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      // _isLoading = true;
    });
    
      // String userId = "";
      try {
        // var tagList=[];
        // tags = widget.value['tags'].split(';');
        for (var i in tags) {
          tagList.add(i.toString());
        }
        var _response = await createPostForNotifs(widget.value['title'], widget.value['body'], widget.value['tags'],
            widget.value['owner'], widget.value['url'], widget.value['council'], widget.value['author'], widget.value['message'], widget.value['sub']);
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
          // _formKey.currentState.reset();
          // Fluttertoast(
          
          // );
        });
        return 1;
      }
  }

  Widget build(BuildContext context) {
  print(widget.value);
  // tags =;
  if(widget.value['tags']!=null){
    for (var i in  widget.value['tags'] ) {
    tags.add(i.toString());
  }
  }
  
    return Scaffold(
      appBar: AppBar(title: Text(
        'PREVIEW: ' + widget.value['title'])),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Card(
                elevation: 0.0,
                child: Hero(
                    tag: 'image$widget.index',
                    child:widget.value['url']==null ?
                    Container():
                     CachedNetworkImage(
                      fit: BoxFit.fitWidth,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      imageUrl: widget.value['url'],
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )),
              ),
              Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  margin: EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 10.0),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            widget.value['title'],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(fontSize: 35.0),
                          ),
                        ),
                        Center(
                          child: Text(widget.value['sub'][0],
                              // 'Science and Technology Council',
                              style: TextStyle(fontSize: 20.0)),
                        ),
                        Wrap(
                          spacing: 8.0,
                          children: _buildChoice(widget.value),
                        ),
                        Linkify(
                          // data:
                          text: widget.value['body'],
                          // options: LinkifyOptions(humanize: false),
                          onOpen:_onOpen,
                            // if(u.url is UrlElement){
                            // _launchUrl(u.url);
                            // }
                          // },
                          style: TextStyle(
                              fontSize: 15.0,
                              // color:Colors.white
                              ),
                          // linkStyle: TextStyle(
                          //   color: Colors.blue,
                          // ),
                        ),
                        
                      ],
                    ),
                  )),
                  Container(
                    alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0,16.0),
                          child: Wrap(
                            spacing: 10.0,
                            children: <Widget>[
                              Container(
                                child:RaisedButton(
                                  color: Colors.red,
                                  shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                                  onPressed: ()=>Navigator.of(context).pop(),
                                  child :Text('Dismiss',
                                    style:TextStyle(
                                      color:Colors.white
                                    )
                                  ), 
                                )
                              ),
                              widget.type == 'drafts' ?
                              Container(width: 0.0):
                              Container(
                                child:RaisedButton(
                                  color: Colors.grey,
                                  shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                                  onPressed: (){
                                    saveAsDraft(widget.value);
                                  },
                                  child :Text('Save as Draft',
                                    style:TextStyle(
                                      color:Colors.white
                                    )
                                  ), 
                                )
                              ),
                              Container(
                                
                                child:RaisedButton(
                                  color: Colors.teal,
                                  shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                                  onPressed: (){
                                    setState(() {
                                        _loadSubmit = true;
                                      });
                                    Fluttertoast.showToast(msg: 'Publishing posts');
                                    validateAndSubmit().then((var v){
                                      if(v == 0){
                                        setState(() {
                                        _loadSubmit = false;
                                      });
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      }else{
                                         setState(() {
                                        _loadSubmit = false;
                                      });
                                      }
                                    });
                                },
                                  child :Text('Publish',
                                  style:TextStyle(
                                      color:Colors.white
                                    )), 
                                )
                              )
                            ],
                          )
                        )
            ],
          ),
          _loadSubmit
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container()
        ],
      ),
    );
  }
  Future<void> _onOpen(LinkableElement link) async {
    print(link.url);
    if(link.url.startsWith('https://')){
      print('islink');
      if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
    }
    // else if(link.url.contains('mailto:')){
    //   var url = link.url;
    //   print(link.url);
      
    //    if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $link';
    // }
    // }
    // else{
    //   var url = "tel:$link.url";   
    // if (await canLaunch(url)) {
    //    await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // } 
    // }
    
  }
  Future<void> launchCaller(String number) async {
    var url = "tel:$number";   
    if (await canLaunch(url)) {
       await launch(url);
    } else {
      throw 'Could not launch $url';
    }   
}
launchMail(String mailId) async{
  var url = "mailto:$mailId?subject=<subject>&body=<body>";
  if(await canLaunch(url)){
    await launch(url);
  }else{
    throw 'Couldn\'t mail this time';
  }
}


  _buildChoice(timenot) {
    List<Widget> _tag = List();
    // List<String> tags = timenot['tags'];
    for (var i in timenot['tags']) {
      _tag.add(Container(
        constraints: BoxConstraints(
          maxWidth: 120.0,
          // minWidth: 80.0,
        ),
        child: Chip(
          labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
          backgroundColor: Colors.teal[900],
          label: Text(i.toString(), style: TextStyle(color: Colors.white)),
        ),
      ));
    }

    return _tag;
  }
}

// _launchUrl(url) async {
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
