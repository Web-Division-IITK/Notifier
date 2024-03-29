import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/posts/create_edit_posts.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';

class PendingApproval extends StatefulWidget {
  PendingApproval({Key key}) : super(key: key);

  @override
  _PendingApprovalState createState() => _PendingApprovalState();
}

class _PendingApprovalState extends State<PendingApproval>{
  Repository repo = Repository(allCouncilData);
  static DateTime time;
  // List<String> _entity = [];
  bool islevel2 = ids.contains(id);
  
  @override
  void initState() {
    print(islevel2);
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Approvals'),
        centerTitle: true,
        ),
      body:
          FutureBuilder(
            // future : DatabaseProvider(databaseName: 'permission',tableName: 'perm').getAllPosts(),
            future : DBProvider().getAllApprovalPost(
              GetPosts(
                queryColumn: 'council', queryData: allCouncilData.coordOfCouncil[0]),
               islevel2, id),
            builder: (context,AsyncSnapshot<List<Posts>> snapshot){
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if((snapshot == null || snapshot.data == null || snapshot.data.length == 0)){
                    return RefreshIndicator(
                      onRefresh: ()async{
                        // if(islevel2 ){
                          if(time ==null){
                            await getDataNotfs();
                            setState(() {});
                          }else if( DateTime.now().millisecondsSinceEpoch -time.millisecondsSinceEpoch>3000){
                            await getDataNotfs();
                            setState(() {});
                          }else{
                            Future.delayed(Duration(seconds:2),()=>true);
                          }
                          time = DateTime.now();
                        // }else{
                        //   Future.delayed(Duration(seconds: 2),() => setState(() {}));
                        // }
                      },
                      child: ListView(
                        children: <Widget>[
                          Container(
                            // height: MediaQuery.of(context).size.height - 85,
                            padding:EdgeInsets.only(top:MediaQuery.of(context).size.height*0.4,),
                            child: Center(child: islevel2?Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('No pending request.'),
                                Text('You can try refreshing to see if there exists any')
                              ],
                            )
                              : Text('You have no pending request')
                            ),
                          ),
                        ],
                      ),
                    );
                  }else{
                    print(snapshot.data);
                    
                    // snapshot.data.retainWhere((test)=> allCouncilData.subCouncil[allCouncilData.coordOfCouncil[0]].coordiOfInCouncil.contains(test.sub));
                    return RefreshIndicator(
                      // backgroundColor: Theme.of(context).accentColor,
                      // showChildOpacityTransition: false,
                      onRefresh: ()async{
                        // if(islevel2){
                          if(time ==null){
                            await getDataNotfs();
                            setState(() {});
                          }else if( DateTime.now().millisecondsSinceEpoch -time.millisecondsSinceEpoch>3000){
                            await getDataNotfs();
                            setState(() {});
                          }else{
                            Future.delayed(Duration(seconds:2),()=>true);
                          }
                          time = DateTime.now();
                        // }else{
                        //   Future.delayed(Duration(seconds: 2),() => setState(() {}));
                        // }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height - 88,
                        child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              tiles(
                                // List.generate(20, (index)=>snapshot.data[0]).toList()
                                snapshot.data
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    // );
                  }
                  break;
                default: return Container(
                  padding: EdgeInsets.only(top:MediaQuery.of(context).size.width*0.5,),
                  child: Center(child: CircularProgressIndicator(),),);
              }
            }
          ),
        // ],
      // ),
    );
    // });
  }
  Widget tiles(List< Posts> postAccToCouncil) {
    final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
    return AnimatedList(
      physics: NeverScrollableScrollPhysics(),
      // physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      key: _listKey,
      initialItemCount: postAccToCouncil.length ,
      itemBuilder: (BuildContext context, index,animation) {
        // index = 0;
        var arrayOfPosts = postAccToCouncil.toList();
        return SizeTransition(
          sizeFactor: animation,
          child: Dismissible(
            movementDuration: Duration(milliseconds:30),
            resizeDuration: Duration(milliseconds: 60),
            dismissThresholds: {DismissDirection.endToStart : 0.8},
            background: Card(
              color: Colors.red,
              margin: index==0? EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0)
              : EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)
              ),
              // padding: EdgeInsets.symmetric(horizontal: 20),
              // alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Octicons.trashcan,
                    color: Colors.white,
                  ),
                  SizedBox(width:15.0),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0
                    ),
                  ),
                ], 
              ), 
            ),
            direction: DismissDirection.endToStart,
            key: Key(arrayOfPosts[index].id),
            confirmDismiss: (DismissDirection direction){
              // TODO also remove post from arrayu of post
              return confirmDismissDialog(arrayOfPosts[index],_listKey,index);
            },
            child: Card(
              elevation: 5.0,
             margin: index==0? EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0)
              : EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16.0),
                onTap: () {
                   Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return arrayOfPosts[index].owner == id?
                    CreateEditPosts(islevel2? PostDescType.APPROVAL :PostDescType.CREATE_POSTS, index, arrayOfPosts[index],title: 'perm',)
                    : FeatureDiscovery(child: 
                      PostDescription(
                        listOfPosts: arrayOfPosts, 
                        type: PostDescType.APPROVAL,index: index,)); 
                  }));
               
                },
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      right: 16,
                      top:0,
                      child: Container(
                              padding: EdgeInsets.only(left:10),
                              child: islevel2?
                              Container()
                              : (postAccToCouncil[index].type.toLowerCase() == NOTF_TYPE_PERMISSION?
                              SpinKitThreeBounce(size:20,
                                color: Theme.of(context).accentColor,
                              )
                              : Icon(Ionicons.ios_done_all,color: Colors.green,))
                            )
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(16.0, 8.0, 40.0, 0.0),
                              child: AutoSizeText(
                                   postAccToCouncil[index].sub[0].toString(),
//                                  'Science and Texhnology Council',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? Colors.blueGrey
                                        : Colors.white70,
                                    // fontWeight: FontStyle.italic,
                                    fontSize: 10.0,
                                  )),
                            ),
                            // Container(
                            //   padding: EdgeInsets.only(left:10),
                            //   child: postAccToCouncil[index].type.toLowerCase() == 'permission'?
                            //   SpinKitThreeBounce(size:20,
                            //     color: Theme.of(context).accentColor,
                            //   )
                            //   : Icon(Ionicons.ios_done_all,color: Colors.green,),
                            // )
                          ],
                        ),
                        Container(
                          // alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
                          child: AutoSizeText(postAccToCouncil[index].title,
                              // 'Sit commodo fugiat duis consectetur sunt ipsum cupidatat adipisicing mollit et magna duis.',
                              minFontSize: 15.0,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 84.0,
                          ),
                          child: AutoSizeText(
                            // timenot['message'],
                            postAccToCouncil[index].message,
                            // 'Dolor consectetur in dolore anim reprehenderit velit pariatur veniam nostrud id ex exercitation.',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[850]
                                  : Colors.white70,
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 5.0),
                            alignment: Alignment.bottomRight,
                            child: Text(
                              // time,
                              convertDateToString(DateTime.fromMillisecondsSinceEpoch(arrayOfPosts[index].timeStamp))+ ' at ' +
                              DateFormat("hh:mm a").format(DateTime.fromMillisecondsSinceEpoch(arrayOfPosts[index].timeStamp)),
                              style: TextStyle(
                                fontSize: 8.0,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey
                                    : Colors.white70,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  confirmDismissDialog(Posts posts,_listKey,int index) {
    return showDialog<bool>(
      barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  Text(
                    ' Delete this Post ?',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              content: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      // !islevel2 ?
                      'Doing this will permanently delete this post for everyone',
                      // : 'Doing this will delete this post for you',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                        'Note: You will not be able to recover this file later',
                        style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              return false;
                            },
                            child: Text('Dismiss'),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Container(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            onPressed: () async {
                              // a
                              showInfoToast('Deleting post');
                              Navigator.pop(context);
                              _listKey.currentState.removeItem(
                                index,
                                (BuildContext context,Animation<double> animation){
                                  return Container();
                                }
                              );
                              // if(!islevel2){
                                Response res = await deletePost(
                                  posts
                                );
                                if (res.statusCode == 200) {
                                  if(posts.url!=null) clearSelection(posts.url);
                                  DBProvider().deletePost(posts.id);
                                  showSuccessToast('Deleted post successfully');
                                  setState(() {
                                    
                                  });
                                  return true;
                                } else {
                                  showErrorToast('An error occurred while deleteing this post');
                                  _listKey.currentState.insertItem(index);
                                  return false;
                                }
                              // }else{
                              //   await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(posts.id);
                              //   showSuccessToast('Deleted post successfully');
                              //   return true;
                              // }
                            },
                            child: Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  ]));
        });
  }
  Future<bool> clearSelection(String url) async {
    try {
      Reference storageReference =
         FirebaseStorage.instance.refFromURL(url);
      return await storageReference.delete().then((_) {
        return true;
      }).catchError((onError){
        print(onError);
        return false;
      });
    } catch (e) {
      print('Error while deleting image $e');
      return false;
    }
    // StorageUploadTask uploadTask = storageReference.putFile(_image);
  }
}

