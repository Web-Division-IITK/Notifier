// import 'dart:convert';

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:http/http.dart';
// import 'package:intl/intl.dart';
// import 'package:notifier/database/reminder.dart';
// import 'package:notifier/model/notification.dart';
// import 'package:notifier/model/posts.dart';
// import 'package:notifier/screens/posts/create_edit_posts.dart';
// import 'package:notifier/services/database.dart';
// import 'package:notifier/services/functions.dart';
// import 'package:notifier/services/inherited_widget.dart';
// import 'package:notifier/widget/loading.dart';
// import 'package:notifier/widget/showtoast.dart';

// class PostListData extends StatefulWidget {
//   final String type;
//   final String id;
//   PostListData(this.type,this.id);
//   @override
//   _PostListDataState createState() => _PostListDataState();
// }

// class _PostListDataState extends State<PostListData> {
//   @override
//   Widget build(BuildContext context) {
//     return PostList(type: widget.type, sendToChildren: DataHolderAndProvider.of(context).data.value,id: widget.id,);
//   }
// }
// class PostList extends StatefulWidget {
//   final String type;
//   // final Map<String, dynamic> postsMap;
//   // final Map<String,dynamic> peopleData;
//   final String id;
//   // final Map<String,PostsSort> globalPostMap;
//   final SendToChildren sendToChildren;
//   PostList({@required this.type, /*@required this.postsMap,*/ this.sendToChildren ,/*this.peopleData*/ this.id});
//   @override
//   _PostListState createState() => _PostListState();
// }

// class _PostListState extends State<PostList> {
//   // TabController _tabBarController;
//   // Map<String, PostsSort> globalPostMap = {};
//   // Map<String,Map<String,PostsSort>> postSort = {};
//   Map<String,List<PostsSort>> postSort = {};


//   // Map<String,
//   List<bool> _noPost = [];
//   bool _load = false;
//   // bool _loadingDelete = false;
  
