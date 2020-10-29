import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:hive/hive.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/colors.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/database/student_search.dart';
import 'package:notifier/main.dart';
import 'package:notifier/model/hive_models/hive_allCouncilData.dart';
import 'package:notifier/model/hive_models/people_hive.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/about.dart';
import 'package:notifier/screens/all_posts.dart';
import 'package:notifier/screens/bookmark.dart';
import 'package:notifier/screens/home/home_descp.dart';
import 'package:notifier/screens/make_coordi.dart';
import 'package:notifier/screens/posts/create_edit_posts.dart';
import 'package:notifier/screens/posts/pending_approval.dart';
import 'package:notifier/screens/profile_page.dart';
import 'package:notifier/screens/profile/profilepic.dart';
import 'package:notifier/screens/event_management/calendar.dart';
import 'package:notifier/screens/stu_search/stu_search.dart';
import 'package:notifier/screens/posts/update_drafts_list.dart';
import 'package:notifier/screens/preferences.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/widget/drawer_tile.dart';
import 'package:notifier/widget/showtoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  HomePage({this.auth, this.userId, this.logoutCallback});
  @override
  _HomePageState createState() => _HomePageState();
}
/// contains all ids of council heads i.e. level1+level2
List<String> ids = [];
/// current email id `excluding @iik.ac.in` of user
String id;
///current name of user
String name;
///the json file downloaded from internet
Councils allCouncilData;
/// boolean for the admin field
bool admin;

