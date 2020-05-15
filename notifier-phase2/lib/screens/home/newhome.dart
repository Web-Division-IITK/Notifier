import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/hive_model.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/all_posts.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/home/ongoing_events.dart';
import 'package:notifier/screens/home/upcoming_events.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';

class DoubleHolder {
  double value = 0.0;
}

class HomeDescription extends StatefulWidget {
  final DoubleHolder offset = new DoubleHolder();

  
  final List<PostsSort> arrayWithPrefs;
  final String userID;
  final UserModel userModel;
  final bool load;
  HomeDescription({Key key,this.arrayWithPrefs,this.load,this.userModel,this.userID}) : super(key: key);
double getOffsetMethod() {
    return offset.value;
  }

  void setOffsetMethod(double val) {
    offset.value = val;
  }
  @override
  _HomeDescriptionState createState() => _HomeDescriptionState();
}

class _HomeDescriptionState extends State<HomeDescription> {
  bool loadingPost = true;
  ScrollController scrollController;
  // final AsyncMemoizer memoizer = AsyncMemoizer();
  final _upcomingEventKey = GlobalKey<AnimatedListState>();
  final onGoingingEventKey = GlobalKey<AnimatedListState>();
  // final streamController = new StreamController.broadcast();
  // StreamSubscription streamSubscription;

  @override
  void initState() { 
    super.initState();
    setState(() {
      loadingPost = true;
    });
    // streamController.add(Stream.periodic(Duration(minutes: 1)));
    // streamController.hasListener
    // streamSubscription = streamController.stream.listen((onData){});
    scrollController = new ScrollController(
        initialScrollOffset: widget.getOffsetMethod()
    );
  }
  @override
  void dispose() { 
    // streamSubscription.cancel();
      // streamController.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // var data  = DataHolderAndProvider.of(context).data;
    return NotificationListener(
       onNotification: (notification) {
        if (notification is ScrollNotification) {
          widget.setOffsetMethod(notification.metrics.pixels);
        }
       },
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.all(16.0),
        shrinkWrap: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top:16.0),
            child: Text(
              "Ongoing Events",
              style: TextStyle(
                fontSize: 20.0
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top:16.0,bottom:16.0),
            //   constraints: BoxConstraints(
            //   minHeight: 100.0
            // ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)
              ),
              child: Container(
                // padding: EdgeInsets.fromLTRB(16.0,0,16,0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    FutureBuilder(
                      future: DatabaseProvider().getAllPosts(),
                      builder: (context,AsyncSnapshot<List<PostsSort>> snapshot){
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                          // print(snapshot.data);
                          var array = snapshot.data;
                          array.retainWhere((i){
                            var  date = DateTime.fromMillisecondsSinceEpoch(i.startTime);
                            DateTime endTime= DateTime.fromMillisecondsSinceEpoch(i.endTime);
                            
                          // print('array  + $date');
                            return date.isBefore(DateTime.now())&& endTime.isAfter(DateTime.now());
                          });
                          loadONGoingEvent(snapshot.data);
                            return snapshot.data == null ||snapshot.data.length == 0 || array == null || array.length == 0?
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              height: 80.0,
                              child: Center(
                                child: Text(
                                  'You have no Ongoing Events right now'
                                ),
                              ),
                            ) :
                            FutureBuilder(
                              future: Future.delayed(Duration(milliseconds: 80),(){
                                // print('array + $array ');
                              return array;
                            }),
                              builder: (context,snapshot){
                                switch (snapshot.connectionState) {
                                  case ConnectionState.done:
                                    var array = snapshot.data;
                                    if(snapshot.data == null ||snapshot.data.length == 0 || array == null || array.length == 0){
                                      // streamSubscription.pause();
                                      return Container(
                                        padding: EdgeInsets.symmetric(vertical: 5.0),
                                        constraints: BoxConstraints(
                                          maxHeight: 80
                                        ),
                                        child: Center(
                                          child: Text(
                                            'You have no Ongoing Events right now'
                                          ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: <Widget>[
                                        AnimatedList(
                                          physics: NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.symmetric(vertical: 5.0),
                                          key: onGoingingEventKey,
                                          shrinkWrap: true,
                                          initialItemCount: array.length <3? array.length : 3,
                                          itemBuilder: (context,index,animation){
                                            // loadONGoingEvent(array);
                                            return SizeTransition(
                                              sizeFactor: animation,
                                              child: StreamBuilder(
                                                stream: Stream.periodic(Duration(minutes: 1),),
                                                builder: (context, snapshot) {
                                                  return ListItemOnGoing(
                                                    key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                                                    // streamController: streamController,
                                                    post: array[index],
                                                    array: array,
                                                    index: index,
                                                    eventKey: onGoingingEventKey,
                                                    callBack: (){
                                                      setState(() {
                                                      });
                                                    },
                                                    // key: _upcomingEventKey,
                                                  );
                                                }
                                              ),
                                            );
                                          }
                                        ),
                                  Container(
                                    padding: EdgeInsets.only(right: 16.0),
                                  alignment: Alignment.bottomRight,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: (){
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return OnGoingEventPage();
                                        }));
                                    },
                                    child: Text('See All ...',
                                      style: TextStyle(
                                        fontSize: 12.0
                                      )
                                    )
                                  ),
                                ),
                                      ],
                                    );
                                    break;
                                  default: return Container(
                                    height: 80.0,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                              }
                            );
                            
                            
                            break;
                          default: return Container(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            height: 80.0,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        // );
                      }
                    ),

                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:16.0),
            child: Text(
              "Latest Posts",
              style: TextStyle(
                fontSize: 20.0
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top:16.0,bottom:16.0),
              constraints: BoxConstraints(
              minHeight: 80.0
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(16.0,0,16,0),
                // margin: EdgeInsets.only(bottom:16.0),
                child:FutureBuilder(
                      future: Future.sync(() {
                        widget.arrayWithPrefs.retainWhere((test)=>widget.userModel.prefs.contains(test.sub));
                        return widget.arrayWithPrefs;
                      }), 
                      builder: (context,AsyncSnapshot<List<PostsSort>> snapshot){
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            List<PostsSort> array = (snapshot == null || snapshot.data == null)?[]: snapshot.data;
                            
                            if(array.length == 0){
                              return Container(
                                height: 80.0,
                                child: Center(
                                  child: Text(
                                    'No post available right now'
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: <Widget>[
                                ListView.builder(
                                  padding: EdgeInsets.only(top:16),
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: array.length < 3? array.length:3,
                                  itemBuilder: (context,index){
                                    var i = array[index];
                                    i.dateAsString = convertDateToString(DateTime.fromMillisecondsSinceEpoch(i.timeStamp));
                                    if(i.dateAsString == 'Today'){
                                      if(array.firstWhere((test)=>
                                      convertDateToString(DateTime.fromMillisecondsSinceEpoch(test.timeStamp)) 
                                        == i.dateAsString) == i){
                                        return Column(
                                          // key: ValueKey(i.timeStamp),
                                          children: <Widget>[
                                            Container(
                                              child: Center(
                                                child: Text(i.dateAsString),
                                              ),                                            
                                            ),
                                            Container(
                                              child: StreamBuilder(
                                                stream: Stream.periodic(Duration(minutes: 1)),
                                                builder: (context, snapshot) {
                                                  return Tile(
                                                    key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                                                    index: index,
                                                    arrayWithPrefs: array,);
                                                }
                                              ),
                                            )
                                          ],
                                        );
                                      }else{
                                        return Container(
                                          // key: ValueKey(i.timeStamp),
                                          child: StreamBuilder(
                                            stream: Stream.periodic(Duration(minutes: 1)),
                                            builder: (context, snapshot) {
                                              return Tile(
                                                key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                                                index: index,
                                                    arrayWithPrefs: array,);
                                            }
                                          )
                                        );
                                      }
                                    }
                                    else{
                                      if(array.firstWhere((test)=>
                                      convertDateToString(DateTime.fromMillisecondsSinceEpoch(test.timeStamp)) 
                                        == i.dateAsString) == i){
                                        return Column(
                                          // key: ValueKey(i.timeStamp),
                                          children: <Widget>[
                                            Container(
                                              child: Center(
                                                child: Text(i.dateAsString),
                                              ),                                            
                                            ),
                                            Container(
                                              child: Tile(
                                                key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                                                index: index,
                                                arrayWithPrefs: array,)
                                            )
                                          ],
                                        );
                                      }else{
                                        return Container(
                                          // key: ValueKey(i.timeStamp),
                                          child: Tile(
                                            key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                                            index: index,
                                            arrayWithPrefs: array,)
                                        );
                                      }
                                    }
                                  }
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: (){
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return AllPostGetData(widget.userModel);}));
                                    },
                                    child: Text('See All ...',
                                      style: TextStyle(
                                        fontSize: 12.0
                                      )
                                    )
                                  ),
                                ),
                              ]
                            );
                            break;
                          default: return Container(
                            height: 80.0,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      }
                    ),
                    
                //   ],
                // ),
              ),

            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:0.0),
            child: Text(
              "Upcoming Events",
              style: TextStyle(
                fontSize: 20.0
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top:16.0,bottom:16.0),
            //   constraints: BoxConstraints(
            //   minHeight: 100.0
            // ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)
              ),
              child: Container(
                // padding: EdgeInsets.fromLTRB(16.0,0,16,0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    FutureBuilder(
                      future: DatabaseProvider().getAllPosts(),
                      builder: (context,AsyncSnapshot<List<PostsSort>> snapshot){
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                          // print(snapshot.data);
                          var array = snapshot.data;
                          array.retainWhere((i){
                            var  date = DateTime.fromMillisecondsSinceEpoch(i.startTime);
                            // DateTime endTime= DateTime.fromMillisecondsSinceEpoch(i.endTime);
                            return date.isAfter(DateTime.now());
                          });
                          loadUpcomingEvents(array);
                            return snapshot.data == null ||snapshot.data.length == 0 || array == null || array.length == 0?
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              // height: 80.0,
                              constraints: BoxConstraints(
                                maxHeight: 80
                              ),
                              child: Center(
                                child: Text(
                                  'You have no Upcoming Events right now'
                                ),
                              ),
                            ) :
                            FutureBuilder(
                              future: Future.delayed(Duration(milliseconds: 80),(){
                              return array;
                            }),
                              builder: (context,snapshot){
                                switch (snapshot.connectionState) {
                                  case ConnectionState.done:
                                    var array = snapshot.data;
                                    return snapshot.data == null ||snapshot.data.length == 0 || array == null || array.length == 0?
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 5.0),
                                      height: 80.0,
                                      child: Center(
                                        child: Text(
                                          'You have no Upcoming Events right now'
                                        ),
                                      ),
                                    ) :Column(
                                      children: <Widget>[
                                        AnimatedList(
                                          physics: NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.symmetric(vertical: 5.0),
                                          key: _upcomingEventKey,
                                          shrinkWrap: true,
                                          initialItemCount: array.length <3? array.length : 3,
                                          itemBuilder: (context,index,animation){
                                            // loadONGoingEvent(array);
                                            return SizeTransition(
                                              sizeFactor: animation,
                                              child: StreamBuilder(
                                                stream: Stream.periodic(Duration(minutes: 1)),
                                                builder: (context, snapshot) {
                                                  return ListItem(
                                                    key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                                                    postsList: array,
                                                    // array: array,
                                                    index: index,
                                                    eventKey: _upcomingEventKey,
                                                    load: (){
                                                      setState(() {
                                                      });
                                                    },
                                                    // key: _upcomingEventKey,
                                                  );
                                                }
                                              ),
                                            );
                                          }
                                        ),
                                  Container(
                                    padding: EdgeInsets.only(right:16.0),
                                  alignment: Alignment.bottomRight,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: (){
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return UpcomingEventsPage();
                                        }));
                                    },
                                    child: Text('See All ...',
                                      style: TextStyle(
                                        fontSize: 12.0
                                      )
                                    )
                                  ),
                                ),
                                      ],
                                    );
                                    break;
                                  default: return Container(
                                    height: 80.0,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                              }
                            );
                            
                            
                            break;
                          default: return Container(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            height: 80.0,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        // );
                      }
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  loadONGoingEvent(array){
    if(array.length == 0){
      // print('No events right now');
      // return  'No events right now';
    }
    else{
      for (var i in array) {
        if(i.reminder == true){
           var  date = DateTime.fromMillisecondsSinceEpoch(i.startTime);
          DateTime endTime= DateTime.fromMillisecondsSinceEpoch(i.endTime);
          if(checkDateForONisBetween(date,
              endTime,i)){
              // var minutes = endTime.difference(DateTime.now());
          }
          else if(endTime.isBefore(DateTime.now())){
            DatabaseProvider().deletePost(i.id);
          }
          else{
            // array.removeWhere((test) => test.id == i.id);
          }
        }
    }
    
    }
  }
  Future loadUpcomingEvents(array)async{
    // widget.array.sort((,b)=> a.date.compareTo(b.date));
    if(array.length == 0){
      // print('No events right now');
      // return  'No events right now';
    }
    else{
      for (var i in array) {
        if(i.reminder == true){
          var startTime = DateTime.fromMillisecondsSinceEpoch(i.startTime);
          DateTime endTime= DateTime.fromMillisecondsSinceEpoch(i.endTime);
          if(checkDateisBetween(startTime,endTime,i)){
            // Duration duration = startTime.difference(DateTime.now());
            // setState(() {
              // array.add(i);
            // });
          }
          else if(endTime.isBefore(DateTime.now())){
            DatabaseProvider().deletePost(i.id);
          }
          else{
            // setState(() {
              // array.removeWhere((test) => test.id == i.id);
            // });
          }
          }
      } 
    }
  }
}

_navigateToPostDesc(context,index,arrayWithPrefs)async {
    return await Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return FeatureDiscovery(child: PostDescription(listOfPosts: arrayWithPrefs, type: 'display',index: index,));
      }
    ));
    // if( result!=null &&result == 'reload'){
    //   print(result);
    //   setState(() {
    //     // build(context);
    //     //  loadArray(context);
    //     // loadUpcominganOnGOing(widget.arrayWithPrefs);
    //   });
    // }
}

class Tile extends StatefulWidget {
  
    final int index;
    final List<PostsSort> arrayWithPrefs;
    // final Stream stream;
    // final String time;
    Tile({key,this.index,/*this.time,*/this.arrayWithPrefs/*,this.stream*/}):super(key:key);
  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<Tile> {
  // Timer timer;
  var time;
  @override
  void initState() { 
    super.initState();
    var timeStamp = DateTime.fromMillisecondsSinceEpoch(widget.arrayWithPrefs[widget.index].timeStamp);
      widget.arrayWithPrefs[widget.index].dateAsString = convertDateToString(timeStamp);
    switch (widget.arrayWithPrefs[widget.index].dateAsString) {
        case 'Today':{
          if (DateTime.now().difference(timeStamp).inMinutes <60 ) {
            var d;
            switch (d=DateTime.now().difference(timeStamp).inMinutes) {
              case 0: time ='now';
                break;
              default: time = '$d minutes ago';
            }
          } else {time = DateFormat("hh:mm a").format(timeStamp);
          }
        }
        break;
        default: 
          time = DateFormat("hh:mm a, dd MMMM yyyy").format(timeStamp);
      } 
    // timer = Timer.periodic(Duration(minutes: 1), (timer){
    //   widget.arrayWithPrefs[widget.index].dateAsString = convertDateToString(DateTime.fromMillisecondsSinceEpoch(widget.arrayWithPrefs[widget.index].timeStamp));
    //   switch (widget.arrayWithPrefs[widget.index].dateAsString) {
    //     case 'Today':{
    //       if (DateTime.now().difference(timeStamp).inMinutes <60 ) {
    //         var d;
    //         switch (d=DateTime.now().difference(timeStamp).inMinutes) {
    //           case 0: setState(() {
    //             time ='now';
    //           });
    //             break;
    //           default: time = '$d minutes ago';
    //         }
    //       } else {
    //         setState(() {
    //           time = DateFormat("hh:mm a").format(timeStamp);
    //           timer.cancel();
    //         });
    //       }
    //     }
    //     break;
    //     default: setState((){
    //       time = DateFormat("hh:mm a, dd MMMM yyyy").format(timeStamp);
    //     timer.cancel();
    //     });
    //   }
    // });
  }
  // @override
  // void dispose() { 
  //   super.dispose();
  //   timer.cancel();
  // }
    @override
    Widget build(BuildContext context) {
      
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          // return 
            _navigateToPostDesc(context, widget.index,widget.arrayWithPrefs);
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 15.0,
              right: 0.0,
                child: IconButton(
                  tooltip: 'Save Post',
                  icon: widget.arrayWithPrefs[widget.index].bookmark?Icon(
                    MaterialIcons.bookmark
                  ): Icon(MaterialIcons.bookmark_border),
                  onPressed: ()async{
                    setState(() {
                    widget.arrayWithPrefs[widget.index].bookmark = !widget.arrayWithPrefs[widget.index].bookmark;                        
                      });
                      // DataHolderAndProvider.of(context).data.value.globalPostMap[widget.arrayWithPrefs[index].id].bookmark = false ;
                      // DataHolderAndProvider.of(context).data.value.globalPostsArray.firstWhere((test) => test.id == widget.arrayWithPrefs[index].id).bookmark = false ;
                      // DataHolderAndProvider.of(context).data.refresh();
                    await DBProvider().updateQuery(
                      GetPosts(queryColumn: 'bookmark', queryData: (widget.arrayWithPrefs[widget.index].bookmark?1:0),id:widget.arrayWithPrefs[widget.index].id));
                    if(widget.arrayWithPrefs[widget.index].bookmark ==true){
                      showSuccessToast('Bookmarked');
                    }else{
                        // showInfoToast('Removed From Saved');
                    }
                    printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: widget.arrayWithPrefs[widget.index].id)));
                  }),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: AutoSizeText(
                    widget.arrayWithPrefs[widget.index].sub,
                      // 'Science and Texhnology Council',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.blueGrey
                            : Colors.white70,
                        // fontWeight: FontStyle.italic,
                        fontSize: 10.0,
                      )),
                ),
                Container(
                  // alignment: Alignment.center,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width-90
                  ),
                  padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
                  child: AutoSizeText(widget.arrayWithPrefs[widget.index].title,
                  
                      // 'Sit commodo fugiat duis consectetur sunt ipsum cupidatat adipisicing mollit et magna duis.',
                      minFontSize: 15.0,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 116.0,
                  ),
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.black
                  //   )
                  // ),
                  child: AutoSizeText(
                    // timenot['message'],
                    widget.arrayWithPrefs[widget.index].message,
                    // 'Dolor consectetur in dolore anim reprehenderit djhbjdhsbvelit pariatur veniam nostrud id ex exercitation.',
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
                      time,
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
    );
  }
  }