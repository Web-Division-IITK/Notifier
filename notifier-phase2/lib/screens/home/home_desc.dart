// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:frideos/frideos.dart';
// import 'package:intl/intl.dart';
// import 'package:notifier/database/reminder.dart';
// import 'package:notifier/model/notification.dart';
// import 'package:notifier/model/posts.dart';
// import 'package:notifier/screens/all_posts.dart';
// import 'package:notifier/screens/home.dart';
// import 'package:notifier/screens/home/ongoing_events.dart';
// import 'package:notifier/screens/home/upcoming_events.dart';
// import 'package:notifier/screens/posts/post_desc.dart';
// import 'package:notifier/screens/posts/post_list.dart';
// import 'package:notifier/services/database.dart';
// import 'package:notifier/services/functions.dart';
// import 'package:notifier/services/inherited_widget.dart';
// import 'package:notifier/widget/showtoast.dart';

// // class HomePostDescription extends StatefulWidget {
// //   final List<PostsSort> globalPostsArray;
// //   final dynamic prefs;
// //   final String userID;
// //   HomePostDescription(this.globalPostsArray,this.prefs,this.userID);
// //   @override
// //   _HomePostDescriptionState createState() => _HomePostDescriptionState();
// // }

// // class _HomePostDescriptionState extends State<HomePostDescription> {
// //   // List<PostsSort> globalPostsArray= [];
  
// //   @override
// //   Widget build(BuildContext context) {
// //     var data = DataHolderAndProvider.of(context).data.value;
// //     // globalPostsArray = data.globalPostsArray;
// //     return /*DataHolderAndProvider(
// //       data: DataHolderAndProvider.of(context).data,
// //       child: StreamedWidget(
// //         stream: DataHolderAndProvider.of(context).data.outStream, 
// //       builder: (context,sn){
// //         return */HomeDescription(
// //           data.globalPostsArray,
// //           data.prefs,
// //           widget.userID
// //         );
// //     //   }
// //     // ),
// //     // );
// //   }
// // }


// class HomeDescription extends StatefulWidget {
//   final List<PostsSort> arrayWithPrefs;
//   final dynamic prefs;
//   final String userID;
//   HomeDescription({key:Key,this.arrayWithPrefs,this.prefs,this.userID}):super(key:key);
//   @override
//   _HomeDescriptionState createState() => _HomeDescriptionState();
// }

// class _HomeDescriptionState extends State<HomeDescription> {

// // List<PostsSort> widget.arrayWithPrefs= [];
// // List<PostsSort> globalPostsArray= [];
// bool _noPost = false;
// List<PostsSort> ongoing = [];
// List<PostsSort> upcoming = [];
// List<PostsSort> clubPostsMap = [];
// bool _load1 = false;
// bool _load2 = false;
// bool _load = false;
// @override
// void initState() { 
//   if(widget.arrayWithPrefs == null || widget.arrayWithPrefs.length == 0){
//     setState(() {
//       _noPost = true;
//     });
//   }
//   setState(() {
//     _load1 = true;
//     _load2 = true;
//     _load = true;
//   });
  
//   // globalPostsArray = [];
//   // globalPostsArray = DataHolderAndProvider.of<List<SortDateTime>>(context);
//   // data.refresh();
//   super.initState();
//   // List.
//   // List.generate(1, (int index){
//   //   widget.globalPostsArray.forEach((f){
//   //     if(widget.prefs.contains(f.sub)){
//   //       // arrayWithclub = updateDataInList(arrayWithclub, f);
//   //       return f;
//   //     }
//   //   });

//   // },growable:true);
  
// }

//   // Iterable<PostsSort> get arrayofTime sync*{
    
//     // widget.globalPostsArray.forEach((f){
//     //   if(widget.prefs.contains(f.sub)){
//     //     // arrayWithclub.add(f);
//     //     yield f;
//     //     // yield clubPostsMap = updateDataInList(clubPostsMap,f);
//     //   }else if(f.reminder == true){
//     //     DatabaseProvider().deletePost(f.id);
//     //   }
//     // });
//     // for(var i in widget.globalPostsArray){
//     //   if(widget.prefs.contains(i.sub)){
//     //     yield i;
//     //   }else if(i.reminder == true){
//     //     DatabaseProvider().deletePost(i.id);
//     //   }
//     // }
//     // if (clubPostsMap.length == 0) {
//     //   clubPostsMap=[];
//     // }
//     // yield arrayWithclub = clubPostsMap.toList();
//     // if( arrayWithclub==null || arrayWithclub.length==0){
//     //     yield Container(
//     //       height: 100.0,
//     //       child: Center(
//     //       child: Text(
//     //         'No posts exists right now'
//     //       ),
//     //     ),);
        
