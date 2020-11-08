import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/posts/post_desc.dart';

// class UpcomingEvents extends StatefulWidget {
//   final List<PostsSort> array;
//   UpcomingEvents({@required this.array});
//   @override
//   _UpcomingEventsState createState() => _UpcomingEventsState();
// }

// class _UpcomingEventsState extends State<UpcomingEvents> {
//   final GlobalKey<AnimatedListState> _eventKey = GlobalKey<AnimatedListState>();
//   bool _noPost = false;
//   List<PostsSort> array =[];
//   Timer _timer;
//   @override
//   void initState() { 
//     super.initState();
//     loadFromDatabase();
//     // loadUpcomingEvents();
//     _timer = Timer(Duration(minutes: 5), 
//       (){
//         setState(() {
//           loadUpcomingEvents();
//         });
//       }
//     );
//   }
//   refresh(){
//     setState(() {
//       loadUpcomingEvents();
//     });
//   }
//   @override
//   void dispose() { 
//     _timer.cancel();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container( 
//       child:_noPost||array.length==0?
//         Container(
//           height: 80.0,
//           child: Center(
//             child: Text('You have no upcoming events right now'),
//           ),
//         ):
//         Stack(
//           children: <Widget>[
//            Center(
//              child: Container(
//               //  padding: EdgeInsets.(16.0),
//                margin: EdgeInsets.only(bottom:40.0,top:16.0),
//                child: AnimatedList(
//                  shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 key: _eventKey,
//                 initialItemCount: (array.length <3 && array.length!=0)? array.length:3,
//                 itemBuilder: (context,index,animation){
//                   // PostsSort postsSort = widget.array[index];
//                   return array.length == 0?
//                   Container(
//                     child: Center(
//                       child: Text('You have no upcoming events right now'),
//                     ),
//                   )
//                   :ListItem(
//                     load: refresh, 
//                     postsList: array, 
//                     index: index, 
//                     eventKey: _eventKey);
//                 },
//                ),
//              ),
//             ),
//             Positioned(
//               bottom:0.0,
//               right:0.0,
//               child: Padding(
//                 padding: const EdgeInsets.only(top:16.0),
//                 child: CupertinoButton(
//                   onPressed: (){
//                     Navigator.of(context).push(MaterialPageRoute(
//                       builder: (BuildContext context) {
//                         return UpcomingEventsPage(
//                           array: array,
//                           load: refresh,
//                         // child:  pass,
//                         );}));
//                   },
//                   child: Text('See All ...',
//                     style: TextStyle(
//                       fontSize: 12.0
//                     )
//                   )
//                 ),
//               ),
//             )
//           ],
//         ),
//       // ),
//     );
//   }
//   loadFromDatabase()async{
//     await DatabaseProvider().getAllPosts().then((list){
//       if(list.isNotEmpty){
//         array = list;
//         loadUpcomingEvents();
//         if(mounted){
//           setState(() {
          
//         });
//         }
//       }
//       else{
//         array =[];
//       }
//     });
//   }
  
//   Future loadUpcomingEvents()async{
//     // widget.array.sort((,b)=> a.date.compareTo(b.date));
//     if(widget.array.length == 0){
//       print('No events right now');
//       return  'No events right now';
//     }
//     else{
//       for (var i in widget.array) {
//         if(i.reminder == true){
//           var startTime = DateTime.fromMillisecondsSinceEpoch(i.startTime);
//           DateTime endTime= DateTime.fromMillisecondsSinceEpoch(i.endTime);
//           if(checkDateisBetween(startTime,endTime,i)){
//             // Duration duration = startTime.difference(DateTime.now());
//             // setState(() {
//               array.add(i);
//             // });
//           }
//           else if(endTime.isBefore(DateTime.now())){
//             DatabaseProvider().deletePost(i.id);
//           }
//           else{
//             // setState(() {
//               array.removeWhere((test) => test.id == i.id);
//             // });
//           }
//           }
//       } 
//     }
//   }
  