class _HomePageState extends State<HomePage> {
  /// all posts are loaded firstly into this array after retreivel from database
  static List<PostsSort> globalPostsArray;
  /// hive data for the current active user
  Box userData;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  bool _load = true;
  bool _errorWidget;
  bool refreshPost = true;
  /// this is model for the student search and here is used to
  SearchModel searchModel;
  AsyncMemoizer _memorizer = AsyncMemoizer();
  
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  // StreamController streamController = StreamController.broadcast();
  final HiveDatabaseUser hiveUser = HiveDatabaseUser();
  /// preferneces of the current user
  var _prefs = [];
  bool darkMode;
  File profilePic;
  /// minimum time between two referesh queries
  DateTime timeOfRefresh;
  SharedPreferences _profilePicName;
  String picName;
  /// after user's data is retreived then all the posts in database are retreived as well as a function is trigerred to retreive that data from internet if there is no post available
  Future loadHome()async{
    try{
      _profilePicName = await SharedPreferences.getInstance();
      picName = _profilePicName.getString(PICNAME);
      if(picName != null && !picName.contains(userData.toMap()[0].rollno)){
        picName = null;
      }
      profilePic = await file(picName?? "${searchModel.rollno}.jpg");
    }
    catch(e) {
      print('ERROR OCCURRED WHILE INITAITING SHARED PREFERENCE FOR PROFILE PIC');
      print(e);
      profilePic = null;
    }
    return await loadPosts().then((var status){
      print('loading Posts....');
      subscribeUnsubsTopic(_prefs, []);
      if(status == null || status == true){
        subscribeUnsubsTopic(_prefs, []);
        setState(() {
          print('everything seems alright [line85] ... moving ahead ....');
          _errorWidget = false;
          _load = false;
        });
        print('preferences is completed');
        setState(() {});
      }
      else{
        setState(() {
          _errorWidget = true;
          // _errorRefreshFunction = loadHome();
          _load = false;
        });
      }
    });
  }
  /// function to retreive the json from internet and then save to allcouncilData variable
  /// returns the data retreived is everything is alright otherwise returns null with setting _errorWidget value as true
  Future<Councils> fullData()async{
    return await councilData().then((var data) async{
      if(data!=null){
        print('Data retreived from council == '+
            data.toString());
        allCouncilData = data;
        for (var i in allCouncilData.subCouncil.values.toList()) {
          ids+= i.level2;
        }
      return allCouncilData;
      }else{
        setState(() {
          _errorWidget = true;
          _load = false;
        });
        return null;
      }
    });
  }
  /// initiates the app logic and background fetch
  loadApp() async{
    setState(() {
      _load = true;
    });
    userData = await hiveUser.hiveBox;
    // streamController.addStream(userData.watch());
    return await fullData().then((var status)async{
      if(status != null){
        print('loading User ...');
        return await loadUser().then((v)async{
          if(v){
            print('initiating Home function ...');
            return await loadHome();
          }else{
            subscribeUnsubsTopic(_prefs, []);
            print(globalPostsArray);
            setState(() {
              _errorWidget = true;
              _load = false;
            });
            setState(() {
            });
          }
        });
      }
    });
  }
  @override
  void initState() {
    _load = true;
    /// creating auth map to be use in various functions
    // auth().intialiseAuthValues(id, widget.userId);
    _fcm.configure(
      onMessage: (Map<String, dynamic> message)async{
        print('onMessage' + '$message');
        var data = message['data'];
        print(data['type'] == 'delete');
        if(data['type'] == 'permission'){
          if((ids.contains(id) && 
            allCouncilData.coordOfCouncil.contains(data['council']))
                || allCouncilData.level3.contains(id)){
            print('permission');
           if(data['fetchFF'] == 'true'){
             return await fetchPostFromFirebase(data['id'],collection: 'notification').then((var data)async{
                if(data!=null){
                  data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                  if(data.containsKey("startTime")){
                    data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                  }
                  if(data.containsKey("endTime")){
                    data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                  }
                   message.update('priority',(v)=>'max',ifAbsent: ()=>'max');
                  if(id!="" || id!= null||id.isNotEmpty){
                    await showPermissionNotification(message);
                  }
                  return await DBProvider().newPost(postsFromJson(json.encode(data)));
                }
                else{
                  showInfoToast('A request has been published but we are not able to load it,please, load it manually under pending approval section');
                  return 1;
                }
              });
           }else{
              data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                  if(data.containsKey("startTime")){
                    data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                  }
                  if(data.containsKey("endTime")){
                    data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                  }
                   message.update('priority',(v)=>'max',ifAbsent: ()=>'max');
                  if(id!="" || id!= null||id.isNotEmpty){
                    await showPermissionNotification(message);
                  }
                  
                  return await DBProvider().newPost(postsFromJson(json.encode(data)));
           }
          }
          print('nothing');
          return;
        }
        else if(data['type'] == 'delete'){
          print('deleting');
          // await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(
          //         data['id']
          //       );
          return await DBProvider().deletePost(data['id']);
        }else{
          print('line78');
          if(data['fetchFF'] == 'true'){
            
            return await fetchPostFromFirebase(data['id']).then((var data)async{
              if(data!=null){
                data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                if(data.containsKey("startTime")){
                  data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                }
                if(data.containsKey("endTime")){
                  data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                }
                message.update('priority',(v)=>data['priority'],ifAbsent: ()=>data['priority']);
                if(id!="" || id!= null||id.isNotEmpty){
                  await showNotification(message);
                }
                // if(!ids.contains(id) && data['owner'] == id) {
                //   await await DBProvider().newPost(postsFromJson(json.encode(data)));
                // }else{
                //   await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(data['id']);
                // }
                return await  DBProvider().newPost(postsFromJson(json.encode(data))).then((v)=>setState((){}));
              }
            });
          }
          else{
            data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
            if(data.containsKey("startTime")){
              data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
            }
            if(data.containsKey("endTime")){
              data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
            }
            // }
            print('line80');
            if(id!="" || id!= null||id.isNotEmpty){
              await showNotification(message);
            }
            
              globalPostsArray.add(postsSortFromJson(json.encode(data)));
            // if(!ids.contains(id) && data['owner'] == id) {
            //   await await DBProvider().newPost(postsFromJson(json.encode(data)));
            // }else{
            //   await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(data['id']);
            // }
            return await  DBProvider().newPost(postsFromJson(json.encode(data)));
          }
        }
        // return ;
      },
      onResume: (Map<String,dynamic>message){
        print(message);
        return;
      },
      onLaunch: (Map<String,dynamic> message){
        return;
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
     
    super.initState();
    loadApp().then((_){
      setState(() {
        
      });
    });
    
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build( BuildContext context) {
    darkMode = Theme.of(context).brightness == Brightness.light ? false : true;
    return WillPopScope(
      onWillPop: ()async{
        return showDialog<bool>(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Row(
                children: <Widget>[
                  Icon(AntDesign.warning,
                    color: Colors.red,
                  ),
                  SizedBox(width:10.0),
                  Text('Alert',
                    style: TextStyle(
                      color: Colors.red
                    ),
                  )
                ]),
              content: Text('Do you really want to exit from app'),
              actions: <Widget>[
                Row(
                  children: <Widget>[
                    RaisedButton.icon(
                      onPressed: (){
                        Navigator.pop(context);
                        return false;
                      },
                      icon: Icon(MaterialIcons.close), 
                      label: Text('Dismiss'),
                    ),
                    SizedBox(width:10.0),
                    FlatButton.icon(
                      onPressed: ()async{
                        return Navigator.of(context).pop(true);
                      },
                      icon: Icon(MaterialIcons.exit_to_app),
                      label: Text('Exit'),
                    )
                  ],
                )
              ],
            );
          }
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title:Text('Home'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.replay,) ,onPressed:(){
              if(timeOfRefresh == null){
                loadApp();
              }else if((DateTime.now().millisecondsSinceEpoch - timeOfRefresh.millisecondsSinceEpoch) > 5000) {
                loadApp();
              }else{
                setState(() {
                  _load = true;
                });
                Future.delayed(Duration(seconds: 2),()=>setState((){_load = false;}));
              }
            })
          ],
        ),
        drawer: !_load? SafeArea(
          child: Drawer(
            elevation: 5.0,
            child: ListView(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.width * 0.7,
                  color: Theme.of(context).brightness == Brightness.dark ?Colors.black:Colors.white,
                  child: Center(
                    child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (BuildContext context) {
                                  return Profile(_memorizer);
                                }));
                              },
                              child: profilePic != null && profilePic.existsSync()?
                                CircleAvatar(
                                  radius: 50.0,
                                  backgroundImage: MemoryImage(
                                    profilePic.readAsBytesSync()
                                  ),
                                )
                                : CircleAvatar(
                                    radius: 50.0,
                                    backgroundImage: AssetImage(defaultProfileUrl(searchModel.gender)),
                                  ),
                              /*FutureBuilder(
                                future: file(picName?? "${searchModel.rollno}.jpg"),
                                builder: (context,AsyncSnapshot<File> snapshot){
                                  switch(snapshot.connectionState){
                                    case ConnectionState.done:
                                      if(snapshot == null || snapshot.data == null || !snapshot.hasData || snapshot.hasError){
                                        return CircleAvatar(
                                          radius: 50.0,
                                          backgroundImage: AssetImage(defaultProfileUrl(searchModel.gender)),
                                        );
                                      }else{
                                        if(snapshot.data.existsSync()){  
                                          return CircleAvatar(
                                            radius: 50.0,
                                            backgroundImage: MemoryImage(
                                              snapshot.data.readAsBytesSync()
                                            ),
                                          );
                                        }else{
                                          return CircleAvatar(
                                            radius: 50.0,
                                            backgroundImage: AssetImage(defaultProfileUrl(searchModel.gender)),
                                          );
                                        }
                                      }
                                    break;
                                    default: return CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: AssetImage(defaultProfileUrl(searchModel.gender)),
                                      );
                                    break;
                                  }
                                }
                              ),*/
                            ),
                            // FutureBuilder(
                            //   future: this._loadUserPic(),
                            //   builder: (context, snapshot){
                            //   switch (snapshot.connectionState) {
                            //     case ConnectionState.done:
                            //       if(snapshot == null || snapshot.data == null || !snapshot.hasData || snapshot.hasError){
                            //         return CircleAvatar(
                            //           radius: 50.0,
                            //           backgroundImage: AssetImage('assets/${searchModel.gender.toLowerCase()}profile.png'),
                            //           // backgroundColor: Theme.of(context).accentColor,
                            //           // child: Text(
                            //           //   // 'kjkjbd',
                            //           //   _errorWidget?'':
                            //           //     name == null || name == ''
                            //           //         ? id[0].toUpperCase()
                            //           //         : name[0].toUpperCase(),
                            //           //     style: TextStyle(
                            //           //         fontSize: 40.0,
                            //           //         color: Colors.white  
                            //           //       )),
                            //         );
                            //       }else{
                            //         return CircleAvatar(
                            //           radius: 50.0,
                            //           backgroundImage: snapshot.data,
                            //         );
                            //       }
                            //       break;
                            //     default: return CircleAvatar(
                            //           radius: 50.0,
                            //           backgroundImage: AssetImage('assets/${searchModel.gender.toLowerCase()}profile.png'),
                            //           // backgroundColor: Theme.of(context).accentColor,
                            //           // child: Text(
                            //           //   _errorWidget?'':
                            //           //     name == null || name == ''
                            //           //         ? id[0].toUpperCase()
                            //           //         : name[0].toUpperCase(),
                            //           //     style: TextStyle(
                            //           //         fontSize: 40.0,
                            //           //         color: Colors.white  
                            //           //       )),
                            //         );
                            //         break;
                            //   }
                            // }),
                            SizedBox(height: 20.0),
                            Text(
                              // 'nmb',
                              _errorWidget?'':
                              name == null || name == '' ? id : name,
                              style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 17.0),
                            ),
                          ],
                        ),
                  ),
                ),
                /*ids.contains(id) ?
                Container():
                InkWell(
                        onTap: () async {
                          Navigator.of(context).pop();
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                              return SafeArea(child: Preferences(
                                    widget.auth,
                                    loadApp,
                                    userData.toMap()[0].uid,
                                    allCouncilData,
                                    userData
                                  ));
                            }));
                        },
                        child:Container(
                  height: 55.0,
                  padding: EdgeInsets.only(left:15.0),
                  child:  Row(
                          children: <Widget>[
                            Icon(Octicons.settings),Container(
                                padding: EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
                                child: Text('Preferences',
                                  style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito')),
                              ),
                          ],
                        ),
                      ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return StreamBuilder(
                            stream: userData.watch(key: 0), 
                            builder: (context,AsyncSnapshot<BoxEvent> sn)=>
                              SafeArea(child: AllPostGetData(
                               (sn == null || sn.data == null || sn.data.value == null)? userData.toMap()[0]:sn.data.value,
                              ))
                          );
                        }));
                    },
                    child: Container(
                      height: 55.0,
                      padding: EdgeInsets.only(left:15.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Entypo.notification),
                          Container(
                            padding: EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
                            child: Text('Posts',
                              style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito')),
                          ),
                        ],
                      ),
                    )
                  ),*/
                  ids.contains(id) ?
                  Container():
                  DrawerTile(
                    icon: Octicons.settings,
                    routeWidget: Preferences(
                      widget.auth,
                      loadApp,
                      userData.toMap()[0].uid,
                      allCouncilData,
                      userData
                    ),
                    title: 'Preferences',
                  ),
                  DrawerTile(
                    icon: Entypo.notification,
                    routeWidget: StreamBuilder(
                      stream: userData.watch(key: 0), 
                      builder: (context,AsyncSnapshot<BoxEvent> sn)=>
                        AllPostGetData(
                          (sn == null || sn.data == null || sn.data.value == null)? 
                            userData.toMap()[0]:sn.data.value,
                        )
                    ),
                    title: 'Posts',
                  ),
                  ((allCouncilData !=null&&( allCouncilData.level3.contains(id) || ids.contains(id)))
                  || userData.toMap()[0].admin == true) ?
                  ExpansionTile(
                    leading: Icon(MaterialCommunityIcons.shield_account,
                      color:CustomColors(context).iconColor
                    ),
                    title: Text('Admin Options',
                    style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito'),
                    ),
                    backgroundColor: CustomColors(context).exapndedTileColor,
                    children: [
                      ((){
                      if((allCouncilData !=null&&( allCouncilData.level3.contains(id) || ids.contains(id))))
                        return DrawerTile(
                          routeWidget: MakeCoordi(
                                  ids,
                                  allCouncilData,
                                  id,
                                  widget.auth,
                                  widget.logoutCallback,
                                  widget.userId,
                                  userData
                                ),
                          title: 'Make Coordinator',
                          icon: MaterialCommunityIcons.account_card_details_outline,
                        );
                      }()),
                      ((){
                      if(userData.toMap()[0].admin == true)
                        return Column(
                          children: [
                            DrawerTile(
                              routeWidget: CreateEditPosts('Create', null, PostsSort(author: name,owner:id)),
                              title: 'Create Posts',
                              icon: Entypo.new_message
                            ),
                            DrawerTile(
                              routeWidget: PostList('Update',id,_prefs),
                              title: 'Update Posts',
                              icon: MaterialCommunityIcons.update
                            ),
                            DrawerTile(
                              routeWidget: PendingApproval(),
                              title: 'Pending Approval',
                              icon: MaterialCommunityIcons.stamper
                            ),
                            DrawerTile(
                              routeWidget: PostList('Drafts',widget.userId,_prefs),
                              title: 'Drafted Posts',
                              icon: Ionicons.ios_save
                            ),
                          ],
                        );
                      }()),
                    ],
                  )
                  : Container(),
                  DrawerTile(
                    icon: MaterialIcons.collections_bookmark,
                    routeWidget: BookMarked(),
                    title: 'Bookmarked Posts',
                  ),
                  DrawerTile(
                    icon: Octicons.calendar, //TODO add calendar icon
                    routeWidget: Calendar(),
                    title: 'Events',
                  ),
                  DrawerTile(
                    icon: MaterialCommunityIcons.account_search,
                    routeWidget: StudentSearch(),
                    title: 'Student Search',
                  ),
                  Container(
                    height: 55.0,
                    padding: EdgeInsets.only(left:15.0, top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Ionicons.ios_color_palette),
                        Container(
                          padding: EdgeInsets.only(left:30.0),
                          child: Text(
                            'Dark Mode',
                            style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito'),
                          ),
                        ),
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
                  DrawerTile(
                    icon: Entypo.info_with_circle,
                    routeWidget: AboutPage(),
                    title: 'About Us',
                  ),
                  Divider(),
                  DrawerTile(
                    icon: AntDesign.logout,
                    onTap: signOut,
                    title: 'Logout',
                  ),
                  /* InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                                return SafeArea(child: BookMarked());
                            }));
                          },
                          child: Container(
                            height: 55.0,
                            padding: EdgeInsets.only(left:15.0),
                            child: Row(
                              children: <Widget>[
                                Icon(MaterialIcons.collections_bookmark),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 15.0, top: 15.0, bottom: 15.0),
                                  child: Text(
                                    'Bookmarked Posts',
                                    style: TextStyle(
                                      fontSize: 20.0, fontFamily: 'Nunito'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                  InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                                return SafeArea(child: Calendar());
                            }));
                          },
                          child: Container(
                            height: 55.0,
                            padding: EdgeInsets.only(left:15.0),
                            child: Row(
                              children: <Widget>[
                                Icon(MaterialIcons.collections_bookmark),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 15.0, top: 15.0, bottom: 15.0),
                                  child: Text(
                                    'Events',
                                    style: TextStyle(
                                      fontSize: 20.0, fontFamily: 'Nunito'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                  InkWell(
                    onTap: () async {
                          Navigator.of(context).pop();
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                             return SafeArea(child: StudentSearch());
                            }));
                    },
                        child:Container(
                        height: 55.0,
                        padding: EdgeInsets.only(left:15.0),
                        child:  Row(
                          children: <Widget>[
                            Icon(MaterialCommunityIcons.account_search),Container(
                                padding: EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
                                child: Text('Student Search',
                                  style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito')),
                              ),
                          ],
                        ),
                      ),
                  ),
                  
                  InkWell(
                    onTap: () async{
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                          return SafeArea(child: AboutPage());
                      }));                      
                    },
                    child:Container(
                      height: 55.0,
                      padding: EdgeInsets.only(left:15.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Entypo.info_with_circle),
                          Container(
                            padding: EdgeInsets.only(
                              left: 15.0, top: 15.0, bottom: 15.0),
                            child: Text(
                              'About Us',
                              style: TextStyle(
                                fontSize: 20.0, fontFamily: 'Nunito'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                  
                  InkWell(
                    onTap: () {
                      signOut();
                    },
                    child:Container(
                      height: 55.0,
                      padding: EdgeInsets.only(left:15.0),
                      child: Row(
                        children: <Widget>[
                          Icon(AntDesign.logout),
                          Container(
                            padding:EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
                            child: Text(
                              'Logout',
                              style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito'),
                            ),
                          ),
                        ],
                      ),
                    )
                  )
                  */
              ],
            ),
          ),
        ) : null,
        body: _load? Container(
          child: Center(child: CircularProgressIndicator())
        )
        :(_errorWidget? Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  'An Unknown Error occured while loading Posts!!\nTry checking your internet connectivity and refereshing',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red)
                ),
              ),
              RaisedButton.icon(onPressed: (){
                if(timeOfRefresh == null){
                  loadApp();
                }else if((DateTime.now().millisecondsSinceEpoch - timeOfRefresh.millisecondsSinceEpoch) > 5000) {
                  loadApp();
                }else{
                  setState(() {
                    _load = true;
                  });
                  Future.delayed(Duration(seconds: 2),()=>setState((){_load = false;}));
                }
              }, icon: Icon(Icons.refresh), label: Text('Reload again')),
            ],
          ),
        // ): Container(
        ):
        FutureBuilder(
          future: DBProvider().getAllPostsWithoutPermissions(),
          builder: (context, snapshot) {
            return StreamBuilder(
              stream: userData.watch(key: 0),
              builder: (context,AsyncSnapshot<BoxEvent> sn){
                return  HomeDescription(
                  postArray: snapshot.data??globalPostsArray,
                  userModel:(sn == null || sn.data == null || sn.data.value == null)? userData.toMap()[0]:sn.data.value,
                  userID: userData.toMap()[0].uid,
                  load: refreshPost,
                );
              }
            );
          }
        )
        ))
      // ),
    );
  }

  Future<dynamic> _loadUserPic() async {
    return this._memoizer.runOnce(() async => await UserProfilePic(searchModel).getUserProfilePic() );
  }

  /// loads the current user data from hive database if found else fetches from firebase ;
  /// also calls loadPeopleData if admin is true
  Future<bool>loadUser() async{

    if(userData.isNotEmpty && userData.toMap()[0]!=null){
      var list = await StuSearchDatabase().getAllPostswithQuery(QueryDatabase(['username'], [userData.toMap()[0].id]));
      searchModel = (list!=null&&list.length != 0)?list[0]: SearchModel(gender: '');
      id = userData.toMap()[0].id;
      admin = userData.toMap()[0].admin ?? false;
      name = (list!=null&&list.length != 0)? userData.toMap()[0].name= list[0].name: '';
      userData.toMap()[0].rollno= (list!=null&&list.length != 0)? list[0].rollno: '';
      userData.putAt(0,userData.toMap()[0]);
      _prefs = userData.toMap()[0].prefs ?? [];
      subscribeUnsubsTopic(_prefs, []);
      if(admin == true){
        return await loadPeopleData();
      }else{
        return true;
      }
    }else{
      return await populateUsers(widget.userId).then((status)async{
        if(status == true){
          Box userBox = await HiveDatabaseUser().hiveBox;
          if(userBox.isNotEmpty && userData.toMap()[0]!=null){
            id = userBox.toMap()[0].id;
            admin = userBox.toMap()[0].admin ?? false;
            name = userBox.toMap()[0].name ?? false;
            _prefs = userBox.toMap()[0].prefs ?? [];
            // print(userBox.toMap()[0]);
            subscribeUnsubsTopic(_prefs, []);
            if(admin == true){
              return await loadPeopleData();
            }else{
              return true;
            }
          }else{
            return false;
          }
        }else{
          return false;
        }
      });
    }
  }
  ///loads data from people collection from firebase about the user and its admin rights and saves this in a hive database
  Future<bool> loadPeopleData() async{
    Box peopleBox = await HiveDatabaseUser(databaseName: 'people').hiveBox;
    if(peopleBox.isNotEmpty){
      try {
        PeopleModel model =peopleBox.toMap()[0];
        allCouncilData.coordOfCouncil = model.councils.keys.toList();
          allCouncilData.subCouncil.forEach((councilName,subCouncil){
            subCouncil.coordiOfInCouncil = (model.councils[councilName] == null )? 
              []
                :model.councils[councilName];
        }); 
        return true; 
      } catch (e) {
        print(e);
        return false;
      }
    }else{
      return await populatePeople(id).then((value)async{
        if(value == true){
          peopleBox = await HiveDatabaseUser(databaseName: 'people').hiveBox;
          if(peopleBox.isNotEmpty){
            try {
               PeopleModel model =peopleBox.toMap()[0];
                allCouncilData.coordOfCouncil = model.councils.keys.toList();
                  allCouncilData.subCouncil.forEach((councilName,subCouncil){
                    subCouncil.coordiOfInCouncil = (model.councils[councilName] == null )? 
                      []
                        :model.councils[councilName];
              }); 
              return true; 
            } catch (e) {
              print(e);
              return false;
            }
          }else{
            return false;
          }
        }else{
          return false;
        }
      });
    }
  }
  
  /// has return type true (for all is well) ;false(for error retreiving);null(not found anyhting).
  ///  Retreives all post from local database and loads them into [globalPostsArray] variable.
  Future<bool> loadPosts()async{
    return await DBProvider().getAllPosts().then((var v)async{
      if(v!=null && v.length != 0){
        setState(() {
          globalPostsArray = v;
        }); 
        return true;
      }else{
        return await p1('0',owner: id).then((status)async{
          return status;
        });
      }
    });
  }
  signOut() async {
    try {
      // subscribeUnsubsTopic([], (userData.toMap()[0]?.prefs == null)? []:userData.toMap()[0]?.prefs);
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async{
    print('AppPushs myBackgroundMessageHandler : $message');
    Map<dynamic,dynamic> data = message['data'];
    data = data.cast<String,dynamic>();
    if(data['type'] == 'permission'){
      if((ids.contains(id) && 
          allCouncilData.coordOfCouncil.contains(data['council']))
            || allCouncilData.level3.contains(id)){
        print('permission');
          if(data['fetchFF'] == 'true'){
            return await fetchPostFromFirebase(data['id']).then((var data)async{
              if(data!=null){
                data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                if(data.containsKey("startTime")){
                  data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                }
                if(data.containsKey("endTime")){
                  data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                }
                message.update('priority',(v)=>'max',ifAbsent: ()=>'max');
                if(id!="" || id!= null||id.isNotEmpty){
                  await showPermissionNotification(message);
                }
                return await DBProvider().newPost(postsFromJson(json.encode(data)));
              }
              else{
                // showInfoToast('A request has been published but we are not able to load it,please, load it manually under requested permissions');
                return 1;
              }
            });
          }
          if(data!=null){
            data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
            if(data.containsKey("startTime")){
              data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
            }
            if(data.containsKey("endTime")){
              data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
            }
            message.update('priority',(v)=>'max',ifAbsent: ()=>'max');
            if(id!="" || id!= null||id.isNotEmpty){
                    await showPermissionNotification(message);
                  }
              return await DBProvider().newPost(postsFromJson(json.encode(data)));
            }
            else{
              // showInfoToast('A request has been published but we are not able to load it,please, load it manually under requested permissions');
              return 1;
            }
      }else{
       return Future<void>.value();
      }
    } 
      else  if(data['type'] == 'delete'){
        // await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(data['id']);
         await DBProvider().deletePost(data['id']);
        }else{
          if(data['fetchFF'] == 'true'){
            return await fetchPostFromFirebase(data['id']).then((data)async{
              if(data!=null){
                data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                if(data.containsKey("startTime")){
                  data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                }
                if(data.containsKey("endTime")){
                  data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                }
                // if(ids.contains(id)) await DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(
                //   postsSortFromJson(json.encode(data))
                // );
                await DBProvider().newPost(postsFromJson(json.encode(data)));
                message.update('priority', (v)=>'max',ifAbsent: ()=>'max');
                if(id!="" || id!= null||id.isNotEmpty){
                    await showNotification(message);
                  }
                
              }else{
                message = {
                  'data': {
                    'timeStamp': DateTime.now().millisecondsSinceEpoch,
                    'priority':'max',
                    'title':'A pending publish request was unable to fetch',
                    'message':'Click to check it out yourself',
                    'sub': 'Notifier',
                  }
                };
              }
            });
          }
          else{
            if(data!=null){
              data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
              if(data.containsKey("startTime")){
                data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
              }
              if(data.containsKey("endTime")){
                data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
              }
              // if((ids.contains(id) && allCouncilData.coordOfCouncil.contains(data['council'])) || allCouncilData.level3.contains(id)){
              //   DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(data['id']);
              // }else if(data['owner'] == id){
              //   DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(postsSortFromJson(json.encode(data)));
              // }
              await DBProvider().newPost(postsFromJson(json.encode(data)));
              if(id!="" || id!= null||id.isNotEmpty){
                    await showNotification(message);
                  }
            }else{
              // message = {
              //   'data': {
              //     'timeStamp': DateTime.now().millisecondsSinceEpoch,
              //     'priority':'max',
              //     'title':'A pending publish request was unable to fetch',
              //     'message':'Click to check it out yourself',
              //     'sub': 'Notifier',
              //   }
              // };
            }
          }
          // globalPostsArray.insert(0,postsSortFromJson(json.encode(data)));
        }
    return Future<void>.value();
  } 
}




printPosts(PostsSort nwPosts){
  print(nwPosts.tags);
              print(nwPosts.author);
              print(nwPosts.body);
              print(nwPosts.sub);
              print(nwPosts.timeStamp is int);
              print(nwPosts.title);
              print(nwPosts.council);
              print(nwPosts.id);
              print(nwPosts.message);
              print(nwPosts.owner);
              print(nwPosts.url);
              print(nwPosts.reminder);
              // print(nwPosts.);

              // print(nwPosts.dateAsString);
              
}