//     // }
//     // else{
//     //   var length = (arrayWithclub.length<3)? arrayWithclub.length: 3;
//     //    for (var j = 0 ;j< (length);j++) {
      
//     //     var i= arrayWithclub[j];
//     //     // DateTime postTime = DateTime.parse(i.value['timeStamp']);
//     //     DateTime postTime = DateTime.fromMillisecondsSinceEpoch(i.timeStamp);
//     //     var time;var day;
//     //     // var dayTime = DateFormat('d mm yyyy').format;
//     //     if (DateTime.now().day == postTime.day && DateTime.now().month == postTime.month && DateTime.now().year == postTime.year) {
//     //       if (DateTime.now().hour == postTime.hour || (DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) < 3600000) {
//     //         switch (DateTime.now().minute - postTime.minute) {
//     //           case 0:
//     //             time = 'now';
//     //             day = 'Today';
//     //           break;
//     //           default:
//     //             var i = ((DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) /60000).round();
//     //             time = '$i minutes ago';
//     //             day = 'Today';
//     //         }
//     //       } else {
//     //         time = DateFormat('hh:mm a,').format(postTime);
//     //         day = 'Today';
//     //       }
//     //     } else {
//     //         time = DateFormat('hh:mm a,d MMMM, yyyy').format(postTime);
//     //         day = DateFormat('d MMMM, yyyy').format(postTime);
//     //     }
//     //     switch(i.dateAsString){
//     //       case 'Today':{
//     //         if (arrayWithclub.firstWhere((test){
//     //           return (test.dateAsString == 'Today' )?
//     //           true : false;
//     //         }) == i) {
//     //           yield Column(
//     //             children: <Widget>[
//     //               Container(child: Text('Today'),),
//     //                 Container(
//     //                     // margin: const EdgeInsets.symmetric(horizontal: 16.0),
//     //                     child: tile(arrayWithclub.indexOf(i) , time),
//     //                   )
//     //             ],
//     //           );
//     //         } else {
//     //           yield Container(
//     //                     // margin: const EdgeInsets.symmetric(horizontal: 16.0),
//     //                     child: tile(arrayWithclub.indexOf(i) , time),
//     //                 );
//     //         }
//     //       } 
//     //         break;
//     //       case 'Yesterday' : {
//     //         if (arrayWithclub.firstWhere((test){
//     //           return (test.dateAsString == 'Yesterday')?true:false;
//     //         }) == i) {
//     //           yield Column(
//     //             children: <Widget>[
//     //               Container(child: Text('Yesterday'),),
//     //                 Container(
//     //                     // margin: const EdgeInsets.symmetric(horizontal: 16.0),
//     //                     child: tile(arrayWithclub.indexOf(i) , time),
//     //                   )
//     //             ],
//     //           );
//     //         } else {
//     //           yield Container(
//     //                     // margin: const EdgeInsets.symmetric(horizontal: 16.0),
//     //                     child: tile(arrayWithclub.indexOf(i) , time),
//     //                   );
//     //         }
//     //       }
//     //         break;
//     //       default: if (arrayWithclub.firstWhere((test){
//     //         return (test.dateAsString == day)?true:false;
//     //       }) == i) {
//     //         yield Column(
//     //             children: <Widget>[
//     //               Container(child: Text(day),),
//     //                 Container(
//     //                     // margin: const EdgeInsets.symmetric(horizontal: 16.0),
//     //                     child: tile(arrayWithclub.indexOf(i) , time),
//     //                   )
//     //             ],
//     //           );
//     //       } else {
//     //         yield Container(
//     //                     // margin: const EdgeInsets.symmetric(horizontal: 16.0),
//     //                     child: tile(arrayWithclub.indexOf(i) , time),
//     //                   );
//     //       }
//     //       break;
//     //     } 
//     //   }
//     // }
//   // }
//   void loadUpcominganOnGOing(List<PostsSort>arrayWithclub)async{
//     // await Future.sync(computation)
//     ongoing = [];
//     upcoming = [];
//     for (var i in arrayWithclub) {
//       if(i.reminder == true && i.endTime!=0){
//         var endTime = DateTime.fromMillisecondsSinceEpoch(i.endTime);
//         var startTime = DateTime.fromMillisecondsSinceEpoch(i.startTime);
//         if(checkDateisBetween(startTime, endTime,i )){
//           upcoming.add(i);
//         }
//         else if(checkDateForONisBetween(startTime, endTime, i)){
//           ongoing.add(i);
//         }
//       }
      
//     }
//     await Future.delayed(Duration(milliseconds: 80),(){
//       // print('232');
//       setState(() {
//         _load1 = false;
//         _load2 = false;
//       });
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     var pass = DataHolderAndProvider.of(context).data;
//     var data = DataHolderAndProvider.of(context).data.value;
//     // globalPostsArray = data.globalPostsArray;
//     // loadArray(context);
//     // arrayofTime.toList();
//     loadUpcominganOnGOing(widget.arrayWithPrefs);
    
