import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/data/data.dart';
// import 'package:notifier/data/data.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/databse.dart';

class Preferences extends StatefulWidget {
  Preferences(this.auth, this.logoutCallback, this.userId, this.allCouncilData,
      this.firstTimeOpen);
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final Councils allCouncilData;
  final bool firstTimeOpen;
  // final List<bool> select;
  // va
  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  List<Widget> list = List();

  // Map<String,Map<String,dynamic>> prefSel = {
  //     "snt":{
  //       'entity':[],
  //       'misc':[],
  //     },
  //     "mnc":{
  //       'entity':[],
  //       'misc':[],
  //     },
  //     "anc":{
  //       'entity':[],
  //       'misc':[],
  //     },
  //     "gns":{
  //       'entity':[],
  //       'misc':[],
  //     },
  //     "ss":{
  //       'entity':[],
  //       'misc':[],
  //     }

  // };
  // List<bool> select = List();
  bool _loading = false;
  bool _loadingWid = false;
  List<String> _prefs = List();
  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  // List<Map<String,bool>> entitesAndMisc = [];
  List<Widget> tabBarItem = [];
  // print(widget.allCouncilData);
  List<Tab> prefsTabs = [];
  var _councilsData;

  @override
  void initState() {
    _loading = false;
    _loadingWid = true;
    readContent('users').then((var value) {
      print('reading users');
      if (value != null) {
        setState(() {
          // _prefs = value['prefs'].cast<String>();
          _councilsData = value['council'];
        });
        // setState(() {
        //   _prefs.remove('Science and Technology Council');
        //   _prefs.remove('Techkriti');
        // });
      }
      setState(() {
        _loadingWid = false;
      });

      buildTabs();
    });

    super.initState();
  }
  buildTabs() {
    for (var i in widget.allCouncilData.subCouncil) {
      prefsTabs.add(
        Tab(
          text: i.council.toString(),
          
        ),
      );
      for (var index = 0; index < i.entity.length; index++) {
        // if (_prefs.contains(i.entity[index])) {
        //   // setState(() {
        //   i.select.insert(index, true);
        //   // print(true);
        //   // });
        // } else {
        //   // setState(() {
        //   i.select.insert(index, false);
        //   // });
        // }
        if(_councilsData[i.council.toString()]["entity"].contains(i.entity[index])){
          i.select.insert(index, true);
        }
        else{
           i.select.insert(index, false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_loadingWid
        ? DefaultTabController(
            length: allCouncilData.subCouncil.length,
            child: Scaffold(
                appBar: new AppBar(
                    title: new Text('Preferences'),
                    bottom: TabBar(tabs: [
                      ...prefsTabs.toList(),
                    ],
                      labelColor: Colors.white,
                    )),
                body: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height - 180.0,
                            child: TabBarView(
                              // children: tabBarItem.toList(),
                              children: <Widget>[
                                // ...tabBarItem.toList(),
                                for (var i in widget.allCouncilData.subCouncil)
                                  listItem(i),
                                // }
                                //   ListView.builder(
                                //       itemCount: selectionData[0].name.length,
                                //       itemBuilder: (BuildContext context, int index) {
                                //         return Container(
                                //               child: Row(
                                //                 children: <Widget>[
                                //                   Container(
                                //                     width: MediaQuery.of(context).size.width * 0.7,
                                //                     // decoration: Decoration(),
                                //                     padding: EdgeInsets.only(left: 30.0),
                                //                     child: Text(
                                //                       selectionData[0].name[index],
                                //                       style: TextStyle(
                                //                         fontFamily: 'Nunito',
                                //                         // fontWeight: FontWeight.bold,
                                //                         fontSize: 15.0,
                                //                       ),
                                //                     ),
                                //                   ),
                                //                   Container(
                                //                     width: MediaQuery.of(context).size.width * 0.3,
                                //                     child: Align(
                                //                       alignment: Alignment.centerLeft,
                                //                       child: Switch(
                                //                         value: selectionData[0].isSelected[index],
                                //                         onChanged: (value) {
                                //                           if (!value) {
                                //                             setState(() {
                                //                               confirmdialogForPrefs(
                                //                                   index,
                                //                                   selectionData[0].name[index],
                                //                                   value);
                                //                             });
                                //                             print(value.toString() +
                                //                                 ':' +
                                //                                 selectionData[0].name[index]);

                                //                             // }
                                //                           } else {
                                //                             setState(() {
                                //                               selectionData[0].isSelected[index] =
                                //                                   value;
                                //                               print(value.toString() +
                                //                                   ':' +
                                //                                   selectionData[0].name[index]);
                                //                             });
                                //                           }
                                //                         },
                                //                         // activeTrackColor: Colors.lightGreenAccent,
                                //                         // activeColor: Colors.green,
                                //                       ),
                                //                     ),
                                //                   )
                                //                 ],
                                //               ),
                                //             );

                                //       }),
                              ],
                            ),
                          ),
                          Container(
                            height: 50.0,
                            width: MediaQuery.of(context).size.width,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black38
                                    : Colors.white,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              width: 150.0,
                              padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    _loading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container()
                  ],
                )))
        : Container();
  }

  Widget listItem(SubCouncil i) {
    return ListView.builder(
        itemCount: i.entity.length,
        itemBuilder: (BuildContext context, int index) {
          // if(widget.firstTimeOpen){

          // }
          return Container(
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  // decoration: Decoration(),
                  padding: EdgeInsets.only(left: 30.0),
                  child: Text(
                    // keyList[index],
                    i.entity[index],
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
                      child: Checkbox(
                        value: i.select[index],
                        onChanged: (value) {
                          if (!value) {
                            // setState(() {
                            confirmdialogForPrefs(index, i, value);
                            // });
                            print(value.toString() + ':' + i.entity[index]);
                          } else {
                            setState(() {
                              i.select[index] = value;
                              print(value.toString() + ':' + i.entity[index]);
                            });
                          }
                        },
                      )
                      // child: Switch(
                      //   dragStartBehavior: DragStartBehavior.start,
                      //   // value: i[keyList[index]],
                      //   value: i.select[index],
                      //     onChanged: (value) {
                      //       if (!value) {
                      //         // setState(() {
                      //           confirmdialogForPrefs(index,i,value);
                      //         // });
                      //         print(value.toString() +':' +i.entity[index]);
                      //       }
                      //       else {
                      //         setState(() {
                      //           i.select[index] = value;
                      //           print(value.toString() +':' +i.entity[index]);
                      //         });
                      //       }
                      //     },
                      // activeTrackColor: Colors.lightGreenAccent,
                      // activeColor: Colors.green,
                      // ),
                      ),
                )
              ],
            ),
          );
        });
  }

  confirmdialogForPrefs(int key, SubCouncil name, value) {
    return showDialog(
        context: context,
        builder: (context) {
          String typed;
          final _formKey = GlobalKey<FormState>();
          //  TextFormField _unsubscribe = GlobalKey<TextS>;
          return AlertDialog(
            title: Row(
              children: <Widget>[
                Icon(Icons.warning,
                  color: Colors.red,
                ),
                Text('  Alert',
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      // fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    )),
              ],
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Do you really want to unsubscribe \n'+ name.entity[key],
                textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      // fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    )),
                SizedBox(height: 10.0),
                Text(
                  'Note: You will not be able to receive any notification from ' + name.entity[key],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 10.0),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: 'Type ',
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: name.entity[key],
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ' to continue',
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black))
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
                        hintText: name.entity[key],
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
                          : value != name.entity[key] &&
                                  value !=
                                      name.entity[key].toString().toLowerCase()
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
                        onPressed: () {
                          setState(() {
                            name.select[key] = true;
                          });
                          Navigator.pop(context);
                        }),
                    RaisedButton(
                        color: Colors.red[900],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            if (typed == name.entity[key].toString() ||
                                typed ==
                                    name.entity[key].toString().toLowerCase()) {
                              setState(() {
                                print(typed.toLowerCase());
                                name.select[key] = value;
                                // Navigator.pop(context);
                              });
                              Navigator.pop(context);
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
          return AlertDialog(
            title: Row(
              children: <Widget>[
                Icon(Icons.warning,
                  color: Colors.red,
                ),
                Text('  Alert',
                    style: TextStyle(
                      color: Colors.red,
                      // fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    )),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Do you really want to save changes',
                  style: TextStyle(
                    color: Colors.red,
                    // fontFamily: 'Comfortaa',
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Note: You will not be able to receive notifications for the unsubscribed topics',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  ),
                ),
                SizedBox(height: 10.0),
                RichText(
                    text: TextSpan(
                        text: 'Type ',
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                        children: <TextSpan>[
                      TextSpan(
                          text: 'Yes ',
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: 'to continue',
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black))
                    ])),
                SizedBox(height: 10.0),
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
                                    // prefSel.clear();
                                    List<Prefren> prefSel =
                                        List(allCouncilData.subCouncil.length);
                                    // print(prefSel[1].misc);
                                    for (var i
                                        in widget.allCouncilData.subCouncil) {
                                      prefSel[allCouncilData.subCouncil
                                              .indexOf(i)] =
                                          Prefren([], [], i.council);
                                      for (var j in i.entity) {
                                        // print(j);
                                        if (i.select[i.entity.indexOf(j)] ==
                                            true) {
                                          // print(j);
                                          // prefSel[i.council]['entity'].add(i.entity[i.select.indexOf(j)]);
                                          // List<String> misc;
                                          // prefSel[i.council]['misc'].addAll(i.misc);
                                          // misc..addAll(i.misc);

                                          prefSel[allCouncilData.subCouncil
                                                  .indexOf(i)]
                                              .entity
                                              .add(j);
                                          // prefSel[allCouncilData.subCouncil.indexOf(i)]..add(j);
                                          // prefSel[i.council].map((map)=>allCouncilData.subCouncil.where((item) =>item.select == true).map((item) => ));
                                          // prefSel.add(i.entity[i.select.indexOf(j)]);
                                        }

                                        prefSel[allCouncilData.subCouncil
                                                .indexOf(i)]
                                            .misc = i.misc;
                                      }

                                      // print(i.select.length);
                                      // print(i.entity.length);
                                      //   // else{
                                      //   //   if(prefSel. prefSel.contains(selectionData[0].name[i])){
                                      //   //     prefSel.remove(selectionData[0].name[i]);
                                      //   //   }
                                      //   // }
                                    }
                                    var data = {
                                      'snt': {
                                        'entity': prefSel
                                            .where(
                                                (item) => item.council == 'snt')
                                            .map((map) => map.entity),
                                        'misc': prefSel
                                            .where(
                                                (item) => item.council == 'snt')
                                            .map((map) => map.misc),
                                      },
                                    };
                                    prefSel.forEach((f) {
                                      data.update(f.council, (v) {
                                        return {
                                          'entity': prefSel
                                              .where((item) =>
                                                  item.council == f.council)
                                              .map((map) => map.entity),
                                          'misc': prefSel
                                              .where((item) =>
                                                  item.council == f.council)
                                              .map((map) => map.misc),
                                        };
                                      }, ifAbsent: () {
                                        return {
                                          'entity': prefSel
                                              .where((item) =>
                                                  item.council == f.council)
                                              .map((map) => map.entity),
                                          'misc': prefSel
                                              .where((item) =>
                                                  item.council == f.council)
                                              .map((map) => map.misc),
                                        };
                                      });
                                    });
                                    print(data);
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

  var unsubscribe = [];
  var subscribe = [];
  Future<bool> onUpdate(List<Prefren> prefSel) async {
    var val;
    var uid;
    List<String> prefsel = [];
    prefSel.forEach((f) {
      prefsel += f.entity;
    });
    var same = false;
    Fluttertoast.showToast(msg: 'Saving Preferences');
    List<String> prefs = [];
    return await readContent('users').then((var value) async {
      // List<dynamic> prefs = value['prefs'];
      var councilData = value['council'];
      councilData.keys.forEach((key){
        prefs += councilData[key]["entity"].cast<String>(); 
      });
      var data = {};
      prefSel.forEach((f) {
        data.update(f.council, (v) {
          return {
            'entity': f.entity,
            'misc': f.misc,
          };
        }, ifAbsent: () {
          return {
            'entity': f.entity,
            'misc': f.misc,
          };
        });
      });
      

      for (var i in widget.allCouncilData.subCouncil) {
        if (i.misc != null && i.misc.isNotEmpty) {
          i.misc.forEach((f) {
            if (prefs.contains(f.toString())) {
              prefs.remove(f.toString());
            }
          });
        }
      }
      // prefs.remove('Science and Technology Council');
      // prefs.remove('Techkriti');
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
      val["council"] = data;
      // val['prefs'] = prefsel;
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
      print(prefsel.toString() + 'prefsel');
      // if(widget.allCouncilData.subCouncil.iterator.current.misc != null && widget.allCouncilData.subCouncil.iterator.current.misc.isNotEmpty){
      //   for (var i in widget.allCouncilData.subCouncil.iterator.current.misc) {
      //   prefsel.add(i.toString());
      // }
      // }
      // print(prefsel.toString() +'prefsel');
      // return true;
      
      // prefsel += prefsel.addAll(widget.allCouncilData.iterator.current.misc.iterator.to);
      return await updateInFireBase(uid, data).then((v) {
        Fluttertoast.showToast(msg: 'Done!!!');
        return true;
      });
    });
    // });
  }
}

checkSpace(String name) {
  return name.replaceAll(' ', '_');
}

final FirebaseMessaging _fcm = FirebaseMessaging();
void subscribeUnsubsTopic(var subscribe, var unsubscribe) {
 
  for (var i in unsubscribe) {
    if(i!=null && i!= ""){
    _fcm.unsubscribeFromTopic(checkSpace(i).toString());
    }
  }
  for (var i in subscribe) {
    
    if(i!=null && i!= ""){
      // print(i + 'subscribe to topic');
      _fcm.subscribeToTopic(checkSpace(i).toString());
    }
  }
}

dynamic action() {
  readContent('users').then((var value) {
    return print(value['council'].toString() + 'pref');
  });
  return print('nothing');
}
