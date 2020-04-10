import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/data/data.dart';
import 'package:notifier/main.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/model/todo.dart';
import 'package:notifier/screens/about.dart';
import 'package:notifier/screens/posts/drafts/drafts.dart';
import 'package:notifier/screens/posts/notification/notification.dart';
import 'package:notifier/screens/posts/createposts.dart';
import 'package:notifier/screens/make_coordi.dart';
import 'package:notifier/screens/posts/notification/prefs_home.dart';
import 'package:notifier/screens/posts/update/updateposts.dart';
// import 'package:notifier/screens/posts/updateposts.dart';
import 'package:notifier/screens/preferences.dart';
import 'package:notifier/screens/profile.dart';
import 'dart:async';

import 'package:notifier/services/databse.dart';
import 'package:notifier/services/function.dart';

class HomePage extends StatefulWidget {
  HomePage(
      {Key key, this.darkMode, this.auth, this.userId, this.logoutCallback})
      : super(key: key);
  final bool darkMode;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

bool admin;

// List<dynamic> sortedarray = List();
// List<UpdatePostsFormat> timenots = List();

  Councils allCouncilData;
class _HomePageState extends State<HomePage> {
  // List<Todo> _todoList;
  var id;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flnp = FlutterLocalNotificationsPlugin();
  String _name;
  String _rollno;
  List<dynamic> ids = List();
  List<dynamic> _prefs = [];
  String display;
  String bodyMsg;
  String data;
  String uid;
  var load = false;
  List<String> _subs = List();
  bool darkMode;
  bool _loadNew = false;
  bool error = false;
  Future<bool> loadEVERY() async {
    load = true;
    setState(() {
      // _loadNew = load? false:true;
    });

    return await procedure().then((bool v) async {
      print(v.toString() + ':procedure line45 home.dart');
      if (v != null && v) {
        setState(() {
          addStringToSF(DateTime.now().toIso8601String());
        });
        return await readContent('snt').then((var val) {
          print('snt values line56 of home.dart:' + val.toString());
          // print(sortedarray);
          // sortedarray.clear();
          if (val != null) {
            Map<String,SortDateTime> arr = {};
            // print(val.keys.length);
            val.keys.forEach((key) {
              // var v = DateTime.parse('2020-03-23T17:26:56.295');
              if (val[key]['exists'] == false) {
                if(arr.containsKey(key)){
                  arr.remove(key);
                }
                // print('values whoose esists is false line57 home.dart:'+val[key].toString());
                // val.remove(key);
              } else {
                DateTime postTime = DateTime.parse(val[key]['timeStamp']);
                // postTime = DateTime.now();
                // postTime = DateTime(year)
                var time;
                time = checkTime(postTime).toString();
                arr.update(key, (v)=> SortDateTime( key, DateTime.parse(val[key]['timeStamp']).toUtc().millisecondsSinceEpoch,
                          val[key],val[key]['sub'][0],time),
                          ifAbsent: ()=>SortDateTime( key, DateTime.parse(val[key]['timeStamp']).toUtc().millisecondsSinceEpoch,
                          val[key],val[key]['sub'][0],time)
                          );
                          // print(arr);
                // if (DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch>) {
                //   if(DateTime.now().day == postTime.day){
                //     time= 'Today';
                //   }
                //   else{
                //     time = 'Yesterday';
                //   }
                // } else {
                //   time = DateFormat('d MMMM, yyyy').format(postTime);
                // }
                // if(sortedarray.length!=0){
                //   // sortedarray.forEach((item) {
                //   // if(item.uid == key){
                //   //   item = SortDateTime( key, DateTime.parse(val[key]['timeStamp']).toUtc().millisecondsSinceEpoch,
                //   //         val[key],val[key]['sub'][0],time);
                //   // }
                //   // else{
                //   //   sortedarray.insert(0,
                //   //     SortDateTime( key, DateTime.parse(val[key]['timeStamp']).toUtc().millisecondsSinceEpoch,
                //   //         val[key],val[key]['sub'][0],time));
                //   // }
                // });
                // }else{
                  // if(sortedarray.length!=0 ){
                  //   sortedarray.where((item)=> item.uid == key).forEach((f){
                  //     if(f.uid == key){f = SortDateTime( key, DateTime.parse(val[key]['timeStamp']).toUtc().millisecondsSinceEpoch,
                  //         val[key],val[key]['sub'][0],time);}
                  //   });
                  // }else{
                  //   sortedarray.insert(0,
                  //     SortDateTime( key, DateTime.parse(val[key]['timeStamp']).toUtc().millisecondsSinceEpoch,
                  //         val[key],val[key]['sub'][0],time));
                  // }
                  
                  // arr.values.toList()
                // }
                  // 
                
                // if (!sortedarray.contains(SortDateTime( key, DateTime.parse(val[key]['timeStamp']).toUtc().millisecondsSinceEpoch,
                //   val[key],val[key]['sub'][0],time
                // ))) {
                //   // sortedarray.insert(0, element);
                //   sortedarray.insert(0,
                //       SortDateTime( key, DateTime.parse(val[key]['timeStamp']).toUtc().millisecondsSinceEpoch,
                //           val[key],val[key]['sub'][0],time));
                //   // print(sortedarray[0].date);
                // }
              }
            });
            sortedarray= arr.values.toList();
            return true;
          }
          return false;
        });
      }
      return false;
      // print(v);
    });
  }

