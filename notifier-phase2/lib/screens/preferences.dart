
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/model/hive_models/hive_allCouncilData.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/loading.dart';
import 'package:notifier/widget/showtoast.dart';

class Preferences extends StatefulWidget {
  Preferences(this.auth, this.logoutCallback, this.userId, this.allCouncilData,
      this.usersBox);
  final BaseAuth auth;
  final Function logoutCallback;
  final String userId;
  final Councils allCouncilData;
  final Box usersBox;
  // final List<bool> select;
  // va
  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  List<Widget> list = List();
  bool _loading = false;
  bool _loadingWid = false;
  List<Widget> tabBarItem = [];
  List<Tab> prefsTabs = [];
  // var _councilsData;
  int noOfTabs = 0;
  var _prefs;
  Box peopleBox ;
  // Box widget.usersBox ;
  // var globalPostMap = {};
  initPeopleBox() async{
    peopleBox  = await HiveDatabaseUser(databaseName: 'people').hiveBox;
    // widget.usersBox  = await HiveDatabaseUser().hiveBox;
    _prefs = widget.usersBox.toMap()[0].prefs;
    setState(() {
        _loadingWid = false;
      });
     buildTabs();
  }
  @override
  void initState() {
    widget.allCouncilData.subCouncil.values.toList().forEach((element) {
      if(element.entity.length != 0)
        noOfTabs++;
    });
    _loading = false;
    _loadingWid = true;
    initPeopleBox();

    super.initState();
  }
  buildTabs() {
    for (var i in widget.allCouncilData.subCouncil.values.toList()) {
      if(i.entity.length != 0){
        prefsTabs.add(
          Tab(
            child: Container(
              width: MediaQuery.of(context).size.width*0.3,
              child: Center(child: Text(convertToCouncilName(i.council.toString()),)),
            )
            
          ),
        );
      }
      print(i.council);
      print(i.entity);
      for (var index = 0; index < i.entity.length; index++) {
        if(_prefs.contains(i.entity[index])){
          // i.select.insert(index, true);
          i.select[index] = true;
        }
        else{
          print(i.entity[index]);
          //  i.select.insert(index, false);
           i.select[index] =  false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_loadingWid
        ? AbsorbPointer(
          absorbing: _loading,
          child: DefaultTabController(
              length: noOfTabs,
              child: Scaffold(
                  appBar: new AppBar(
                      title: new Text('Preferences'),
                      bottom: TabBar(
                        isScrollable: true,
                        tabs: [
                        ...prefsTabs.toList(),
                      ],
                        // labelColor: Colors.white,
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
                                  for (var i in widget.allCouncilData.subCouncil.values.toList())
                                    if(i.entity.length != 0)
                                      listItem(i),
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
                                    confirmdialog(0,context);
                                  },
                                  child: Text(
                                    'Update',
                                    style: TextStyle(
                                      color: Colors.white,
                                      // fontFamily: 'Comfortaa',
                                      // fontWeight: FontWeight.bold,
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
                          ? Container(
                            height: MediaQuery.of(context).size.height,
                            color: Colors.black.withOpacity(0.8),
                            child: Center(child:Loading(display: '',),),
                          )
                          : Container()
                    ],
                  ))),
        )
        : Loading(display: 'loading prefrences',);
  }

  Widget listItem(SubCouncil i) {
    return ListView.builder(
        itemCount: i.entity.length,
        itemBuilder: (BuildContext context, int index) {
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
                        activeColor: Colors.accents[5],
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
                      toolbarOptions: ToolbarOptions(
                                      copy: true,
                                      paste: true,
                                      selectAll: true,
                                    ),
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      decoration: new InputDecoration(
                        hintText: name.entity[key],
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
                              ? 'Type the correct name of topic to Unsubscribe it'
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

  confirmdialog(index,contexts) {
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
                      toolbarOptions: ToolbarOptions(
                                      copy: true,
                                      paste: true,
                                      selectAll: true,
                                    ),
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      decoration: new InputDecoration(
                        // labelText: 'Tags',
                        hintText: 'Yes',
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
                              SystemChannels.textInput.invokeMethod('TextInput.hide');
    
                              if (typed == 'Yes' || typed == 'yes') {
                                setState(() {
                                  Navigator.pop(context);
                                  setState(() {
                                    // prefSel.clear();
                                    Map<String,SubCouncil> prefSel ={};
                                        // List(allCouncilData.subCouncil.length);
                                    // print(prefSel[1].misc);
                                    for (var i in widget.allCouncilData.subCouncil.values.toList()) {
                                      prefSel.update(i.council, (v)=>SubCouncil(entity: [], misc: [], council: i.council),
                                        ifAbsent: ()=>SubCouncil(entity: [], misc: [], council: i.council)
                                      );
                                      // prefSel[allCouncilData.subCouncil
                                      //         .indexOf(i)] =
                                      //     SubCouncil([], [], i.council);
                                      // prefSel[i.council].entity.add(i.entity[i.select.indexOf(i.select.where((test)=> test))])
                                      for (var j in i.entity) {
                                        // print(j);
                                        if (i.select[i.entity.indexOf(j)] ==
                                            true) {
                                          // print(j);
                                          // prefSel[i.council]['entity'].add(i.entity[i.select.indexOf(j)]);
                                          // List<String> misc;
                                          // prefSel[i.council]['misc'].addAll(i.misc);
                                          // misc..addAll(i.misc);

                                          // prefSel[allCouncilData.subCouncil
                                          //         .indexOf(i)]
                                          //     .entity
                                          //     .add(j);
                                          prefSel[i.council].entity.add(j);
                                          // prefSel[allCouncilData.subCouncil.indexOf(i)]..add(j);
                                          // prefSel[i.council].map((map)=>allCouncilData.subCouncil.where((item) =>item.select == true).map((item) => ));
                                          // prefSel.add(i.entity[i.select.indexOf(j)]);
                                        }
                                        prefSel[i.council].misc = i.misc;
                                        // prefSel[allCouncilData.subCouncil
                                        //         .indexOf(i)]
                                        //     .misc = i.misc;
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
                                        'entity': prefSel['snt'].entity,
                                            // .map((map) => map.entity),
                                        'misc': prefSel['snt'].misc
                                            // .where(
                                            //     (item) => item.council == 'snt')
                                            // .map((map) => map.misc),
                                      },
                                    };
                                    prefSel.forEach((council,f) {
                                      data.update(f.council, (v) {
                                        return {
                                          'entity': prefSel[council].entity,
                                              // .where((item) =>
                                              //     item.council == f.council)
                                              // .map((map) => map.entity),
                                          'misc': prefSel[council].misc
                                              // .where((item) =>
                                              //     item.council == f.council)
                                              // .map((map) => map.misc),
                                        };
                                      }, ifAbsent: () {
                                        return {
                                          'entity': prefSel[council].entity,
                                              // .where((item) =>
                                              //     item.council == f.council)
                                              // .map((map) => map.entity),
                                          'misc': prefSel[council].misc
                                              // .where((item) =>
                                              //     item.council == f.council)
                                              // .map((map) => map.misc),
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
                                        // widget.logoutCallback();
                                        Navigator.pop(contexts,'reload');
                                      }else{
                                        setState(() {
                                          _loading = false;
                                        });
                                        showErrorToast('Something Went wrong while loading your preferences please start the app again');
                                      }
                                    }).catchError((onError){
                                      print(onError);
                                      setState(() {
                                          _loading = false;
                                        });
                                      showErrorToast('Something Went wrong');
                                    });
                                  });
                                });
                              }
                            }
                          },
                          child: Text('Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                // fontFamily: 'Comfortaa',
                                // fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              )))
                    ])
              ],
            ),
          );
        });
  }

  var unsubscribe = [];
  var subscribe = [];
  Future<bool> onUpdate(Map<String,SubCouncil> prefSel) async {
    // var val;
    // var uid;
    List<String> prefsel = [];
    prefSel.forEach((council,f) {
      prefsel+= f.entity;
    });
    var same = false;
    showInfoToast('Saving Preferences!!!');
    List<String> prefs = [];
      var data = {};
      prefs = widget.usersBox.toMap()[0].prefs;
      widget.usersBox.toMap()[0].prefs =[""];
      prefSel.forEach((council,f) {
        widget.usersBox.toMap()[0].prefs += (f.entity);
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
      

      for (var i in widget.allCouncilData.subCouncil.values.toList()) {
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
      // uid = widget.usersBox['uid'];
      // print(uid);
      // val = value;
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
        showSuccessToast('Your preferences have been updated!!');
        return true;
      }
      print(same);
      subscribeUnsubsTopic(subscribe, unsubscribe);
      
      await widget.usersBox.putAt(0, widget.usersBox.toMap()[0]).then((v){
        // return true;
      }).catchError((onError){
        print(onError);
      });
      return await updatePrefsInFirebase(widget.usersBox.toMap()[0].uid, data).then((v) {
        showSuccessToast('Your preferences have been updated!!');
        return true;
      }).catchError((onError){
        print(onError);
        return false;
      }).timeout(Duration(seconds: 20),onTimeout: ()=>false);
    // });
    // });
  }
}

checkSpace(String name) {
  return name.replaceAll(' ', '_');
}

// final FirebaseMessaging _fcm = FirebaseMessaging();
// void subscribeUnsubsTopic(var subscribe, var unsubscribe) {
 
//   for (var i in unsubscribe) {
//     if(i!=null && i!= ""){
//     _fcm.unsubscribeFromTopic(checkSpace(i).toString());
//     }
//   }
//   for (var i in subscribe) {
    
//     if(i!=null && i!= ""){
//       // print(i + 'subscribe to topic');
//       _fcm.subscribeToTopic(checkSpace(i).toString());
//     }
//   }
// }

// dynamic action() {
//   readContent('users').then((var value) {
//     return print(value['council'].toString() + 'pref');
//   });
//   return print('nothing');
// }
