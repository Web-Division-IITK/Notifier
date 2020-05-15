import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/loading.dart';

class BookMarked extends StatefulWidget {
  @override
  _BookMarkedState createState() => _BookMarkedState();
}

class _BookMarkedState extends State<BookMarked> {
  bool _load = true;
  List<PostsSort> bookmarkArray = [];
  bool _noPost = false;
  final GlobalKey<AnimatedListState> _bookmarkKey = GlobalKey<AnimatedListState>();
  DateTime timeOfRefresh ;
  @override
  void initState() {
    super.initState();
    _load = true;
    loadBookMarks();
  }
  // Iterable<Widget> get arrayofTime sync*{
  // //  List<PostsSort> globalPostsArray= widget.data.globalPostsArray;
  // //  var prefs = widget.data.prefs;
  // //   = postArray.values.toList();
  //   List<PostsSort> postArray = bookmarkArray;
    
  //   // if( postArray==null && postArray.length==0){
  //   //     // yield Container(
  //   //     //   height: 100.0,
  //   //     //   child: Center(
  //   //     //   child: Text(
  //   //     //     'No posts exists right now'
  //   //     //   ),
  //   //     // ),);
        
  //   // }
  //   // else{
  //     for (var i in postArray) {
  //       // DateTime postTime = DateTime.parse(i.value['timeStamp']);
  //       DateTime postTime = DateTime.fromMillisecondsSinceEpoch(i.timeStamp);
  //       var time;var day;
  //       if (DateTime.now().day == postTime.day && DateTime.now().month == postTime.month && DateTime.now().year == postTime.year) {
  //         if (DateTime.now().hour == postTime.hour || (DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) < 3600000) {
  //           switch (DateTime.now().minute - postTime.minute) {
  //             case 0:
  //               time = 'now';
  //               day = 'Today';
  //             break;
  //             default:
  //               var i = ((DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) /60000).round();
  //               time = '$i minutes ago';
  //               day = 'Today';
  //           }
  //         } else {
  //           time = 'Today at ' + DateFormat('hh:mm a').format(postTime);
  //           day = 'Today';
  //         }
  //       } else if(convertDateToString(postTime) == 'Yesterday'){
  //           time ='Yesterday at '+ DateFormat('hh:mm a').format(postTime);
  //           day = DateFormat('d MMMM, yyyy').format(postTime);
  //       }else{
  //         time = DateFormat('hh:mm a, dd MMMM, yyyy').format(postTime);
  //       }
  //         yield Container(child: tile(postArray.indexOf(i) , time,postArray));
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarked Posts'),
      ),
      body: 
      // FutureBuilder(
      // future: DBProvider().getAllPostswithQuery(GetPosts(queryColumn: 'bookmark', queryData: 1),orderBy: "timeStamp DESC",type: 'bookmark'),
      //   builder: (context,snapshot){
          // switch (snapshot.connectionState) {
          //   case ConnectionState.done:
          !_load ?(_noPost ||bookmarkArray ==null || bookmarkArray.length == 0)?
          //     if(snapshot == null ||snapshot.data == null || snapshot.data.length == 0){
                // return 
                Center(child: Text('You have not bookmarked any post'),)
              // }else{
                // print(snapshot.data.toString() +  'jdjh');
                // return 
                 : AnimatedList(
              // padding: EdgeInsets.all(16),
                  // reverse: true,
                  initialItemCount: bookmarkArray.length,
                  // snapshot.data.length,
                  key: _bookmarkKey,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, index,animation) {
                    List<PostsSort> arrayOfPosts = bookmarkArray;
                    // snapshot.data;
                    return SizeTransition(
                      sizeFactor: animation,
                      child: Dismissible(
                      movementDuration: Duration(milliseconds:30),
                      resizeDuration: Duration(milliseconds: 60),
                      dismissThresholds: {DismissDirection.endToStart : 0.8},
                      background: Card(
                        color: Colors.red,
                        margin: index==0? EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 8.0)
                        : EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
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
                              'Remove from Bookmarks',
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
                      onDismissed:(direction)async{
                        _bookmarkKey.currentState.removeItem(index, 
                          (BuildContext context,Animation<double> animation){
                            return Container();
                        });
                       
                          if(arrayOfPosts.toList().length == 1){
                            setState(() {
                              _noPost = true;
                            });
                          }
                        // });
                        return await dismiss(arrayOfPosts, index);
                      },
                      // confirmDismissDialog(),
                      child: Card(
                              elevation: 5.0,
                            margin: index==0?EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0)
                              : EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.0),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                            return FeatureDiscovery(child: PostDescription(listOfPosts: arrayOfPosts, type: 'display',index: 0,)); 
                                          }));
                              
                                },
                                child: Stack(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.fromLTRB(16.0, 8.0, 40.0, 0.0),
                                              child: AutoSizeText(
                                                  arrayOfPosts[index].sub,
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
                                            //   child: arrayOfPosts[index].type.toLowerCase() == 'permission'?
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
                                          child: AutoSizeText(arrayOfPosts[index].title,
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
                                            arrayOfPosts[index].message,
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
                  }
                )
              // }
              // break;
            // default: return
            : Container(
              height:MediaQuery.of(context).size.height ,
              color: Colors.black.withOpacity(0.8),
            child: Loading(display: 'Unable to load'))
          // }
        // }
      ) ;
  //     _load?
  //     Loading(display: 'loading Bookmarks',)
  //     :
  //     _noPost ==false ?AnimatedList(
  //       padding: EdgeInsets.all(16),
  //           // reverse: true,
  //           initialItemCount: arrayofTime.toList().length,
  //           key: _bookmarkKey,
  //           shrinkWrap: true,
  //           itemBuilder: (BuildContext context, index,animation) {
  //             var arrayOfPosts = arrayofTime.toList();
  //             return SizeTransition(
  //               sizeFactor: animation,
  //               child: Dismissible(
  //               movementDuration: Duration(milliseconds:30),
  //               resizeDuration: Duration(milliseconds: 60),
  //               dismissThresholds: {DismissDirection.endToStart : 0.8},
  //               background: Card(
  //                 color: Colors.red,
  //                 margin: index==0? EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 8.0)
  //                 : EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
  //                 elevation: 5.0,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16.0)
  //                 ),
  //                 // padding: EdgeInsets.symmetric(horizontal: 20),
  //                 // alignment: AlignmentDirectional.centerStart,
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: <Widget>[
  //                     Icon(
  //                       Octicons.trashcan,
  //                       color: Colors.white,
  //                     ),
  //                     SizedBox(width:15.0),
  //                     Text(
  //                       'Remove from Bookmarks',
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 18.0
  //                       ),
  //                     ),
  //                   ], 
  //                 ), 
  //               ),
  //               direction: DismissDirection.endToStart,
  //               key: Key(bookmarkArray[index].id),
  //               onDismissed:(direction)async{
  //                 _bookmarkKey.currentState.removeItem(index, 
  //                   (BuildContext context,Animation<double> animation){
  //                     return Container();
  //                 });
  //                 setState(() {
  //                   if(arrayofTime.toList().length == 1){
  //                     _noPost = true;
  //                   }
  //                 });
  //                 return await dismiss(bookmarkArray, index);
  //               },
  //               // confirmDismissDialog(),
  //               child: arrayOfPosts[index]
  //             ),
  //             );
  //           }
  //         ):Container(
  //           // alignment: Alignment.bottomCenter,
  //           // height: MediaQuery.of(context).size.height *0.4,
  //           child: Center(
  //             child: Text('You have not bookmarked any post'),
  //           ),
  //         ),
    // );
  }
  dismiss(postArray,index) async{
    // setState(() {
        // postArray[index].bookmark = false;
                   
    //  });
  //   //  DataHolderAndProvider.of(context).data.value.globalPostMap[bookmarkArray[index].id].bookmark = false ;
  //    DataHolderAndProvider.of(context).data.value.globalPostsArray.firstWhere((test) => test.id == bookmarkArray[index].id).bookmark = false ;
  //    DataHolderAndProvider.of(context).data.refresh();
     await DBProvider().updateQuery(GetPosts(queryColumn: 'bookmark', queryData: 0,id:postArray[index].id));
     try {
             bookmarkArray.removeAt(index); 
             postArray.removeAt(index); 
           } catch (e) {
             print(e);
           }   
  //    var ind = bookmarkArray.indexWhere((test) => test.id == postArray[index].id);
  //   if(ind!=-1){
      
      // arrayofTime.toList().removeAt(index);
      // bookmarkArray.removeAt(index);
      
  //   }
    
  //   // DataHolderAndProvider.of(context).data.value.globalPostsArray.indexWhere((test)=>test.id == );
  //   // printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: postArray[index].id)));
    // return await Future.delayed(Duration(milliseconds: 50),()=>true);
    return true;
  }
  // Widget tile(index, time,List<PostsSort>postArray) {
  //   postArray = postArray.reversed.toList(); 
  //   return Card(
  //     elevation: 5.0,
  //     margin: EdgeInsets.symmetric(vertical: 10.0),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  //     child: InkWell(
  //       borderRadius: BorderRadius.circular(16.0),
  //       onTap: () {
  //         return Navigator.of(context)
  //             .push(MaterialPageRoute(builder: (BuildContext context) {
  //           return FeatureDiscovery(child: PostDescription(listOfPosts: postArray, type: 'bookmarks',index: index,));
  //         }));
  //       },
  //       child: Stack(
  //         children: <Widget>[
  //         //   Positioned(
  //         //     bottom: 15.0,
  //         //     right: 0.0,
  //         //         child: IconButton(
  //         //           tooltip: 'Save Post',
  //         //           icon: postArray[index].bookmark?Icon(
  //         //             MaterialIcons.bookmark
  //         //           ): Icon(MaterialIcons.bookmark_border),
  //         //           onPressed: ()async{
  //         //             setState(() {
  //         //               postArray[index].bookmark = !postArray[index].bookmark;
                        
  //         //             });
  //         //             await DBProvider().updateQuery(GetPosts(queryColumn: 'bookmark', queryData: (postArray[index].bookmark?1:0),id:postArray[index].id));
  //         //             if(postArray[index].bookmark ==true){
  //         //               showSuccessToast('Bookmarked');
  //         //             }else{
  //         //               var ind = bookmarkArray.indexWhere((test) => test.id == postArray[index].id);
  //         //               if(ind!=-1){
  //         //                 bookmarkArray.removeAt(index);
  //         //                 showRemove
  //         //               }
  //         //               // showInfoToast('Removed From Saved');
  //         //             }
  //         //             printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: postArray[index].id)));
  //         //           }),
  //         // ),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               Container(
  //                 padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
  //                 child: AutoSizeText(
  //                   // timenot['club'],
  //                     postArray[index].sub,
  //                     // 'Science and Texhnology Council',
  //                     textAlign: TextAlign.start,
  //                     style: TextStyle(
  //                       color: Theme.of(context).brightness == Brightness.light
  //                           ? Colors.blueGrey
  //                           : Colors.white70,
  //                       // fontWeight: FontStyle.italic,
  //                       fontSize: 10.0,
  //                     )),
  //               ),
  //               Container(
  //                 // alignment: Alignment.center,
  //                 padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
  //                 child: AutoSizeText(postArray[index].title,
  //                     // 'Sit commodo fugiat duis consectetur sunt ipsum cupidatat adipisicing mollit et magna duis.',
  //                     minFontSize: 15.0,
  //                     overflow: TextOverflow.ellipsis,
  //                     maxLines: 2,
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 17.0,
  //                     )),
  //               ),
  //               Container(
  //                 padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
  //                 constraints: BoxConstraints(
  //                   maxWidth: MediaQuery.of(context).size.width - 84.0,
  //                 ),
  //                 child: AutoSizeText(
  //                   // timenot['message'],
  //                   postArray[index].message,
  //                   // 'Dolor consectetur in dolore anim reprehenderit velit pariatur veniam nostrud id ex exercitation.',
  //                   maxLines: 2,
  //                   style: TextStyle(
  //                     fontSize: 12.0,
  //                     color: Theme.of(context).brightness == Brightness.light
  //                         ? Colors.grey[850]
  //                         : Colors.white70,
  //                   ),
  //                 ),
  //               ),
  //               Container(
  //                   padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 5.0),
  //                   alignment: Alignment.bottomRight,
  //                   child: Text(
  //                     time,
  //                     style: TextStyle(
  //                       fontSize: 8.0,
  //                       color: Theme.of(context).brightness == Brightness.light
  //                           ? Colors.grey
  //                           : Colors.white70,
  //                     ),
  //                   )),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Future<bool>loadBookMarks()async{
    // _load = true;
    return await DBProvider().getAllPostswithQuery(GetPosts(queryColumn: 'bookmark', queryData: 1),type: 'bookmark',orderBy: 'timeStamp DESC').then((var v){
      print('bookmarkpost' +'$v');
      if(v!=null && v.length !=0){
        bookmarkArray = v;
        setState(() {
          _noPost = false;
          _load = false;
        });
        return true;
      }else{
        setState(() {
          _noPost = true;
          _load = false;
        });
        return true;
      }
    });
  }

}