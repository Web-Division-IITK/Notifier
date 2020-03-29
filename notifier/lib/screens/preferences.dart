import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/data/data.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/databse.dart';

class Preferences extends StatefulWidget {
  Preferences(this.auth, this.logoutCallback, this.userId);
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  // final List<bool> select;

  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  List<Widget> list = List();
  List<String> prefSel = List();
  List<bool> select = List();
  bool _loading = false;
  List<dynamic> _prefs = List();
  // List<TableRow> tableRow = [];
  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loading = false;
    // for (var i in (selectionData[0].name)) {
    //   select.add(false);
    // }
    // print('reading');
    readContent('users').then((var value){
      print('reading users');
      if(value !=null){
        setState(() {
          _prefs = value['prefs'];
        });
       setState(() {
          _prefs.remove('Science and Technology Council');
          _prefs.remove('Techkriti');
          var r = _prefs;
          //   for (var i in (selectionData[0].name)) {
          //   select.add(false);
          // }
          for (var i in r) {
            var index = selectionData[0].name.indexOf(i);
            selectionData[0].isSelected[index] = true;
          }
       });
      }
    });
    // print(select);
  }

  @override
  Widget build(BuildContext context) {
    // return WillPopScope(onWillPop: ()async{
    //   return Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
    //           return HomePage(auth: widget.auth,logoutCallback:widget.logoutCallback,userId: widget.userId,);
    //         }));
    // },
    // for (var index = 0; index < selectionData[0].name.length; index++) {
    //   list.add(
    //     Row(
    //       children: <Widget>[
    //         Container(
    //           width: MediaQuery.of(context).size.width * 0.7,
    //           // decoration: Decoration(),
    //           padding: EdgeInsets.only(left: 30.0),
    //           child: Text(
    //             selectionData[0].name[index],
    //             style: TextStyle(
    //               fontFamily: 'Nunito',
    //               // fontWeight: FontWeight.bold,
    //               fontSize: 15.0,
    //             ),
    //           ),
    //         ),
    //         Container(
    //           width: MediaQuery.of(context).size.width * 0.3,
    //           child: Align(
    //             alignment: Alignment.centerLeft,
    //             child: Switch(
    //               value: selectionData[0].isSelected[index],
    //               onChanged: (value) {
    //                 if (!value) {
    //                   setState(() {
    //                     confirmdialogForPrefs(
    //                         index, selectionData[0].name[index], value);
    //                   });
    //                   print(value.toString() +
    //                       ':' +
    //                       selectionData[0].name[index]);

    //                   // }
    //                 } else {
    //                   setState(() {
    //                     selectionData[0].isSelected[index] = value;
    //                     print(value.toString() +
    //                         ':' +
    //                         selectionData[0].name[index]);
    //                   });
    //                 }
    //               },
    //               activeTrackColor: Colors.lightGreenAccent,
    //               activeColor: Colors.green,
    //             ),
    //           ),
    //         )
    //       ],
    //     ),
    //   );
    // }
    // list.add(
    //   Container(
    //     width: 150.0,
    //     padding: EdgeInsets.fromLTRB(100.0, 0.0, 100.0, 0.0),
    //     child: RaisedButton(
    //       shape: new RoundedRectangleBorder(
    //           borderRadius: new BorderRadius.circular(30.0)),
    //       // color: Colors.blue,
    //       onPressed: () {
    //         confirmdialog(0);
    //       },
    //       child: Text(
    //         'Update',
    //         style: TextStyle(
    //           color: Colors.white,
    //           fontFamily: 'Comfortaa',
    //           fontWeight: FontWeight.bold,
    //           fontSize: 15.0,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Preferences'),
        ),
        body: Stack(
          children: <Widget>[
            // ListView(
            // shrinkWrap: true,
            // physics: AlwaysScrollableScrollPhysics(),
            // children: list,
            ListView.builder(
                // physics: AlwaysScrollableScrollPhysics(),
                // shrinkWrap: true,
                itemCount: selectionData[0].name.length +1,
                itemBuilder: (BuildContext context, int index) {
                  //  for (var i in (selectionData[0].name)){
                  //    select.add(false);
                  //  }
                  // select.insert(index, false);
                  return index != selectionData[0].name.length?
                      Container(
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              // decoration: Decoration(),
                              padding: EdgeInsets.only(left: 30.0),
                              child: Text(
                                selectionData[0].name[index],
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Switch(
                                  value: selectionData[0].isSelected[index],
                                  onChanged: (value) {
                                    if (!value) {
                                      setState(() {
                                        confirmdialogForPrefs(
                                            index,
                                            selectionData[0].name[index],
                                            value);
                                      });
                                      print(value.toString() +
                                          ':' +
                                          selectionData[0].name[index]);

                                      // }
                                    } else {
                                      setState(() {
                                        selectionData[0].isSelected[index] =
                                            value;
                                        print(value.toString() +
                                            ':' +
                                            selectionData[0].name[index]);
                                      });
                                    }
                                  },
                                  // activeTrackColor: Colors.lightGreenAccent,
                                  // activeColor: Colors.green,
                                ),
                              ),
                            )
                          ],
                        ),
                      ):Container(
                              width: 150.0,
                              padding:
                                  EdgeInsets.fromLTRB(100.0, 0.0, 100.0, 0.0),
                              child: RaisedButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                                // color: Colors.blue,
                                onPressed: () {
                                  confirmdialog(0);
                                },
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Comfortaa',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                            );
                   
                }),
            // ),

            // )

            _loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ],
        )

        // ),
        );
  }

  confirmdialogForPrefs(index, name, value) {
    return showDialog(
        context: context,
        builder: (context) {
          String typed;
          final _formKey = GlobalKey<FormState>();
          //  TextFormField _unsubscribe = GlobalKey<TextS>;
          return CupertinoAlertDialog(
            title: Text('Alert',
                style: TextStyle(
                  color: Colors.red,
                  // fontFamily: 'Comfortaa',
                  // fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                )),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                Text('Do you really want to unsubscribe',
                    style: TextStyle(
                      color: Colors.red,
                      // fontFamily: 'Comfortaa',
                      // fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    )),
                SizedBox(height: 10.0),
                Text(
                  'Note: You will not be able to receive notifications for the unsubscribed topic',
                  style: TextStyle(fontSize: 10.0,),
                ),
                SizedBox(height: 10.0),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: 'Type ',
                        // style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: '$name ',
                              style: TextStyle(
                                  // color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: 'to continue',
                              // style: TextStyle()
                              )
                        ])),
                //  SizedBox(height: 20.0),
                Material(
                  color: Colors.transparent,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      decoration: new InputDecoration(
                        // labelText: 'Tags',
                        hintText: '$name',
                        // icon: new Icon(
                        //   Icons.mail,
                        //   color: Colors.grey,
                        // )
                      ),
                      onChanged: (value) {
                        typed = value;
                      },
                      // autovalidate: true,
                      validator: (value) => value.isEmpty
                          ? 'Field can\'t be empty'
                          : value != name &&
                                  value != name.toString().toLowerCase()
                              ? 'Type the name of topic To Unsubscribe'
                              : null,
                      onSaved: (val) => typed = val,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    CupertinoButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context)),
                    RaisedButton(
                        color: Colors.red[900],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            if (typed == name.toString() ||
                                typed == name.toString().toLowerCase()) {
                              setState(() {
                                print(typed.toLowerCase());
                                selectionData[0].isSelected[index] = value;
                                Navigator.pop(context);
                              });
                            }
                          }
                        },
                        child: Text('Unsubscribe',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            )))
                  ],
                ),
              ],
            ),
          );
        });
  }

  confirmdialog(index) {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          String typed;
          final _formKey = GlobalKey<FormState>();
          return CupertinoAlertDialog(
            title: Text('Alert',
                style: TextStyle(
                  color: Colors.red,
                  // fontFamily: 'Comfortaa',
                  // fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                )),
            content: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  'Do you really want to save changes',
                  style: TextStyle(
                    color: Colors.red,
                    // fontFamily: 'Comfortaa',
                    // fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Note: You will not be able to receive notifications for the unsubscribed topics',
                  style: TextStyle(fontSize: 10.0, ),
                ),
                SizedBox(height: 10.0),
                RichText(
                    text: TextSpan(
                        text: 'Type ',
                        // style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                      TextSpan(
                          text: 'Yes ',
                          style: TextStyle(
                              // color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: 'to continue',
                          // style: TextStyle(color: Colors.black)
                          )
                    ])),
                SizedBox(height: 20.0),
                Material(
                  color: Colors.transparent,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      decoration: new InputDecoration(
                        // labelText: 'Tags',
                        hintText: 'Yes',
                        // icon: new Icon(
                        //   Icons.mail,
                        //   color: Colors.grey,
                        // )
                      ),
                      onChanged: (value) {
                        typed = value;
                      },
                      // autovalidate: true,
                      validator: (value) =>
                          value.isEmpty ? 'Field can\'t be empty' : null,
                      onSaved: (val) => typed = val,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      CupertinoButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.pop(context)),
                      RaisedButton(
                          color: Colors.red[900],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              if (typed == 'Yes' || typed == 'yes') {
                                setState(() {
                                  Navigator.pop(context);
                                  setState(() {
                                    prefSel.clear();
                                    for (var i = 0;
                                        i < selectionData[0].isSelected.length;
                                        i++) {
                                      if (selectionData[0].isSelected[i] ==
                                          true) {
                                        // if(!prefSel.contains(selectionData[0].name[i])){
                                        prefSel.add(selectionData[0].name[i]);
                                        // }
                                      }
                                      // else{
                                      //   if(prefSel. prefSel.contains(selectionData[0].name[i])){
                                      //     prefSel.remove(selectionData[0].name[i]);
                                      //   }
                                      // }
                                    }
                                    setState(() {
                                      _loading = true;
                                    });
                                    onUpdate(prefSel).then((var v) {
                                      if (v) {
                                        setState(() {
                                          _loading = false;
                                        });
                                      }
                                    });
                                  });
                                });
                              }
                            }
                          },
                          child: Text('Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              )))
                    ])
              ],
            ),
          );
        });
  }
}

