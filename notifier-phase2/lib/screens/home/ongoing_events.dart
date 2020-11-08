import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home/upcoming_events.dart';
import 'package:notifier/screens/posts/post_desc.dart';


checkDateForONisBetween(DateTime startTime,DateTime endTime,Posts posts){
  if(startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now())){
    return true;
  }else{
    print('false'+ 'loadingongoing' );
    return false;
  }
}

class OnGoingEventPage extends StatefulWidget {
  // final Function load;
  // // final List<posts> array;
  // final Stream stream;
  // OnGoingEventPage({@required this.stream,/*this.array*/});
  @override
  _OnGoingEventPageState createState() => _OnGoingEventPageState();
}

class _OnGoingEventPageState extends State<OnGoingEventPage> with AutomaticKeepAliveClientMixin<OnGoingEventPage>{

  final GlobalKey<AnimatedListState> oneventKey = GlobalKey<AnimatedListState>();
  List<Posts> array = [];
  // StreamController streamController = StreamController.broadcast();
  @override
  bool get wantKeepAlive => true;

  void callBack(){
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title:Text('Ongoing Events'),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context,AsyncSnapshot<List<Posts>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if(!(snapshot == null || snapshot.data == null || snapshot.data.length ==0)){
                  return RefreshIndicator(
                    onRefresh: ()async{
                      return callBack();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height - 88,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Center(child: Padding(
                      padding: EdgeInsets.only(top: (MediaQuery.of(context).size.height - 88)*0.45),
                          child: Text('No ongoing events right now'),
                        ))),
                    ),
                  );
                }else{
                  return RefreshIndicator(
                    onRefresh: ()async{
                      return callBack();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height - 88,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: list(snapshot))),
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
    );
  }
  Widget list(snapshot){
    return AnimatedList(
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: 16),
                            key: oneventKey,
                            physics: NeverScrollableScrollPhysics(),
                            initialItemCount: snapshot.data.length,
                            itemBuilder: (context,index,animation){
                              // index =0;
                              return SizeTransition(
                                sizeFactor: animation,
                                child: 
                                (snapshot.data == null ||snapshot.data.length == 0)?
                                Container(
                                  child: Center(child: Text('No ongoing events right now')),
                                ):
                                StreamBuilder(
                                  stream: Stream.periodic(Duration(minutes: 1)),
                                  builder: (context, snapsht) {
                                    return ListItemOnGoing(
                                      // streamController:streamController,
                                      post: snapshot.data[index],
                                      array: snapshot.data,
                                      callBack: callBack,
                                      eventKey: oneventKey,
                                      index: index, 
                                    );
                                  }
                                ), 
                              );
                            }
                          );
  }
  Future<List<Posts>> _fetchData()async{
    return await DatabaseProvider().getAllPostsForOngoingEvent().then((list){
      if(list == null || list.length == 0){
        return [];
      }
      else return list;
      // Future.microtask((){
      //   list.retainWhere((test)=> test.startTime < (DateTime.now().millisecondsSinceEpoch) && 
      //     test.endTime > DateTime.now().millisecondsSinceEpoch);
      //   return Future.delayed(Duration(milliseconds: 10),()=>list);
      // });
    });
  } 
  // loadONGoingEvent(){
  //   if(array.length == 0){
  //     print('No events right now');
  //     return  'No events right now';
  //   }
  //   else{
  //     for (var i in array) {
  //       var date = DateTime.fromMillisecondsSinceEpoch(i.startTime);
  //       DateTime endTime= DateTime.fromMillisecondsSinceEpoch(i.endTime);
  //       if(checkDateForONisBetween(date,
  //           endTime,i)){
  //           // var minutes = convertDateFromStringToDateTime(endTime).difference(DateTime.now());
          
  //         setState(() {
  //           array.add(i);
  //         });
  //       }
  //       else if(endTime.isBefore(DateTime.now())){
  //         DatabaseProvider().deletePost(i.id);
  //         array.removeWhere((test) => test.id == i.id);
  //         if(mounted){
  //           setState(() {
            
  //         });
  //         }
  //       }
  //       else{
  //         array.removeWhere((test) => test.id == i.id);
  //       }
  //   }
    
  //   }
  // }
}

class ListItemOnGoing extends StatefulWidget {
  final Posts post;
  final List<Posts> array;
  final GlobalKey<AnimatedListState> eventKey;
  // final StreamController streamController;
  final int index;
  final Function() callBack;
  ListItemOnGoing({Key key,this.post,this.array,this.eventKey,this.index,this.callBack/*,@required this.streamController*/}):super(key:key);
  @override
  _ListItemOnGoingState createState() => _ListItemOnGoingState();
}

class _ListItemOnGoingState extends State<ListItemOnGoing> {
Duration minutes;
// StreamSubscription streamSubscription;
// Timer _timer;
  @override
  void initState() {
    super.initState();
    DateTime.fromMillisecondsSinceEpoch(widget.post.startTime);
    DateTime endTime= DateTime.fromMillisecondsSinceEpoch(widget.post.endTime);
    minutes = DateTime.fromMillisecondsSinceEpoch(widget.post.endTime).difference(DateTime.now());
    // streamSubscription = widget.streamController.stream.listen((onData){
      updateWidget(endTime);
    // });
    // _timer = Timer.periodic(
    //   Duration(minutes:1), (timer){
        
      // });
  }
  // @override
  // void dispose() {
  //   super.dispose();
  //   // streamSubscription.cancel();
  //   // _timer.cancel();
  // }
  @override
  Widget build(BuildContext context) {
    // List<Posts> arrayw = [];
    // widget.array.forEach((f){
    //   arrayw.add(f.post);
    // });
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
              return FeatureDiscovery(child: PostDescription(listOfPosts: widget.array, type: PostDescType.REMINDER));
            })
          ).then((value) => widget.callBack());
        },
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
          ),
          constraints: BoxConstraints(
            minHeight: 100.0,
          ),
          padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(widget.post.sub[0].toString(),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                              ? Colors.blueGrey
                              : Colors.white70,
                    fontSize: 10.0,
                  ),
                ),
                SizedBox(height: 5),
                Text(widget.post.title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height:10.0
                ),
                Wrap(
                  children: <Widget>[
                    Text('Ends in :'),
                    SizedBox(
                      width:5.0
                    ),
                    // Text(minutes.toString()),
                    Text(convertToMinAndHours(minutes.inMinutes))
                  ],
                ),
                // Text(minutes.inSeconds.toString())
                
                // ((minutes.inMinutes/60).floor() == 0)?
                //   Text('${(minutes.inMinutes%60).floor()}' + ' minutes')
                //   :(((minutes.inMinutes%60).round() == 0) ?
                //     Text('${(minutes.inMinutes/60).floor()}' ' hours'):
                //     Text('${(minutes.inMinutes/60).floor()}' ' hours and ' + '${(minutes.inMinutes%60).floor()}' + ' minutes')
                //   )
            ],
          )
        ),
      ),
    );
  }

  void updateWidget(endTime){
    if(endTime.isBefore(DateTime.now())){  
          // setState(() {
            // streamSubscription.cancel();
                // timer.cancel();
          // });
          widget.eventKey.currentState.removeItem(widget.index, 
            (context,animation){
              if(widget.array.length == 1&& widget.index == 0){  
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
          widget.callBack();
        }else{
          setState(() {
            minutes = minutes - Duration(minutes: 1);
          });
        }
  }
}