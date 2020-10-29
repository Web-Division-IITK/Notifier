import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home/upcoming_events.dart';
import 'package:notifier/screens/posts/post_desc.dart';


checkDateForONisBetween(DateTime startTime,DateTime endTime,PostsSort postsSort){
  if(startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now())){
    return true;
  }else{
    print('false'+ 'loadingongoing' );
    return false;
  }
}

class OnGoingEventPage extends StatefulWidget {
  // final Function load;
  // // final List<PostsSort> array;
  // final Stream stream;
  // OnGoingEventPage({@required this.stream,/*this.array*/});
  @override
  _OnGoingEventPageState createState() => _OnGoingEventPageState();
}

class _OnGoingEventPageState extends State<OnGoingEventPage> with AutomaticKeepAliveClientMixin<OnGoingEventPage>{

  final GlobalKey<AnimatedListState> _oneventKey = GlobalKey<AnimatedListState>();
  List<PostsSort> array = [];
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
        title:Text('On Going Events'),
        centerTitle: true,
      ),
      body: Container(
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context,AsyncSnapshot<List<PostsSort>> snapshot) {
            // streamController.stream.listen((onData){});
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if(snapshot == null || snapshot.data == null || snapshot.data.length ==0){
                  // streamController.close();
                  return Container(
                    height: MediaQuery.of(context).size.height*0.8,
                    // height: double.maxFinite,
                    child: Center(child: Text('No ongoing events right now')),
                  );
                }else{
                  // if(streamController.isClosed){
                  //   streamController.addStream(Stream.periodic(Duration(minutes: 1)));
                  // }
                  return LiquidPullToRefresh(
                    showChildOpacityTransition: false,
                    onRefresh: ()async{
                    callBack();
                    },
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      children: <Widget>[
                        snapshot.data == null ||snapshot.data.length == 0?
                        Container(
                          height: MediaQuery.of(context).size.height*0.8,
                          // height: double.maxFinite,
                          child: Center(child: Text('No ongoing events right now')),
                        ):
                        AnimatedList(
                          shrinkWrap: true,
                          key: _oneventKey,
                          physics: NeverScrollableScrollPhysics(),
                          initialItemCount: snapshot.data.length,
                          itemBuilder: (context,index,animation){
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
                                    eventKey: _oneventKey,
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
    );
  }
  Future<List<PostsSort>> _fetchData()async{
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
  final PostsSort post;
  final List<PostsSort> array;
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
    // List<PostsSort> arrayw = [];
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
              return FeatureDiscovery(child: PostDescription(listOfPosts: widget.array, type: 'reminder'));
            })
          );
        },
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
          ),
          constraints: BoxConstraints(
            minHeight: 80.0,
          ),
          padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(widget.post.sub,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                              ? Colors.blueGrey
                              : Colors.white70,
                    fontSize: 10.0,
                  ),
                ),
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