var unsubscribe = [];
var subscribe = [];
Future<bool> onUpdate(List<String> prefsel) async {
  var val;
  var uid;
  var same = false;
  Fluttertoast.showToast(msg: 'Saving Preferences');
  return await readContent('users').then((var value) async {
    var prefs = value['prefs'];
    uid = value['uid'];
    print(uid);
    val = value;
    subscribe.clear();
    unsubscribe.clear();

    print(prefs.toString() + ' prefs');
    for (var i in prefsel) {
      if (!prefs.contains(i)) {
        subscribe.add(i);
        // unsubscribe.remove(i);
      }
    }
    print(prefsel.toString() + ' prefsel');
    for (var i in prefs) {
      if (!prefsel.contains(i)) {
        print(i);
        unsubscribe.add(i);
      }
    }
    print(subscribe.toString() + 'subscribe');
    print(unsubscribe.toString() + 'unsubscribe');

    if (subscribe.length == 0 && unsubscribe.length == 0) {
      same = true;
      Fluttertoast.showToast(msg: 'Done!!!');
      return true;
    }
    val['prefs'] = prefsel;
    print(val);
    print(same);
    subscribeUnsubsTopic(subscribe, unsubscribe);
    // deleteContent('users').whenComplete((){
    if (val != null) {
      await writeContent('users', json.encode(val)).then((var v) {
        if (v) {
          action();
        }
      });
    }
    return await updateInFireBase(uid, prefsel).then((v) {
      Fluttertoast.showToast(msg: 'Done!!!');
      return true;
    });
  });
  // });
}

checkSpace(String name) {
  return name.replaceAll(' ', '_');
}

final FirebaseMessaging _fcm = FirebaseMessaging();
void subscribeUnsubsTopic(var subscribe, var unsubscribe) {
  for (var i in unsubscribe) {
    _fcm.unsubscribeFromTopic(checkSpace(i).toString());
  }
  for (var i in subscribe) {
    _fcm.subscribeToTopic(checkSpace(i).toString());
  }
}

dynamic action() {
  readContent('users').then((var value) {
    return print(value['prefs'].toString() + 'pref');
  });
  return print('nothing');
}