//   // List<PostsSort> globalPostsArray = [];
//   @override
//   void initState() {
//     super.initState();
//     _load = true;
//     postLists();
//     // widget.
//   }
// postLists()async{
//   await loadPostsListAccordingToCouncil().then((v){
//     // Future.delayed(Duration(milliseconds: 80),(){
//     if(v){
//       print(postSort);
//       if(postSort==null){
//         setState(() {
//           _load = false;
//         });
//       }else{
//         print('load');
//         postSort.keys.forEach((council) {
//           tabs.add(Tab(
//             text: convertToCouncilName(council),
//           ));
//           setState(() {
//             _load = false;
//           });
//         });
//       }
//     }
//     else{
//       //TODO make error
//     }
//     // });  
//   });
// }
//   List<Tab> tabs = [];
//   List<Widget> list = [];
//   @override
//   Widget build(BuildContext context) {
//     return 
//     (tabs.length == 1
//         ? scaffoldBuild()
//         : DefaultTabController(length: postSort.length, child: scaffoldBuild()));
//   }
// Widget error(){
//   return Scaffold(
//     appBar: AppBar(
//       title: Text(widget.type[0] + widget.type.substring(1)),
//     ),
//     body:Center(
//       child: Text('Error while loading'),
//     )
//   );
// }
//   Widget scaffoldBuild() {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.type[0] + widget.type.substring(1)),
//         bottom: tabs.length != 1
//             ? TabBar(tabs: [
//                 ...tabs,
//               ])
//             : null,
//             // actions: <Widget>[
//             //   IconButton(icon: Icon(Icons.refresh), 
//             //   onPressed: (){
//             //    setState(() {
//             //     //  initState();
//             //    });
//             //   })
//             // ],
//       ),
//       body: _load?
//       // Container(child: Center(child: CircularProgressIndicator(),),)
//       Loading(display: 'loading ' + (widget.type.toLowerCase() == 'update'? 'posts' : 'drafts'),):
//       (tabs.length == 1
//           ? (_noPost[0]? Container(
//             child: Center(
//               child: Text(
//                 widget.type.toLowerCase() == 'update'? 'You have not made any post under this section':
//                 'You have not saved any post for this council'),),)
//             :  tiles(postSort.values.toList()[0]))
//           : TabBarView(
//               children: <Widget>[
//                 for (var i in postSort.values) 
//                 (_noPost[postSort.values.toList().indexOf(i)] ? Container(child: Center(child: Text(
//                    widget.type.toLowerCase() == 'update'? 'You have not made any post under this section':
//                 'You have not saved any post for this council'),),)
//                   :  tiles(i))
//               ])),
//     );
//   }
//   Widget tiles(List< PostsSort> postAccToCouncil) {
//     final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
//     return AnimatedList(
//       key: _listKey,
//       initialItemCount: postAccToCouncil.length,
//       itemBuilder: (BuildContext context, index,animation) {
//         var arrayOfPosts = postAccToCouncil.toList();
//         return SizeTransition(
//           sizeFactor: animation,
//           child: Dismissible(
//             movementDuration: Duration(milliseconds:30),
//             resizeDuration: Duration(milliseconds: 60),
//             dismissThresholds: {DismissDirection.endToStart : 0.8},
//             background: Card(
//               color: Colors.red,
//               margin: index==0? EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0)
//               : EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
//               elevation: 5.0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0)
//               ),
//               // padding: EdgeInsets.symmetric(horizontal: 20),
//               // alignment: AlignmentDirectional.centerStart,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Icon(
//                     Octicons.trashcan,
//                     color: Colors.white,
//                   ),
//                   SizedBox(width:15.0),
//                   Text(
//                     'Delete',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18.0
//                     ),
//                   ),
//                 ], 
//               ), 
//             ),
//             direction: DismissDirection.endToStart,
//             key: Key(arrayOfPosts[index].id),
//             confirmDismiss: (DismissDirection direction){
//               return confirmDismissDialog(arrayOfPosts[index],_listKey,index);
//             },
//             // confirmDismissDialog(),
//             child: Card(
//               margin: index==0? EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0)
//               : EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
//               elevation: 5.0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0)
//               ),
//               child: Stack(
//                 children: <Widget>[
//                   Container(
//                     // width: MediaQuery.of(context).size.width - 52,
//                     child: ListTile(
//                       // isThreeLine: true,
//                       title: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           SizedBox(height:8.0),
//                           Text(arrayOfPosts[index].sub,
//                             style: TextStyle(
//                               fontSize:10.0
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           Text(arrayOfPosts[index].title,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 20.0,
//                             ),
//                           ),
//                           SizedBox(height:10.0)
//                         ],
//                       ),
//                       subtitle: Container(
//                         padding: EdgeInsets.only(bottom:8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Text(
//                               arrayOfPosts[index].message.trimRight(),
//                               // 'Ipsum ad est duis irure veniam.Excepteur consequat consequat officia in et laboris labore in laborum aute adipisicing elit sit irure.',
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               // 
//                             ),
//                             SizedBox(height:5.0)
//                           ],
//                         ),
//                       ),
//                       onTap: (){
//                         // _listKey.currentState.insertItem(index)
//                         Navigator.of(context).push(MaterialPageRoute(builder: (context){
//                           return CreateEditPosts(widget.type, index, arrayOfPosts[index]); 
//                         }));
//                       },
//                     ),
//                   ),
//                   Positioned(
//                     // height: 50.0,
//                     // width: 100.0,
//                     bottom: 8.0,
//                     right: 8.0,
//                     // alignment: Alignment.bottomRight,
//                     child: AutoSizeText(
//                       convertDateToString(DateTime.fromMillisecondsSinceEpoch(arrayOfPosts[index].timeStamp))+ ' at ' +
//                       DateFormat("hh:mm a").format(DateTime.fromMillisecondsSinceEpoch(arrayOfPosts[index].timeStamp)),
//                       maxLines: 1,
//                       minFontSize: 7,
//                       style: TextStyle(
//                         fontSize: 8.0
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<bool> loadPostsListAccordingToCouncil()async{
//     setState(() {
//       _load = true;
//     });
//     return await fileExists('people').then((peopleExists)async{
//       if(peopleExists){
//         return await readContent('people').then((peopleData)async{
//           print(peopleData);
//           if(widget.type.toLowerCase() == 'update'){
//             return await DBProvider().getAllPostswithQuery(GetPosts(queryColumn: 'owner', queryData: peopleData['id'])).then((list)async{
//               list.sort((a,b)=>b.timeStamp.compareTo(a.timeStamp));
//               return await Future.value(
//                 null != Future.forEach(peopleData['councils'], (council){
//                   print(council);
//                   postSort.update(
//                     council.toString().toLowerCase(), 
//                     (v){
//                       List<PostsSort> v = [];
//                       return v..addAll(list.where((test)=>test.council == council));
//                       // return v.reversed.toList();
//                     },
//                     ifAbsent: (){
//                       List<PostsSort> v = [];
//                       return v..addAll(list.where((test)=>test.council == council));
//                       // return v.reversed.toList();
//                     }
//                     ,
//                   );
//                   if(postSort[council] == null ||postSort[council].length == 0){
//                     _noPost.add(true);
//                   }else{
//                     _noPost.add(false);
//                   }
//               })
//               ).whenComplete(()=>true);
//             });
//           }
//           else if(widget.type.toLowerCase() == 'drafts'){
//            _noPost = [];
//            return null == await Future.doWhile(()async{
//               return null!= await Future.forEach(peopleData['councils'],(council)async{
//                return await DatabaseProvider(databaseName: 'drafts',tableName: 'Drafts').getAllPostswithQuery(
//                 GetPosts(queryColumn: 'council', queryData: council.toString().toLowerCase())).then((list){
//                   print(list);
//                   list.sort((a,b)=>b.timeStamp.compareTo(a.timeStamp));
//                   postSort.update(council.toString().toLowerCase(), (v)=>list,
//                     ifAbsent: ()=>list
//                 );
//                 if(postSort[council] == null ||postSort[council].length == 0){
//                   _noPost.add(true);
//                 }else{
//                   _noPost.add(false);
//                 }
//               });
                
//             });
//             // return _noPost.length!= peopleData['councils'].length;
//            }).whenComplete(()=>true);
//           }
//           else{
//             return true;
//           }
//         });
//       }else{
//         return await populatePeople(widget.id).then((people)async{
//           if(people == null){
//             return false;
//           }if(people.status && people.popleData !=null){
//            return await loadPostsListAccordingToCouncil();
//           }else{
//             postSort = {'snt':[]};
//             return true;
//           }
//         });
//       }
//     });
//   }
//   // Widget tiles(Map<String, PostsSort> postAccToCouncil) {
//   //   return ListView.separated(
//   //     separatorBuilder: (BuildContext context, index) {
//   //       return Divider(
//   //         color: Colors.blueGrey,
//   //       );
//   //     },
//   //     itemCount: postAccToCouncil.length,
//   //     itemBuilder: (BuildContext context, index) {
//   //       var arrayOfPosts = postAccToCouncil.values.toList();
//   //       return Dismissible(
//   //         movementDuration: Duration(milliseconds:30),
//   //         resizeDuration: Duration(milliseconds: 60),
//   //         dismissThresholds: {DismissDirection.endToStart : 0.6},
//   //         // onResize: ()=>Container(
//   //         //   color: Colors.red,
//   //         //   padding: EdgeInsets.symmetric(horizontal: 20),
//   //         //   alignment: AlignmentDirectional.centerStart,
//   //         //   child: Row(
//   //         //     mainAxisAlignment: MainAxisAlignment.center,
//   //         //     children: <Widget>[
//   //         //       Icon(
//   //         //         Icons.delete,
//   //         //         color: Colors.white,
//   //         //       ),
//   //         //       SizedBox(width:15.0),
//   //         //       Text(
//   //         //         'Delete',
//   //         //         style: TextStyle(
//   //         //           color: Colors.white,
//   //         //           fontSize: 18.0
//   //         //         ),
//   //         //       ),
//   //         //     ], 
//   //         //   ), 
//   //         // ),
//   //         background: Container(
//   //           color: Colors.red,
//   //           padding: EdgeInsets.symmetric(horizontal: 20),
//   //           alignment: AlignmentDirectional.centerStart,
//   //           child: Row(
//   //             mainAxisAlignment: MainAxisAlignment.center,
//   //             children: <Widget>[
//   //               Icon(
//   //                 Icons.delete,
//   //                 color: Colors.white,
//   //               ),
//   //               SizedBox(width:15.0),
//   //               Text(
//   //                 'Delete',
//   //                 style: TextStyle(
//   //                   color: Colors.white,
//   //                   fontSize: 18.0
//   //                 ),
//   //               ),
//   //             ], 
//   //           ), 
//   //         ),
//   //         direction: DismissDirection.endToStart,
//   //         key: Key(arrayOfPosts[index].id),
//   //         confirmDismiss: (DismissDirection direction){
//   //           return confirmDismissDialog(arrayOfPosts[index]);
//   //         },
//   //         // confirmDismissDialog(),
//   //         child: ListTile(
//   //           // isThreeLine: true,
//   //           // trailing: ,
//   //           title: Text(arrayOfPosts[index].title),
//   //           subtitle: Text(arrayOfPosts[index].message.trimRight()),
//   //           onTap: (){
//   //             Navigator.of(context).push(MaterialPageRoute(builder: (context){
//   //               return CreateEditPosts('Update', index, arrayOfPosts[index]); 
//   //             }));
//   //           },
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }

//   confirmDismissDialog(PostsSort postsSort,_listKey,int index) {
//     return showDialog<bool>(
//       barrierDismissible: false,
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//               title: Row(
//                 children: <Widget>[
//                   Icon(
//                     Icons.warning,
//                     color: Colors.red,
//                   ),
//                   Text(
//                     ' Delete this Post ?',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ],
//               ),
//               content: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     Text(
//                       'Doing this will permanently delete this file',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 5.0),
//                     Text(
//                         'Note: You will not be able to recover this file later',
//                         style: TextStyle(
//                             fontSize: 10.0,
//                             color: Colors.red,
//                             fontWeight: FontWeight.bold)),
//                     SizedBox(height: 10.0),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: <Widget>[
//                         Container(
//                           child: FlatButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                               return false;
//                             },
//                             child: Text('Dismiss'),
//                           ),
//                         ),
//                         SizedBox(width: 10.0),
//                         Container(
//                           child: RaisedButton(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () async {
//                               // a
//                               showInfoToast('Deleting post');
//                               Navigator.pop(context);
//                               _listKey.currentState.removeItem(
//                                 index,
//                                 (BuildContext context,Animation<double> animation){
//                                   return Container();
//                                 }
//                               );
//                               if(widget.type.toLowerCase() == 'drafts'){
//                                 return await deletePostFromList(postsSort).then((bool status){
//                                   if(status){
//                                     showSuccessToast('Draft deleted successfully');
//                                     return true;
//                                   }else{
//                                     showErrorToast('An error occurred while deleteing this post');
//                                     _listKey.currentState.insertItem(index);
//                                     return false;
//                                   }
//                                 });
//                               }
//                               else{
//                                 Response res = await deletePost(
//                                   postsSort
//                                 );
//                                 if (res.statusCode == 200) {
//                                   DBProvider().deletePost(postsSort.id);
//                                   showSuccessToast('Deleted post successfully');
//                                   return true;
//                                   // return writeContent('people', json.encode(widget.peopleData));
//                                 } else {
//                                   // setState(() {
//                                   //   _loadingDelete = false;
//                                   // });
//                                   showErrorToast('An error occurred while deleteing this post');
//                                   _listKey.currentState.insertItem(index);
//                                   return false;
//                                   // Navigator.pop(context);
//                                 }
//                               }
//                             },
//                             child: Text(
//                               'Confirm',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   ]));
//         });
//   }
//   Future<bool> deletePostFromList(PostsSort postsSort)async{
//     if (postsSort.url != null) {
//       clearSelection(postsSort.url);
//     }
//     return await DatabaseProvider(databaseName: 'drafts',tableName: 'Drafts').deletePost(postsSort.id).then((changes){
//       if(changes!=0){
//         return true;
//       }else{
//         return false;
//       }
//     });
//   }
//   Future<bool> clearSelection(String url) async {
//     try {
//       StorageReference storageReference =
//         await FirebaseStorage.instance.getReferenceFromUrl(url);
//       return await storageReference.delete().then((_) {
//         return true;
//       }).catchError((onError){
//         print(onError);
//         // showErrorToast('Failed!!!');
//         return false;
//       });
//     // StorageUploadTask uploadTask = storageReference.putFile(_image);
  
//     } catch (e) {
//       print(e);
//       return false;
//     }
// }
// }