  sortarrayWithTime() {

    for (var i = 0; i < sortedarray.length; i++) {
      for (var j = i + 1; j < sortedarray.length; j++) {
        if (sortedarray[i].uid == sortedarray[j].uid) {
          // sortedarray[j].value = sortedarray[i].value;
          sortedarray.remove(sortedarray[j]);
          continue;
        }
        
    //     // print('\'diff:' + sortedarray[i].value.toString());
    //     if (sortedarray[i].date < sortedarray[j].date) {
    //       SortDateTime temp = sortedarray[i];
    //       sortedarray[i] = sortedarray[j];
    //       sortedarray[j] = temp;
    //       temp = null;
    //     }
      }
    }
    sortedarray.sort((a,b) => b.date.compareTo(a.date));
  }

  List<DateTime> timeofRefresh = List(2);
  loadSnt() {
    // timeofRefresh DateTime.now();
    loadEVERY().then((bool status) {
      if (status) {
        setState(() {
          print(sortedarray.length.toString() + 'sortedarray');
          // print(sortedarray.length);
          sortarrayWithTime();
          sortedarray.forEach((f) {
            // print('\'sortedarray\':'+f.value.toString());
          });
          if (sortedarray != null) {
            _loadNew = false;
            load = false;
          }
        });
      }else{
        setState(() {
          _loadNew = false;
          load = false;
          error = true;
        });
      }
    });
  }
  Future<Councils> fullData()async{
    return await councilData().then((var data) async{
      if(data!=null){
        print(data);
        allCouncilData = data;
        for (var i in allCouncilData.subCouncil) {
          ids+= i.level2;
        }
      return allCouncilData;
      }else{
        setState(() {
          error = true;
        });
        return null;
        // buildErrorWidget;
      }
    });
  }
 var _councilDataForMe;
  @override
  void initState() {
    super.initState();
    load = true;
    // _fcm.autoInitEnabled()
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage :$message" + ' isthe message');
         showNotification(message['data']);
        setState(() {
          // addStringToSF(DateTime.now().toIso8601String());
        // loadSnt();
          // newNotf = true;
          bodyMsg = message['notification']['body'];
          data = message['data']['message'];
          display = message['notification']['title'];
        });
      },
      onResume: (Map<String, dynamic> message) async {
        showNotification(message['data']);
        _fcm.autoInitEnabled();
        // AndroidNotificationDetails(channelId, channelName, channelDescription);
        print("onResume : $message" + 'is fromResume');
        setState(() {
          // addStringToSF(DateTime.now().toIso8601String());
          // loadEVERY();
          // newNotf = true;
          bodyMsg = message['notification']['body'];
          display = message['notification']['title'];
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        showNotification(message['data']);
        print("onLaunch: $message" + ':is fromLaunch');
        setState(() {
          // addStringToSF(DateTime.now().toIso8601String());
          // loadEVERY();
          // newNotf = true;
          bodyMsg = message['notification']['body'];
          display = message['notification']['title'];
        });
        // onUpdate(prefsel)
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
    configLocalNotification();
    fullData().then((var val){
      if(val !=null){
        readContent('users').then((var value) async {
          print(value.toString() + ' readinng value from users');
          if (value != null) {
            print(value);
            setState(() {
              uid = value['uid'];
              id = value['id'];
              admin = value['admin'];
              _prefs = value['prefs'];
              _name = value['name'];
              _rollno = value['rollno'];
              // var prefer =[];
              // Map<String,Map<String,Iterable<String>>> data;
              _councilDataForMe = value['council'];
              print(_councilDataForMe);
              _councilDataForMe.keys.forEach((key){
                _prefs += (_councilDataForMe[key]["entity"] + _councilDataForMe[key]["misc"]);
              });
              // print(prefer);
               allCouncilData.subCouncil.forEach((f){
            //      for (var i in f.entity) {
            //        var index = f.entity.indexOf(i);
            //      if(_prefs.contains(i)){
            //   // setState(() {
            //         f.select.insert(index, true);
            //     // print(true);
            //   // });
            //     }
            //       else{
            //   // setState(() {
            //     f.select.insert(index, false);
            //   // });
            // }
            //    }
               });
              // print(_prefs + ['Science and Technology Council']);

              print('reading users preferences' + value.toString());
              subscribeUnsubsTopic(_prefs.toList(), []);
              print(admin);
              if (admin != null && (admin == true)) {
                fileExists('people').then((bool fileExists) async {
                  if (!fileExists) {
                    // people = true;
                    populatePeople(id).then((var status) async {
                      print(status.toString() + ' status for people');
                      if (status) {
                        // await fileExists('people').then((bool v) {
                        //   if (v) {
                        print('reading people');
                        readPeople().then((var val) {
                          print(val);
                          if (val != null) {
                            if(val['councils']!=null)
                            {
                              allCouncilData.coordOfCouncil = val['councils'].cast<String>(); 
                              for (var i in val['councils']) {
                              var index = allCouncilData.globalCouncils.indexOf(i);
                              // _subs.add(i.toString());
                              // print(i);
                              allCouncilData.subCouncil[index].coordiOfInCouncil = val['$i'].cast<String>();
                            }
                            }
                            
                          } else {
                            print('file Is empty');
                          }
                        });
                      }
                    });
                  } else {
                    readPeople().then((var v) async {
                      if (v == null) {
                        if (peopleArr == null) {
                          return await populatePeople(id).then((var status) async {
                            print(status.toString() + ' status for people');
                            if (status) {
                              // await fileExists('people').then((bool v) {
                              //   if (v) {
                              print('reading people');
                              readPeople().then((var val) {
                                if (val != null) {
                                  if(val['councils']!=null)
                            {
                              allCouncilData.coordOfCouncil = val['councils'].cast<String>(); 
                              for (var i in val['councils']) {
                              var index = allCouncilData.globalCouncils.indexOf(i);
                              // _subs.add(i.toString());
                              // print(i);
                              allCouncilData.subCouncil[index].coordiOfInCouncil = val['$i'].cast<String>();
                            }
                            }
                                } else {
                                  print('file Is empty');
                                }
                              });
                            }
                          });
                        } else {
                          return await writeContent(
                                  'people', json.encode(peopleArr))
                              .whenComplete(() {
                            print('done!! people');
                           if (v != null) {
                                  if(v['councils']!=null)
                            {
                              allCouncilData.coordOfCouncil = v['councils'].cast<String>(); 
                              for (var i in v['councils']) {
                              var index = allCouncilData.globalCouncils.indexOf(i);
                              // _subs.add(i.toString());
                              // print(i);
                              allCouncilData.subCouncil[index].coordiOfInCouncil = v['$i'].cast<String>();
                            }
                            }
                                } else {
                                  print('file Is empty');
                                }
                            //  return people = true;
                          });
                        }
                      } else {
                        print(v);
                        if (v != null) {
                          if (v != null) {
                                if(v['councils']!=null){
                                  allCouncilData.coordOfCouncil = v['councils'].cast<String>(); 
                                  for (var i in v['councils']) {
                                    var index = allCouncilData.globalCouncils.indexOf(i);
                                    // _subs.add(i.toString());
                                    // print(i);
                                    allCouncilData.subCouncil[index].coordiOfInCouncil = v['$i'].cast<String>();
                                  }
                                }
                                } else {
                                  print('file Is empty');
                                }
                        } else {
                          print('file Is empty');
                        }
                        return false;
                      }
                    });
                  }
                });
                // );
              } else if (id == null) {
                print('id is null');
              } else {
                print(id);
              }
            });
          }
        });
      }
      else if(val == null){
        setState(() {
          error = true;
        });
      }
    });
    // Future.delayed(Duration(seconds: 2),() => print('rendering home'));
    loadSnt();
  }
   

  Widget buildWaitingScreen() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
  Widget buildErrorScreen() {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: Text('Error while Loading'),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    darkMode = Theme.of(context).brightness == Brightness.light ? false : true;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: new AppBar(
            title: new Text('Home'),
            bottom: TabBar(
              labelColor: Colors.white,
              tabs: [
              Tab(
                text: 'Posts',

              ),
              Tab(text: 'All'),
            ]),
          ),
          drawer: Drawer(
              child: ListView(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return ProfilePage(uid, id);
                  }));
                },
                child: Container(
                    height: MediaQuery.of(context).size.width * 0.7,
                    color: darkMode ? Colors.deepPurple : Colors.amber,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 50.0,
                            backgroundColor: Colors.blue,
                            child: Text(
                                name == null || name == ''
                                    ? id[0].toUpperCase()
                                    : name[0].toUpperCase(),
                                style: TextStyle(
                                    fontSize: 40.0, color: Colors.white)),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            name == null || name == '' ? id : name,
                            style: TextStyle(
                                fontFamily: 'Comfortaa',
                                // fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 17.0),
                          ),
                        ],
                      ),
                    )),
              ),
              Container(
                height: 55.0,
                child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return Preferences(
                          widget.auth,
                          widget.logoutCallback,
                          widget.userId,
                          allCouncilData,
                          true
                        );
                      }));
                    },
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
                      child: Text('Preferences',
                          style:
                              TextStyle(fontSize: 20.0, fontFamily: 'Nunito')),
                    )),
              ),
              (allCouncilData !=null&&( allCouncilData.level3.contains(id) || ids.contains(id)))
                  ? Container(
                      height: 55.0,
                      child: InkWell(
                          onTap: () {
                            // Navigator.
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return MakeCoordi(
                                ids,
                                allCouncilData,
                                id,
                                widget.auth,
                                widget.logoutCallback,
                                widget.userId,
                              );
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 15.0, top: 15.0, bottom: 15.0),
                            child: Text(
                              'Make Coordinator',
                              style: TextStyle(
                                  fontSize: 20.0, fontFamily: 'Nunito'),
                            ),
                          )),
                    )
                  : Container(),
              (admin !=null && admin == true)
                  ? Container(
                      height: 55.0,
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return CreatePosts(id, _subs);
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 15.0, top: 15.0, bottom: 15.0),
                            child: Text(
                              'Create Posts',
                              style: TextStyle(
                                  fontSize: 20.0, fontFamily: 'Nunito'),
                            ),
                          )),
                    )
                  : Container(),
              (admin !=null && admin == true)
                  ? Container(
                      height: 55.0,
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return UpDatePosts(id, _subs);
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 15.0, top: 15.0, bottom: 15.0),
                            child: Text(
                              'Update Posts',
                              style: TextStyle(
                                  fontSize: 20.0, fontFamily: 'Nunito'),
                            ),
                          )),
                    )
                  : Container(),
                  (admin !=null && admin == true)
                  ? Container(
                      height: 55.0,
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return Drafts(id, _subs);
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 15.0, top: 15.0, bottom: 15.0),
                            child: Text(
                              'Saved Posts',
                              style: TextStyle(
                                  fontSize: 20.0, fontFamily: 'Nunito'),
                            ),
                          )),
                    )
                  : Container(),
              Container(
                height: 55.0,
                padding: EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito'),
                    ),
                    // SizedBox(width: 40.0),
                    Container(
                      padding: EdgeInsets.only(left: 50.0),
                      child: Switch(
                          value: darkMode,
                          onChanged: (value) {
                            setState(() {
                              darkMode = value;
                            });
                            DynamicTheme.of(context).setBrightness(
                                Theme.of(context).brightness == Brightness.light
                                    ? Brightness.dark
                                    : Brightness.light);
                          }),
                    )
                  ],
                ),
              ),
              Container(
                      height: 55.0,
                      child: InkWell(
                          onTap: () async{
                            // var v = proc();
                            // print(v);
                            // var db = Firestore.instance;
                            // await db.collectionGroup('posts/council').getDocuments().then((var v){
                            //   print(v);
                            //   v.documents.forEach((f){
                            //     print(f.documentID);
                            //   });
                            // });
                            // await db.collection('posts').document('council').collection('gnc').getDocuments().then((onValue){
                            //   print(onValue.documents.iterator.current);
                            // });
                            // print(_councilDataForMe["ss"].entity);
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return AboutPage();
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 15.0, top: 15.0, bottom: 15.0),
                            child: Text(
                              'About Us',
                              style: TextStyle(
                                  fontSize: 20.0, fontFamily: 'Nunito'),
                            ),
                          )),
                    ),
              Divider(),
              Container(
                height: 55.0,
                child: InkWell(
                    onTap: () {
                      signOut();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito'),
                      ),
                    )),
              )
            ],
          )),
          body: load
              ? buildWaitingScreen()
              : error ? buildErrorScreen():
              TabBarView(
                
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                        if (timeofRefresh[0] != null) {
                          if ((DateTime.now().millisecondsSinceEpoch -
                                  timeofRefresh[0].millisecondsSinceEpoch) <
                              5000) {
                            // Duration()
                            return sortarrayWithTime();
                            // return print('nofresh');
                          }
                          print(true.toString() + 'timeoofreferesh');
                        }
                        await loadSnt();
                        setState(() {
                          // t2 =DateTime.now();
                          timeofRefresh[0] = DateTime.now();
                        });
                      },
                    child: sortedarray.length == 0?
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('No posts to display'),
                          FlatButton(
                            onPressed: () async {
                              if (timeofRefresh[0] != null) {
                                if ((DateTime.now().millisecondsSinceEpoch - timeofRefresh[0].millisecondsSinceEpoch) <
                                                30000) {
                                              return sortarrayWithTime();
                                            }
                                          }
                                          await loadSnt();
                                          setState(() {
                                            // t2 =DateTime.now();
                                            timeofRefresh[0] = DateTime.now();
                                          });
                                        },
                                        child: Text('Refresh'))
                                  ],
                                ),
                              )
                            : PrefsHome()),
                  RefreshIndicator(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: sortedarray.length == 0
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('No posts to display'),
                                    FlatButton(
                                        onPressed: () async {
                                          if (timeofRefresh[0] != null) {
                                            if ((DateTime.now().millisecondsSinceEpoch - timeofRefresh[0].millisecondsSinceEpoch) < 30000) {
                                              return sortarrayWithTime();
                                            }
                                          }
                                          await loadSnt();
                                          setState(() {
                                            timeofRefresh[0] = DateTime.now();
                                          });
                                        },
                                        child: Text('Refresh'))
                                  ],
                                ),
                              )
                            : MessageHandlerNotf(widget.userId, loadSnt),
                      ),
                      onRefresh: () async {
                        if (timeofRefresh[0] != null) {
                          if ((DateTime.now().millisecondsSinceEpoch -
                                  timeofRefresh[0].millisecondsSinceEpoch) <
                              5000) {
                            // Duration()
                            return sortarrayWithTime();
                            // return print('nofresh');
                          }
                          print(true.toString() + 'timeoofreferesh');
                        }
                        await loadSnt();
                        setState(() {
                          // t2 =DateTime.now();
                          timeofRefresh[0] = DateTime.now();
                        });
                      }),
                ])),
    );
  }
  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('launch');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flnp.initialize(initializationSettings);
  }
   void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      // Platform.isAndroid
           'tk.notifier.sntiitk',
          // : 'com.duytq.flutterchatdemo',
      'Notifier',
      'Notifier',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));
    // await _flnp.initialize(initializationSettings;\);
    await _flnp.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  // await _flnp.
//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }
  signOut() async {
    try {
      DynamicTheme.of(context).setBrightness(Brightness.light);
      subscribeUnsubsTopic([], _prefs);
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
//   Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
//   if (message.containsKey('data')) {
//     // Handle data message
//     final dynamic data = message['data'];
//     print(data .toString() + 'backgrounddata from home');
//   }

//   if (message.containsKey('notification')) {
//     // Handle notification message
//     final dynamic notification = message['notification'];
//   }
//   configLocalNotification();
//  showNotification(message['data']);
//   // Or do other work.
// }
}