Future getDataNotfs()async{
  var db = Firestore.instance;
  print(allCouncilData.coordOfCouncil);
  if(ids.contains(id)){
  //   return await db.collection('allPosts').where('type', isEqualTo: 'permission')
  //   .orderBy('timeStamp',descending: true)
  //   .getDocuments().then((var value)async{
  //     if (value.documents!=null) {
  //       value.documents.forEach((document){
  //         var data =  document.data;
  //         data.update('sub', (v)=>v[0]);
  //         DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(postsSortFromJson(json.encode(data)));
  //       });
  //     } else {
  //       return 1;
  //     }
  //   }).catchError((onError){
  //     print(onError);
  //     return 1;
  //   });
  // }else if(!ids.contains(id)){
  //   //TODO
  // }
  // else if(allCouncilData.coordOfCouncil[0] =='anc'){
  //   return await db.collection('allPosts').where('type', isEqualTo: 'permission').where('council',isEqualTo: allCouncilData.coordOfCouncil[0])
  //     .where('sub',arrayContainsAny: allCouncilData.subCouncil[allCouncilData.coordOfCouncil[0]].coordiOfInCouncil)
  //     .orderBy('timeStamp',descending: true)
  //     .getDocuments().then((var value)async{
  //     if (value.documents!=null) {
  //       value.documents.forEach((document){
  //         var data =  document.data;
  //         data.update('sub', (v)=>v[0]);
  //         DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(postsSortFromJson(json.encode(data)));
  //       });
  //     } else {
  //       return 1;
  //     }
  //   }).catchError((onError){
  //     print(onError);
  //     return 1;
  //   });
  // }
  // else{
    try {
      Response res = await post(FETCH_PENDINGAPPR_POST_WITH_COUNCIL_API, headers: HEADERS, 
        body: json.encode({TYPE: NOTF_TYPE_PERMISSION, COUNCIL: allCouncilData.coordOfCouncil[0]})
      );
      print('RESPONSE STATUSCODE - ' + res.statusCode.toString());
      print(res.body);

      if(res == null || res.statusCode != 200 || res.body == null){
        print("ERROR WHILE FETCHING APPROVAL POST FOR LEVEL2");
        return 1;
      }else{
        var data = json.decode(res.body);
        data.forEach((post){
          post[TIMESTAMP] = (post[TIMESTAMP] is String)? double.parse(post[TIMESTAMP]).round() :post[TIMESTAMP];
              if(post.containsKey(STARTTIME)){
                post[STARTTIME] = (post[STARTTIME] is String)? double.parse(post[STARTTIME]).round() :post[STARTTIME];
              }
              if(post.containsKey(ENDTIME)){
                post[ENDTIME] = (post[ENDTIME] is String)? double.parse(post[ENDTIME]).round() :post[ENDTIME];
              }
          // data.update(SUB, (v)=>v[0]);
          DBProvider().insertPost(postsFromJson(json.encode(post)));
        });
      }
    } catch (e) {
      print("ERROR WHILE FETCHING APPROVAL POST FOR LEVEL2");
      print(e);
      return 1;
    }
    // return await db.collection('allPosts').where('type', isEqualTo: 'permission').where('council',isEqualTo: allCouncilData.coordOfCouncil[0])
    // .getDocuments().then((var value)async{
    //   if (value.documents!=null) {
    //     value.documents.forEach((document){
    //       var data =  document.data;
    //       data.update('sub', (v)=>v[0]);
    //       DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(postsSortFromJson(json.encode(data)));
    //     });
    //   } else {
    //     return 1;
    //   }
    // }).catchError((onError){
    //   print(onError);
    //   return 1;
    // });
  }
  else{
    return await p1('5',owner: id) == false;
  }
}