//     return Container(
//       // padding: EdgeInsets.all(16.0),
//       child: SafeArea(
//         child: ListView(
//           padding:EdgeInsets.all(16.0),
//           children: <Widget>[
//             // TableRow(
//             //   children: [
//                 Text(
//                   "On Going Event",
//                   style: TextStyle(
//                     fontSize: 20.0
//                   )
//                 ),
//               // ]
//             // ),
//             // TableRow(
//               // children: [
//                 Container(
//                   padding: EdgeInsets.only(top:16.0,),
//                   constraints: BoxConstraints(
//                     minHeight: 100.0,
//                     maxHeight: 500.0
//                   ),
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16.0)
//                     ),
//                     child: _load1?Container(
//                       height: 80.0,
//                       child: Center(child: CircularProgressIndicator()),
//                     ) :
//                     OnGoingEvent(
//                       SendToChildren(
//                         globalPostsArray: (ongoing == null ||ongoing.length ==0 )? []:ongoing)),
//                   )
//                 ),
//               // ]
//             // ),
//             // TableRow(
//               // children:[
//                 Padding(
//                   padding: const EdgeInsets.only(top:16.0),
//                   child: Text(
//                     "Latest Posts",
//                     style: TextStyle(
//                       fontSize: 20.0
//                     ),
//                   ),
//                 ),
//               // ]
//             // ),
//             // TableRow(
//               // children: <Widget>[
//                 Container(
//                   padding: EdgeInsets.only(top:16.0,bottom:16.0),
//                   constraints: BoxConstraints(
//                     minHeight: 100.0
//                   ),
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16.0)
//                   ),
//                     child: _noPost || widget.arrayWithPrefs == null || widget.arrayWithPrefs.length ==0?
//                     Container(
//                       height:80.0,
//                       child: Center(
//                         child: Text('No post is currently available to show'),
//                       ),
//                     ):
//                     Stack(
//                       // fit: StackFit.expand,
//                       children: <Widget>[
//                         Center(
//                           child: Container(
//                             padding: EdgeInsets.all(16.0),
//                             margin: EdgeInsets.only(bottom:16.0),
//                             child: _load?
//                             Center(child: CircularProgressIndicator(),):
//                             ListView.builder(
//                               physics: NeverScrollableScrollPhysics(),
//                               shrinkWrap: true,
//                               itemCount: widget.arrayWithPrefs.length,
//                               itemBuilder: (context,index){
//                                 var i =widget.arrayWithPrefs.toList()[index];
//                                 // return widget.arrayWithPrefsfirstWhere((test)=>test.dateAsString == 'Today')

//                                 // }
//                                 // (
//                                 // );
//                               }
//                             ),
//                             // child: Column(
//                             //   children: <Widget>[
//                             //     ...arrayofTime.toList(),
                                
//                             //   ],
//                             // ),
//                           ),
//                         ),
//                         Positioned(
//                           // alignment: Alignment.bottomRight,
//                           bottom:0.0,
//                           right:0.0,
//                           child: Padding(
//                             padding: const EdgeInsets.only(top:16.0),
//                             child: CupertinoButton(
//                                   onPressed: (){
//                                     Navigator.of(context).push(MaterialPageRoute(
//                                         builder: (BuildContext context) {
//                                           return DataHolderAndProvider(
//                                             child: StreamedWidget(
//                                               stream: pass.outStream, 
//                                             builder: (context,snapshot) => AllPostGetData()
//                                           ),
//                                           data:  pass,
//                                     );}));
//                                   },
//                                   child: Text('See All ...',
//                                     style: TextStyle(
//                                       fontSize: 12.0
//                                     )
//                                   )
//                               ),
//                           ),
//                         )
//                       ],
//                     )
//                   ),
//                 // )
//               // ]
//             ),
//             // TableRow(
//               // children: <Widget>[
//                 Text(
//                   "Upcoming Events",
//                   style: TextStyle(
//                     fontSize: 20.0
//                   ),
//                 ),
//               // ]
//             // ),
//             // TableRow(
//               // children: <Widget>[
//                 Container(
//       // height:0.0,
//                   padding: EdgeInsets.only(top:16.0,bottom:16.0),
//                     constraints: BoxConstraints(
//                       minHeight: 100.0
//                     ),
//                   child: Card(
//                     // elevation:2.0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16.0)
//                     ),
//                     child:_load2?Container(
//                       height: 80.0,
//                       child: Center(child: CircularProgressIndicator()),
//                     ) :
//                     UpcomingEvents(
//                       array: (upcoming == null ||upcoming.length ==0 )? []:upcoming
//                     ),
//                   )
//                 )
//               // ]
//             // ),
//           ],
//         )
//       ),
//     );
//   }
//   // void loadArray(context){
      
