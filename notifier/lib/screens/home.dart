import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/data/data.dart';
import 'package:notifier/main.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/model/todo.dart';
import 'package:notifier/screens/posts/notification/notification.dart';
import 'package:notifier/screens/posts/createposts.dart';
import 'package:notifier/screens/make_coordi.dart';
import 'package:notifier/screens/posts/updateposts.dart';
import 'package:notifier/screens/preferences.dart';
import 'package:notifier/screens/profile.dart';
import 'dart:async';

import 'package:notifier/services/databse.dart';
import 'package:notifier/services/function.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key,this.darkMode, this.auth, this.userId, this.logoutCallback})
      : super(key: key);
  bool darkMode;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

bool admin;
// List<dynamic> sortedarray = List();
// List<UpdatePostsFormat> timenots = List();

class _HomePageState extends State<HomePage> {
  // List<Todo> _todoList;
  var id;
  String _name;
  String _rollno;
  List<String> ids = List();
  List<dynamic> _prefs = List();

  String uid;
  var load = false;
  List<String> _subs = List();
  bool darkMode;
  Future<bool> loadEVERY() async {
    load = true;

    return await procedure().then((bool v) async {
      print(v.toString() + ':procedure line45 home.dart');
      if (v != null && v) {
        setState(() {
          addStringToSF(DateTime.now().toIso8601String());
        });
        return await readContent('snt').then((var val) {
          print('snt values line56 of home.dart:' + val.toString());
          print(sortedarray);
          sortedarray.clear();
          if (val != null) {
            print(val.keys.length);
            val.keys.forEach((key) {
              // var v = DateTime.parse('2020-03-23T17:26:56.295');
              if (val[key]['exists'] == false) {
                // print('values whoose esists is false line57 home.dart:'+val[key].toString());
                // val.remove(key);
              } else {
                // print('values whoose esists is true line57 home.dart:' +
                // val[key].toString());
                // if(!sortedarray.contains(UpdatePostsFormat(uid: key,value:val[key]))){
                //   sortedarray.add(UpdatePostsFormat(uid: key,value:val[key]));
                // }
                if (!sortedarray.contains(SortDateTime(
                    key,
                    DateTime.parse(val[key]['timeStamp'])
                        .toUtc()
                        .millisecondsSinceEpoch,
                    val[key]))) {
                  // sortedarray.insert(0, element);
                  sortedarray.insert(
                      0,
                      SortDateTime(
                          key,
                          DateTime.parse(val[key]['timeStamp'])
                              .toUtc()
                              .millisecondsSinceEpoch,
                          val[key]));
                  // print(sortedarray[0].date);
                }
                print('\'whileSavinh\''+sortedarray[0].value.toString());
                //         sortedarray.forEach((array){
                //           if(array.uid == key){
                //             if(array.value['sub'] == val[key]['sub'] &&
                // array.value['esists'] == val[key]['exists'] &&
                // array.value['title'] == val[key]['title'] &&
                // array.value['url'] == val[key]['url'] &&
                // array.value['body'] == val[key]['body'] &&
                // array.value['tags'] == val[key]['tags'] &&
                // array.value['council'] == val[key]['council'] &&
                // array.value['message'] == val[key]['message'] &&
                // array.value['owner'] == val[key]['owner'] &&
                // array.value['timeStamp'] == val[key]['timeStamp'] &&
                // array.value['author'] == val[key]['author']){
                //   sortedarray.remove(array);
                //   // continue;
                // }
                //   }
                // });

              }
            });
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
        // print('\'diff:' + sortedarray[i].value.toString());
        if (sortedarray[i].date < sortedarray[j].date) {
          SortDateTime temp = sortedarray[i];
          sortedarray[i] = sortedarray[j];
          sortedarray[j] = temp;
          temp = null;
        }
        // if(sortedarray[i].uid.contains(sortedarray[j].uid)){
        //   // print(true.toString() + 'smae');

        // }
      }
    }
    // for(var i =0;i<sortedarray.length;i++){
    //   if(tim)
    // }
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
            print('\'sortedarray\':'+f.value.toString());
          });
          if (sortedarray != null) {
            load = false;
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
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
          // print(_prefs + ['Science and Technology Council']);

          print('reading users preferences' + value.toString());
          subscribeUnsubsTopic(_prefs, []);
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
                        for (var i in val['sub']) {
                          _subs.add(i.toString());
                          print(i);
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
                              for (var i in val['sub']) {
                                _subs.add(i.toString());
                                print(i);
                              }
                            } else {
                              print('file Is empty');
                            }
                          });
                          // } else {
                          //   print('filealready exists');
                          // }
                          // });
                          // }
                          // });
                        }
                      });
                    } else {
                      return await writeContent(
                              'people', json.encode(peopleArr))
                          .whenComplete(() {
                        print('done!! people');
                        setState(() {
                          for (var i in v['sub']) {
                            _subs.add(i.toString());
                            // print(i['id']);
                            print(_subs);
                          }
                        });
                        //  return people = true;
                      });
                    }
                  } else {
                    print(v);
                    if (v != null) {
                      for (var i in v['sub']) {
                        _subs.add(i.toString());
                        // print(i['id']);
                        print(_subs);
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
    loadSnt();
  }

  signOut() async {
    try {
      subscribeUnsubsTopic([], _prefs);
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  Widget buildWaitingScreen() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    darkMode = Theme.of(context).brightness == Brightness.light ?false: true;
    return Scaffold(
          appBar: new AppBar(title: new Text('Home'), actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ]
              //   IconButton(
              //       icon: Icon(Icons.refresh),
              //       onPressed: () {
              //         loadEVERY();
              //       })
              // ],
              ),
          drawer: Drawer(
              child: ListView(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return ProfilePage(uid,id);
                  }));
                },
                child: Container(
                    height: MediaQuery.of(context).size.width * 0.7,
                    color: Colors.amber,
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
              (id == 'adtgupta' || id == 'utkarshg' || id == 'sntsecy')
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
              (admin == true)
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
              (admin == true)
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
              Container(
                height: 55.0,
                padding: EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito'),
                    ),
                    Switch(
                      value: darkMode, onChanged: (value){
                        setState(() {
                          darkMode = value;
                        });
                          DynamicTheme.of(context).setBrightness(
              Theme.of(context).brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light);
                        
                      })
                  ],
                ),
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
              : RefreshIndicator(
                  child:
                      /*SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child:*/
                      Container(
                    // constraints: BoxConstraints(

                    // ),
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
                                        if ((DateTime.now()
                                                    .millisecondsSinceEpoch -
                                                timeofRefresh[0]
                                                    .millisecondsSinceEpoch) <
                                            30000) {
                                          // Duration()
                                          return sortarrayWithTime();
                                          // return print('nofresh');
                                        }
                                        print(true.toString() +
                                            'timeoofreferesh');
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
                        : MessageHandler(widget.userId, loadSnt),
                  ),
                  // ),

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
    );
  }
}