// }
bool checkDateisBetween(DateTime startTime,DateTime endTime, Posts posts){
    // final time = convertDateToString(startTime).toLowerCase();
    // var now = DateTime.now();
    var today = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
    var tomrw = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+1);
    var aDate = DateTime(startTime.year,startTime.month,startTime.day);

    // print(time);
    if(( true||today == aDate|| aDate == tomrw) 
        && startTime.isAfter(DateTime.now()) && endTime.isAfter(DateTime.now())){
          print('dateisBe');
      return true;
    }
    else{
       print('dateisBe72');
      return false;
    }
  }

class UpcomingEventsPage extends StatefulWidget {
  // final Function load;
  // final Stream stream;
  // final List<posts> array;
  // UpcomingEventsPage({@required this.array,@required this.load});
  @override
  _UpcomingEventsPageState createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> with AutomaticKeepAliveClientMixin<UpcomingEventsPage> {
  final GlobalKey<AnimatedListState> _upcomingKey = GlobalKey<AnimatedListState>();
  List<Posts> array = [];
  // StreamController streamController = StreamController.broadcast();
  // StreamSubscription streamSubscription;
  @override
  bool get wantKeepAlive => true;

  Future<void>refresh(){
    return Future.delayed(Duration(seconds: 2),()=>setState(() {}));
  }
  // @override
  // void initState() { 
  //   super.initState();
  //   streamController.addStream(Stream.periodic(Duration(minutes: 1)));
    
  // }
  // @override
  // void dispose() {
  //   // streamSubscription.cancel();
  //   streamController.close();
  //   super.dispose();
  // }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Events'),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top,
        child: RefreshIndicator(
          onRefresh: refresh,
          child: Container(
            height: MediaQuery.of(context).size.height - 88,
            child: FutureBuilder(
              future: DatabaseProvider().getAllPostsForUpcomingEvents(),
              builder: (context,AsyncSnapshot<List<Posts>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if(snapshot == null || snapshot.data == null || snapshot.data.length ==0){
                      // streamController.close();
                      return Container(
                        height: MediaQuery.of(context).size.height*0.8,
                        // height: double.maxFinite,
                        child: Center(child: Text('No upcoming events right now')),
                      );
                    }else{
                      // if(streamController.isClosed){
                      //   streamController.addStream(Stream.periodic(Duration(minutes: 1)));
                      // }
                      // LiquidPullToRefresh(
                      //   showChildOpacityTransition: false,
                      //   onRefresh: ()async{
                      //     refresh();
                      //   },
                      return SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          // itemExtent: MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top,
                          // shrinkWrap: true,
                          // padding: EdgeInsets.symmetric(vertical: 16.0),
                          children: <Widget>[
                           ( snapshot.data == null ||snapshot.data.length == 0)?
                            Container(
                              height: MediaQuery.of(context).size.height*0.8,
                              // height: double.maxFinite,
                              child: Center(child: Text('No upcoming events right now')),
                            ):
                            AnimatedList(
                              shrinkWrap: true,
                              key: _upcomingKey,
                              physics: NeverScrollableScrollPhysics(),
                              initialItemCount: snapshot.data.length ,
                              itemBuilder: (context,index,animation){
                                // index =0;
                                return SizeTransition(
                                  sizeFactor: animation,
                                  child: 
                                  (snapshot.data == null ||snapshot.data.length == 0)?
                                  Container(
                                    child: Center(child: Text('No upcoming events right now')),
                                  ):
                                  StreamBuilder(
                                    stream: Stream.periodic(Duration(minutes: 1)),
                                    builder: (context, snapsht) {
                                      return ListItem(
                                        key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                                        postsList: snapshot.data,
                                        // array: snapshot.data,
                                        load: refresh,
                                        eventKey: _upcomingKey,
                                        index: index, 
                                      );
                                    }
                                  ), 
                                );
                              }
                            ),
                          ],
                        ),
                      );
                    }
                    break;
                  default: return Container(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              }
            ),
          ),
        ),
      ),
    );
  }
   Future<List<Posts>> _fetchData()async{
    return await DatabaseProvider().getAllPostsForUpcomingEvents().then((list){
      print(list);
      if(list == null || list.length == 0){
        return [];
      }
      else return list;
      // Future.microtask((){
      //   list.retainWhere((test)=> checkDateForONisBetween(
      //     DateTime.fromMillisecondsSinceEpoch(test.startTime), 
      //     DateTime.fromMillisecondsSinceEpoch(test.endTime),test));
      //   return Future.delayed(Duration(milliseconds: 10),()=>list);
      // });
    });
  } 
}
class ListItem extends StatefulWidget {
  final Function load;
  final List<Posts> postsList;
  final int index;
  final GlobalKey<AnimatedListState> eventKey;
  // final StreamController streamController;
  ListItem({Key key,@required this.load,@required this.postsList,@required this.index,@required this.eventKey/*, @required this.streamController*/}) : super(key: key);
  
  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  var minutes;
  Posts posts;
  // StreamSubscription subscription;
  @override
  void initState() {
    super.initState();
    posts = widget.postsList[widget.index];
    var date = DateTime.fromMillisecondsSinceEpoch(posts.startTime);
    // DateTime endTime= convertDateFromStringToDateTime(posts.endTime);
    minutes = date.difference(DateTime.now());
    // subscription = widget.streamController.stream.listen((onData){
      if(minutes == 0){  
          // setState(() {
            // timer.cancel();
            // subscription.cancel();
          // });
          widget.eventKey.currentState.removeItem(widget.index, 
            (context,animation){
              if(widget.postsList.length == 1&& widget.index == 0){  
                // widget._eventKey.currentState.widget.createState();  
                // widget.array.removeAt(widget.index);                      
                return Container(
                  child: Text('No posts available right now'),
                );
              }
              else{
                // widget._eventKey.currentState.widget.createState();  
                // widget.array.removeAt(widget.index); 
                return Container();
              }
              
            }
          );
          // widget.load();
        }else{
          setState(() {
            minutes = minutes - Duration(minutes: 1);
          });
        }
    // });
    // _timer = Timer.periodic(
    //   Duration(minutes:1), (timer){
    //     if(minutes == 0){  
    //       setState(() {
    //         timer.cancel();
    //       });
    //       widget.eventKey.currentState.removeItem(widget.index, 
    //         (context,animation){
    //           if(widget.postsList.length == 1&& widget.index == 0){  
    //             // widget._eventKey.currentState.widget.createState();  
    //             // widget.array.removeAt(widget.index);                      
    //             return Container(
    //               child: Text('No posts available right now'),
    //             );
    //           }
    //           else{
    //             // widget._eventKey.currentState.widget.createState();  
    //             // widget.array.removeAt(widget.index); 
    //             return Container();
    //           }
              
    //         }
    //       );
    //       widget.load();
    //     }else{
    //       setState(() {
    //         minutes = minutes - Duration(minutes: 1);
    //       });
    //     }
    //   });
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0)
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: (){
          return Navigator.of(context).push(
            MaterialPageRoute(builder: (context){
              return FeatureDiscovery(child: PostDescription(listOfPosts: widget.postsList, type: PostDescType.REMINDER));
            })
          ).then((value) => widget.load()??{});
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
          ),
          width: double.maxFinite,
          constraints: BoxConstraints(
            minHeight: 100.0,
            // maxHeight: 90.0
          ),
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(posts.sub[0].toString(),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                              ? Colors.blueGrey
                              : Colors.white70,
                    fontSize: 10.0,
                  ),
                ),
                SizedBox(height:  5),
                Text(posts.title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height:10.0
                ),
                Wrap(
                  children: <Widget>[
                    Text('Starts in :'),
                     SizedBox(
                      width:5.0
                    ),
                    // Text(minutes.toString()),
                    Text(convertToMinAndHours(minutes.inMinutes))
                  ],
                ),
               
            ],
          ),
        )
      ),
    );
  }
}

convertToMinAndHours(minutes){
  var v = '';
  switch ((((minutes/60).floor())/24).floor()) {
    case 0: v = '';
      break;
    case 1: v= '1 day ';
      break;
    default: v= "${(((minutes/60).floor())/24).floor()} days ";
  }
  switch((minutes/60).floor()) {
    case 0:  v += '';
      break;
    case 1: v += '1 hour ';
      break;
    default: v +='${(minutes/60).floor()} hours ';
  }
  switch ((minutes%60).floor()) {
    case 0: return v;
      break;
    case 1: return ((v=='')? (v + '1 minute'): (v + 'and 1 minute'));
      break;
    default: return ((v=='')? (v + '${(minutes%60).floor()} minutes'): (v + 'and ${(minutes%60).floor()} minutes'));
  }
}