//   //   // DataHolderAndProvider().data.stream.
//   //   // Future.delayed(Duration(seconds: 2),(){
//   //   //   // DataHolderAndProvider().data.outStream.listen((onData){
//   //   //   DataHolderAndProvider().data.onChange((onDataChanged){
//   //   //     setState(() {
          
//   //   //     });
//   //   //   // });
//   //   // });
//   //   // });

//   // }
//   _navigateToPostDesc(context,index)async {
//     final result  = await Navigator.of(context)
//               .push(MaterialPageRoute(builder: (BuildContext context) {
//             return PostDescription(listOfPosts: widget.arrayWithPrefs, type: 'display',index: index,);
//       }
//     ));
//     if( result!=null &&result == 'reload'){
//       print(result);
//       setState(() {
//         // build(context);
//         //  loadArray(context);
//         loadUpcominganOnGOing(widget.arrayWithPrefs);
//       });
//     }
//   }
//   Widget tile(index, time) { 
//     // print(timenot);
//     return Card(
//       elevation: 5.0,
//       margin: EdgeInsets.symmetric(vertical: 10.0),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16.0),
//         onTap: () {
//           // return 
//             _navigateToPostDesc(context, index);
//         },
//         child: Stack(
//           children: <Widget>[
//             Positioned(
//               bottom: 15.0,
//               right: 0.0,
//                   child: IconButton(
//                     tooltip: 'Save Post',
//                     icon: widget.arrayWithPrefs[index].bookmark?Icon(
//                       MaterialIcons.bookmark
//                     ): Icon(MaterialIcons.bookmark_border),
//                     onPressed: ()async{
//                       setState(() {
//                         widget.arrayWithPrefs[index].bookmark = !widget.arrayWithPrefs[index].bookmark;
                        
//                       });
//                       // DataHolderAndProvider.of(context).data.value.globalPostMap[widget.arrayWithPrefs[index].id].bookmark = false ;
//                       // DataHolderAndProvider.of(context).data.value.globalPostsArray.firstWhere((test) => test.id == widget.arrayWithPrefs[index].id).bookmark = false ;
//                       // DataHolderAndProvider.of(context).data.refresh();
//                       await DBProvider().updateQuery(GetPosts(queryColumn: 'bookmark', queryData: (widget.arrayWithPrefs[index].bookmark?1:0),id:widget.arrayWithPrefs[index].id));
//                       if(widget.arrayWithPrefs[index].bookmark ==true){
//                         showSuccessToast('Bookmarked');
//                       }else{
//                         // showInfoToast('Removed From Saved');
//                       }
//                       printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: widget.arrayWithPrefs[index].id)));
//                     }),
//           ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Container(
//                   padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
//                   child: Hero(
//                     tag: 'club' + index.toString(),
//                     child: AutoSizeText(
//                       // timenot['club'],
//                         widget.arrayWithPrefs[index].sub,
//                         // 'Science and Texhnology Council',
//                         textAlign: TextAlign.start,
//                         style: TextStyle(
//                           color: Theme.of(context).brightness == Brightness.light
//                               ? Colors.blueGrey
//                               : Colors.white70,
//                           // fontWeight: FontStyle.italic,
//                           fontSize: 10.0,
//                         )),
//                   ),
//                 ),
//                 Container(
//                   // alignment: Alignment.center,
//                   padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
//                   child: Hero(
//                     tag: 'title' + index.toString(),
//                     child: AutoSizeText(widget.arrayWithPrefs[index].title,
//                         // 'Sit commodo fugiat duis consectetur sunt ipsum cupidatat adipisicing mollit et magna duis.',
//                         minFontSize: 15.0,
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 2,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 17.0,
//                         )),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width - 116.0,
//                   ),
//                   // decoration: BoxDecoration(
//                   //   border: Border.all(
//                   //     color: Colors.black
//                   //   )
//                   // ),
//                   child: AutoSizeText(
//                     // timenot['message'],
//                     widget.arrayWithPrefs[index].message,
//                     // 'Dolor consectetur in dolore anim reprehenderit djhbjdhsbvelit pariatur veniam nostrud id ex exercitation.',
//                     maxLines: 2,
//                     style: TextStyle(
//                       fontSize: 12.0,
//                       color: Theme.of(context).brightness == Brightness.light
//                           ? Colors.grey[850]
//                           : Colors.white70,
//                     ),
//                   ),
//                 ),
//                 Container(
//                     padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 5.0),
//                     alignment: Alignment.bottomRight,
//                     child: Text(
//                       time,
//                       style: TextStyle(
//                         fontSize: 8.0,
//                         color: Theme.of(context).brightness == Brightness.light
//                             ? Colors.grey
//                             : Colors.white70,
//                       ),
//                     )),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }