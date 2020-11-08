import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
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
import 'package:notifier/screens/featured_post/featured_post.dart';
import 'package:notifier/screens/home/home_descp.dart';
import 'package:notifier/screens/home/ongoing_events.dart';
import 'package:notifier/screens/home/upcoming_events.dart';
import 'package:notifier/screens/make_coordi.dart';
import 'package:notifier/screens/map/maps.dart';
import 'package:notifier/screens/posts/create_edit_posts.dart';
import 'package:notifier/screens/posts/pending_approval.dart';
import 'package:notifier/screens/profile_page.dart';
import 'package:notifier/screens/profile/profilepic.dart';
import 'package:notifier/screens/event_management/calendar.dart';
import 'package:notifier/screens/stu_search/stu_search.dart';
import 'package:notifier/screens/posts/update_drafts_list.dart';
import 'package:notifier/screens/preferences.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/fcm.dart';
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
  static List<Posts> globalPostsArray;
  /// hive data for the current active user
  Box userData;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  bool _load = true;
  bool _errorWidget;
  bool refreshPost = true;
  bool newPostLoading = true;
  bool newPost = false;
  StreamController _newPostStreamController = StreamController(sync: true);
  /// this is model for the student search and here is used to
  SearchModel searchModel;
  AsyncMemoizer _memorizer = AsyncMemoizer();
  final GlobalKey<ScaffoldState> _homePageKey = GlobalKey<ScaffoldState>();
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
    auth.update("id", (value) => userData.toMap()[0].id);
  auth.update("uid", (value) => userData.toMap()[0].uid);
    return await loadPosts().then((var status){
      print('loading Posts....');
      subscribeUnsubsTopic(_prefs, []);
      if(status == null || status == true){
        subscribeUnsubsTopic(_prefs, []);
        if(mounted) setState(() {
          print('everything seems alright [line85] ... moving ahead ....');
          _errorWidget = false;
          _load = false;
        });
        print('preferences is completed');
        if(mounted) setState(() {});
      }
      else{
        if(mounted) setState(() {
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
        print("COORDI OF COUNCIL >>>>" +allCouncilData?.coordOfCouncil.toString());
      return allCouncilData;
      }else{
        if(mounted) setState(() {
          _errorWidget = true;
          _load = false;
        });
        return null;
      }
    });
  }
  /// initiates the app logic and background fetch
  loadApp() async{
    if(mounted) setState(() {
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
            if(mounted) setState(() {
              _errorWidget = true;
              _load = false;
            });
            if(mounted) setState(() {
            });
          }
        });
      }
    });
  }
  @override
  void initState() {
    _load = true;
    _newPostStreamController.add(false);
    /// creating auth map to be use in various functions
    // auth().intialiseAuthValues(id, widget.userId);
    _fcm.configure(
      onMessage: (Map<String,dynamic> message){
        return onMessage(message).then((_){
          if(mounted) setState((){});
        });
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
      if(mounted) setState(() {
        
      });
    });
    
  }
  @override
  void dispose() {
    super.dispose();
    _newPostStreamController.close();
  }
  @override
  Widget build( BuildContext context) {
    darkMode = Theme.of(context).brightness == Brightness.light ? false : true;
    return WillPopScope(
      onWillPop: ()async{
        if(_homePageKey.currentState.isDrawerOpen){
          Navigator.pop(context);
          return false;
        } 
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
                        if(_homePageKey.currentState.isDrawerOpen){
                          Navigator.of(context).pop();
                        } 
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
        key: _homePageKey,
        appBar: AppBar(
          title:Text('Home'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.replay,) ,onPressed:(){
              if(timeOfRefresh == null){
                loadApp();
              }else if((DateTime.now().millisecondsSinceEpoch - timeOfRefresh.millisecondsSinceEpoch) > 5000) {
                loadApp();
              }else{
                if(mounted) setState(() {
                  _load = true;
                });
                Future.delayed(Duration(seconds: 2),(){
                  if(mounted) setState((){_load = false;});
                });
              }
            }),
            IconButton(icon: Icon(Icons.ac_unit) , onPressed: ()async{
              await ReminderNotification('An event you have saved is going on',
              reminder: postsFromJson( json.encode(
                  {"startTime": "",   
                  "endTime": "", "author": "", 
                  "isFeatured": "true", "notfID": "1604514573684", 
                  "fetchFF": "true", 
                  "id": "67e7f447-b0e8-451b-a199-194a0719d29e", 
                  "sub": ["President Students Gymkhana"], 
                  "url": "", "body": "", "tags": "", "type": "permission", 
                  "timeStamp": "1604514573684", "owner": "adtgupta", "title": "St th", 
                  "message": "Setht", "council": "psg"}
              ),),
                time: tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
              ).initiate;
              // showNotification(
              //   {"notification": {"title": null, "body": null}, 
              //   "data": 
              //     {"startTime": "",   
              //     "endTime": "", "author": "", 
              //     "isFeatured": "", "notfID": "1604514573684", 
              //     "fetchFF": "true", 
              //     "id": "67e7f447-b0e8-451b-a199-194a0719d29e", 
              //     "sub": "President Students Gymkhana", 
              //     "url": "", "body": "", "tags": "", "type": "permission", 
              //     "timeStamp": "", "owner": "adtgupta", "title": "St th", 
              //     "message": "Setht", "council": "psg"}}
              // );
            }), 
            // IconButton(icon: Icon(Icons.ac_unit), onPressed: (){
            //   _newPostStreamController.add(newPost = !newPost);
            // })
          ],
        ),
        drawerEdgeDragWidth: MediaQuery.of(context).size.width*0.2,
        drawer: !_load? SafeArea(
          child: Drawer(
            elevation: 5.0,
            child: ListView(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.width * 0.7,
                  color: Theme.of(context).brightness == Brightness.dark ?Colors.black:Colors.white,
                  child: Center(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (BuildContext context) {
                                      return Profile(_memorizer);
                                    })).then((value) {
                                      if(mounted) setState((){});
                                    });
                                  },
                                  child: profilePic != null && profilePic.existsSync()?
                                    Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 50.0,
                                          backgroundImage: MemoryImage(
                                            profilePic.readAsBytesSync()
                                          ),
                                        ),
                                      ]
                                    )
                                    : CircleAvatar(
                                        radius: 50.0,
                                        backgroundImage: AssetImage(defaultProfileUrl(searchModel?.gender??"M")),
                                      ),
                                ),
                                SizedBox(height: 20.0),
                                Text(
                                  _errorWidget?'':
                                  name == null || name == '' ? id : name,
                                  style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 17.0),
                                ),
                              ],
                            ),
                        Positioned(
                          right: 16,
                          child: IconButton(icon: Icon(Icons.map),
                            iconSize: 30,
                            splashColor: CustomColors(context).accentColor,
                            tooltip: "Campus Map",
                            onPressed: () {
                              Navigator.push(context, 
                                MaterialPageRoute(builder: (context){
                                  return CustomMap();
                                })
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                    icon: AntDesign.exception1,
                    navigation: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) {
                            return SafeArea(child:FeaturedPost());
                              })).then((value) => setState((){})),
                    title: 'Featured Section',
                  ),
                  DrawerTile(
                    icon: Entypo.notification,
                    navigation: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) {
                            return SafeArea(child: StreamBuilder(
                      stream: userData.watch(key: 0), 
                      builder: (context,AsyncSnapshot<BoxEvent> sn)=>
                        AllPostGetData(
                          (sn == null || sn.data == null || sn.data.value == null)? 
                            userData.toMap()[0]:sn.data.value,
                        )
                    ));})).then((value) => setState((){})),
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
                      Container(),
                      ((){
                      if((allCouncilData !=null&&( allCouncilData.level3.contains(id) || ids.contains(id))))
                        return DrawerTile(
                          navigation: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) {
                            return SafeArea(child: MakeCoordi(
                                  ids,
                                  allCouncilData,
                                  id,
                                  widget.auth,
                                  widget.logoutCallback,
                                  widget.userId,
                                  userData
                                ),);
                          })).then((value){
                            if(mounted) setState((){});
                          }),
                          title: 'Make Coordinator',
                          icon: MaterialCommunityIcons.account_card_details_outline,
                        );
                        else return Container();
                      }()),
                      ((){
                        print('is admin '+  userData.toMap()[0].admin.toString());
                      if(userData.toMap()[0].admin == true)
                        return Column(
                          children: [
                            DrawerTile(
                              routeWidget: CreateEditPosts(PostDescType.CREATE_POSTS, null, Posts(author: name,owner:id)),
                              title: 'Create Posts',
                              icon: Entypo.new_message
                            ),
                            DrawerTile(
                              routeWidget: PostList(PostDescType.EDIT_POSTS,id,_prefs),
                              title: 'Update Posts',
                              icon: MaterialCommunityIcons.update
                            ),
                            DrawerTile(
                              routeWidget: PendingApproval(),
                              title: 'Pending Approval',
                              icon: MaterialCommunityIcons.stamper
                            ),
                            DrawerTile(
                              routeWidget: PostList(PostDescType.DRAFT_POSTS,widget.userId,_prefs),
                              title: 'Drafted Posts',
                              icon: Ionicons.ios_save
                            ),
                          ],
                        );
                        else return Container();
                      }()),
                    ],
                  )
                  : Container(),
                  DrawerTile(
                    icon: MaterialIcons.collections_bookmark,
                    // routeWidget: BookMarked(),
                     navigation: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) {
                            return SafeArea(child:BookMarked());
                              })).then((value) => setState((){})),
                    title: 'Bookmarked Posts',
                  ),
                  ExpansionTile(
                    leading: Icon(MaterialCommunityIcons.calendar_alert,
                      color:CustomColors(context).iconColor
                    ),
                    title: Text('Events',
                      style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito'),
                    ),
                    backgroundColor: CustomColors(context).exapndedTileColor,
                    children: [
                      DrawerTile(
                        icon: Octicons.calendar, 
                        // routeWidget: Calendar(),
                         navigation: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) {
                            return SafeArea(child:Calendar());
                              })).then((value) => setState((){})),
                        title: 'Schedule',
                      ),
                      DrawerTile(
                        icon: MaterialCommunityIcons.timetable,
                        // routeWidget: OnGoingEventPage(),
                        navigation: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) {
                            return SafeArea(child:OnGoingEventPage());
                              })).then((value) => setState((){})),
                        title: 'Ongoing Events',
                      ),
                      DrawerTile(
                        icon: MaterialCommunityIcons.calendar_outline,
                        // routeWidget: UpcomingEventsPage(),
                        navigation: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) {
                            return SafeArea(child: UpcomingEventsPage());
                              })).then((value) => setState((){})),
                        title: 'Upcoming Events',
                      ),
                    ],
                  ),
                  
                  // DrawerTile(
                  //   icon: Octicons.calendar, //TODO add calendar icon
                  //   routeWidget: Calendar(),
                  //   title: 'Time Table',
                  // ),
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
                              if(mounted) setState(() {
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
                    // onTap: ()async{
                    //   await DBProvider().getAllPostsWithoutPermissions().then((value){
                    //     value.forEach((v){
                    //       print(v.sub);
                    //     });
                    //   });
                    //   await p1('0', owner:id);
                      // showErrorToastWithButton('Testing this toast with a long message as we can usually have and this is a test to test the button functionality  and adaptance of toast',
                      //   (){print("tap");}
                      // );
                    // },
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
                  if(mounted) setState(() {
                    _load = true;
                  });
                  Future.delayed(Duration(seconds: 2),(){
                    if(mounted) setState((){_load = false;});
                  });
                }
              }, icon: Icon(Icons.refresh), label: Text('Reload again')),
            ],
          ),
        // ): Container(
        ):
        Stack(
          children: [
            FutureBuilder(
              future: DatabaseProvider().noOfPosts(),
              builder: (context, snapshot) {
                return FutureBuilder(
                  future: DBProvider().getAllPostsWithoutPermissions(),
                  builder: (context, snapshot) {
                    return snapshot != null && snapshot.hasData ?
                      HomeDescription(
                        postArray: snapshot.data.cast<Posts>()??globalPostsArray.cast<Posts>(),
                        userModel:/*(sn == null || sn.data == null || sn.data.value == null)?*/ userData.toMap()[0]/*:sn.data.value*/,
                        userID: userData.toMap()[0].uid,
                        load: refreshPost,
                      )
                    : Center(child: CircularProgressIndicator());
                  }
                );
              }
            ),
            StreamBuilder(
              stream: _newPostStreamController.stream,
              builder: (context, newPost) {
                print(newPost);
                return newPost != null
                  && newPost.data == true
                  ? StatefulBuilder(
                  builder: (context, reBuild) {
                    return Positioned(
                      top: 5,
                      width: newPostLoading == true? 130 : 60,
                      left: MediaQuery.of(context).size.width *0.5 - (newPostLoading == true?65 : 30),
                      child: RaisedButton(
                        padding: EdgeInsets.all(2),
                        onPressed: (){
                          reBuild((){
                            newPostLoading = !newPostLoading;
                          });
                        },
                        child: newPostLoading == true?
                          Text("New Posts",
                            style: TextStyle(fontSize: 15),
                          )
                      : SpinKitFadingCircle(color: Colors.white, size: 25,),));
                  }
                ): Container();
              }
            )
          ],
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
      searchModel = (list!=null&&list.length != 0)?list[0]: SearchModel(gender: '',name: id,);
      id = userData.toMap()[0].id;
      admin = userData.toMap()[0].admin ?? false;
      name = (list!=null&&list.length != 0)? userData.toMap()[0].name= list[0].name: userData.toMap()[0].id;
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
      return await populateUsers().then((status)async{
        if(status == true){
          Box userBox = await HiveDatabaseUser().hiveBox;
          if(userBox.isNotEmpty && userData.toMap()[0]!=null){
            id = userBox.toMap()[0].id;
            admin = userBox.toMap()[0].admin ?? false;
            name = userBox.toMap()[0].name ?? id;
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
    print(".....POPULATING PEOPLE>>>>>>>>>>>");
    if(peopleBox.isNotEmpty){
      try {
        PeopleModel model =peopleBox.toMap()[0];
        print("PEOPLE DATA >>>>> MODEL ${model.councils}");
        allCouncilData.coordOfCouncil = model.councils.keys.toList();
        // print(allCouncilData.coordOfCouncil);
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
    return await DBProvider().getAllPostsWithoutPermissions().then((var v)async{
      if(v!=null && v.length != 0){
        if(mounted)
          if(mounted) setState(() {
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
  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) => onBackgroundMessage(message);
}




printPosts(Posts nwPosts){
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