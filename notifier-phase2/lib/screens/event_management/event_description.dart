import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/main.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/event_management/schedule_reminder.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/beautify_body.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';

class EventDescription extends StatefulWidget {
  /// list of posts which contains all posts for one post just pass the PostsSort parameter inside []
  final List<PostsSort> listOfPosts;
  /// index of the page that is to be displayed default is zero
  final int index;
  final String type;
  EventDescription({@required this.listOfPosts,@required this.type,this.index = 0});
  @override
  _EventDescriptionState createState() => _EventDescriptionState();
}
// const String feature1 = 'feature5',
//   feature2= 'feature6';

class _EventDescriptionState extends State<EventDescription> with SingleTickerProviderStateMixin {
  AnimationController _animationController ;
  Animation<Color> _colorTween;
  PageController _pageController;
  bool _load = false;
  bool priority = false;
  var time = false;
  var result = '';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AbsorbPointer(
          absorbing: _load,
          child: PageView.builder(
              controller: _pageController,
              itemCount: widget.listOfPosts.length,
              itemBuilder:(BuildContext context,indexOfPage) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(widget.listOfPosts[indexOfPage].title),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                       onPressed: (){
                         Navigator.pop(context,result);
                       }),
                    actions: <Widget>[
                      
                      ((((widget.type.toLowerCase().contains('display') || widget.type.contains('all')) || widget.type.toLowerCase() == 'reminder')
                        && widget.listOfPosts[indexOfPage].endTime > DateTime.now().millisecondsSinceEpoch
                        && widget.listOfPosts[indexOfPage].startTime != 0 && widget.listOfPosts[indexOfPage].startTime!=null 
                        && widget.listOfPosts[indexOfPage].endTime != 0 && widget.listOfPosts[indexOfPage].endTime!=null)) ?
                      IconButton(
                        tooltip: 'Add Reminder',
                        icon: widget.listOfPosts[indexOfPage].reminder?
                          Icon(
                            Ionicons.ios_notifications
                          ):Icon(Ionicons.ios_notifications_outline),
                        iconSize: 26.0,
                      // : Icon(MaterialIcons.bookmark_border),
                        onPressed: ()async{
                          setState(() {
                            widget.listOfPosts[indexOfPage].reminder = !widget.listOfPosts[indexOfPage].reminder;
                            result  = 'reload';
                          });
                          
                          await DBProvider().updateQuery(GetPosts(queryColumn: 'reminder', queryData: (widget.listOfPosts[indexOfPage].reminder?1:0),id:widget.listOfPosts[indexOfPage].id));
                            if(widget.listOfPosts[indexOfPage].reminder ==true){
                              if(DateTime.fromMillisecondsSinceEpoch(widget.listOfPosts[indexOfPage].startTime)
                                .difference(DateTime.now()).inMinutes >=10){
                                await ReminderNotification('An event you have saved is starting in 10 minutes',reminder: widget.listOfPosts[indexOfPage],
                                  time: DateTime.fromMillisecondsSinceEpoch(widget.listOfPosts[indexOfPage].startTime).subtract(Duration(minutes: 10))).initiate;
                              }else if(DateTime.fromMillisecondsSinceEpoch(widget.listOfPosts[indexOfPage].startTime)
                                .difference(DateTime.now()).inMinutes > 0){
                                  var min = DateTime.fromMillisecondsSinceEpoch(widget.listOfPosts[indexOfPage].startTime)
                                .difference(DateTime.now()).inMinutes ;
                                  await ReminderNotification('An event you have saved is starting in $min minutes',reminder: widget.listOfPosts[indexOfPage],
                                    time: DateTime.now()).initiate;
                              }else if(DateTime.fromMillisecondsSinceEpoch(widget.listOfPosts[indexOfPage].endTime,)
                                .difference(DateTime.now()).inMinutes <=0){
                                  await ReminderNotification('Event has ended',id: widget.listOfPosts[indexOfPage].timeStamp.toSigned(31)).cancel;
                              }else{
                                await ReminderNotification('An event you have saved is going on',reminder: widget.listOfPosts[indexOfPage],
                                 time: DateTime.now()).initiate;
                              }
                              await DatabaseProvider().insertPost(widget.listOfPosts[indexOfPage]);
                              showSuccessToast('Added as a Reminder');
                            }else{
                              showInfoToast('Removed From Reminder');
                              await ReminderNotification('Event has ended',id: widget.listOfPosts[indexOfPage].timeStamp.toSigned(31)).cancel;
                              await DatabaseProvider().deletePost(widget.listOfPosts[indexOfPage].id);
                            } 
                        }

                      )
                      : ((((widget.type.toLowerCase().contains('display') || widget.type.contains('all')) || widget.type.toLowerCase() == 'reminder')
                        && (widget.listOfPosts[indexOfPage].startTime != 0 || widget.listOfPosts[indexOfPage].startTime!=null 
                        || widget.listOfPosts[indexOfPage].endTime != 0 || widget.listOfPosts[indexOfPage].endTime!=null))) ?
                      IconButton(
                        icon: Icon(
                          Ionicons.ios_notifications_off
                        ),
                        disabledColor: Theme.of(context).brightness == Brightness.dark ? Colors.white:Colors.black,
                        iconSize: 26.0,
                        onPressed: null,
                      ):Container(),
                      (widget.type.contains('all')||
                        (widget.type.toLowerCase().contains('display') ||
                        widget.type.toLowerCase() =='notification'||widget.type.toLowerCase() =='reminder' ))?
                      IconButton(
                        tooltip: 'Save Post',
                        icon: widget.listOfPosts[indexOfPage].bookmark?
                          Icon(
                            MaterialIcons.bookmark
                          )
                          : Icon(MaterialIcons.bookmark_border),
                            iconSize: 26.0,
                            onPressed: ()async{
                              setState(() {
                                widget.listOfPosts[indexOfPage].bookmark = !widget.listOfPosts[indexOfPage].bookmark;
                              });
                              await DatabaseProvider().updateQuery(GetPosts(queryColumn: 'bookmark', queryData: (widget.listOfPosts[indexOfPage].bookmark?1:0),id:widget.listOfPosts[indexOfPage].id));
                              await DBProvider().updateQuery(GetPosts(queryColumn: 'bookmark', queryData: (widget.listOfPosts[indexOfPage].bookmark?1:0),id:widget.listOfPosts[indexOfPage].id));
                                if(widget.listOfPosts[indexOfPage].bookmark ==true){
                                  showSuccessToast('Bookmarked');
                                }else{
                                      // showInfoToast('Removed From Saved');
                                    }
                                printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: widget.listOfPosts[indexOfPage].id)));
                              },
                        ):Container(),
                    ],
                  ),
                  body:Stack(
                    children: <Widget>[
                     ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          widget.listOfPosts[indexOfPage].url !=  null && widget.listOfPosts[indexOfPage].url !=  'null' && widget.listOfPosts[indexOfPage].url.trim() !=  ''
                          ? CachedNetworkImage(
                            progressIndicatorBuilder: (context,url,progress){
                              return Container(
                                child: Center(
                                  child: CircularProgressIndicator(value: progress.progress,
                                    valueColor: _colorTween,
                                  ),
                                ),
                              );
                            },
                            imageUrl: widget.listOfPosts[indexOfPage].url)
                          :Container(),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)
                            ),
                            elevation: 5.0,
                            margin: EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 15.0),
                            child: Stack(
                              children: <Widget>[
                                                         
                                Container(
                                  padding:EdgeInsets.all(16.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: AutoSizeText(
                                            widget.listOfPosts[indexOfPage].title,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            style: TextStyle(fontSize: 35.0),
                                          ),
                                        ),
            /*                      Center(
                                                child:Text(widget.listOfPosts[indexOfPage].sub,
                                                    // 'Science and Technology Council',
                                                    style: TextStyle(fontSize: 17.0)),*/
                                              // ),
                                              (widget.listOfPosts[indexOfPage].tags != 'null' &&widget.listOfPosts[indexOfPage].tags != ''&&widget.listOfPosts[indexOfPage].tags != null)
                                              ? Padding(
                                                padding: const EdgeInsets.only(top:8.0),
                                                child: Wrap(
                                                  spacing: 8.0,
                                                  children: _buildChoice(widget.listOfPosts[indexOfPage].tags),
                                                ),
                                              ): Container(),
                                              widget.listOfPosts[indexOfPage].startTime != 0 && widget.listOfPosts[indexOfPage].startTime!=null ?
                                              Container(
                                                padding: EdgeInsets.only(top:16.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(right:8.0),
                                                      child: Icon(
                                                        EvilIcons.calendar,
                                                        size: 30.0,
                                                      ),
                                                    ),
                                                    
                                                    Text(
                                                      DateFormat("hh:mm a, dd MMMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(widget.listOfPosts[indexOfPage].startTime)),
                                                    )
                                                  ],
                                                ),
                                              ):Container(),
                                              widget.listOfPosts[indexOfPage].startTime != 0 && widget.listOfPosts[indexOfPage].startTime!=null 
                                              && widget.listOfPosts[indexOfPage].endTime != 0 && widget.listOfPosts[indexOfPage].endTime!=null ?
                                              Container(
                                                padding: EdgeInsets.only(top:0.0,left: 2.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(right:8.0),
                                                      child: Icon(Ionicons.md_time,
                                                        size: 26.0,
                                                      ),
                                                    ),
                                                    // widget.listOfPosts[indexOfPage].endTime != '' && widget.listOfPosts[indexOfPage].Time!=null ?
                                                    Text(
                                                      DateFormat("hh:mm a, dd MMMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(widget.listOfPosts[indexOfPage].endTime)),
                                                    ),
                                                  ],
                                                ),
                                              ) :Container(),
                                              Container(
                                                // decoration: BoxDecoration(
                                                //   border:Border.all()
                                                // ),
                                                padding: const EdgeInsets.only(top:16.0),
                                                child: BeautifyPostBody(
                                                  body: widget.listOfPosts[indexOfPage].body,
                                                  textStyle: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Theme.of(context).brightness == Brightness.dark?Colors.white: Colors.black,
                                                      fontFamily: 'Raleway'
                                                      // color:Colors.white
                                                      ),
                                                  linkStyle: TextStyle(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                              ],
                            ),
                          ),
                          !widget.type.toLowerCase().contains('display') && widget.type.toLowerCase() != 'bookmarks' &&widget.type.toLowerCase() !='reminder' ?Container(
                            margin: EdgeInsets.only(bottom:20.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 20.0,
                              runSpacing: 10.0,
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                  Container(
                                    height: 40,
                                    child: RaisedButton.icon(
                                      elevation: 10.0,
                                      color: Colors.grey[800],
                                      splashColor: Colors.black,
                                      textColor: Colors.white,
                                      onPressed: (){
                                        Navigator.pop(context);
                                      }, 
                                      icon: Icon(MaterialCommunityIcons.cancel), 
                                      label: Text(
                                        'Dismiss'
                                      )
                                    ),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      minWidth: 150
                                    ),
                                    height: 40,
                                    child: RaisedButton.icon(
                                      elevation: 10.0,
                                      highlightElevation: 5.0,
                                      onPressed: ()async{
                                        showInfoToast('Creating Event');
                                        setState(() {
                                          _load = true;
                                        });
                                        Future.delayed(Duration(seconds: 10),(){
                                          if(mounted){setState(()=>time = true);}
                                        });
                                        String id;
                                        // if(widget.type.toLowerCase() == 'create'){
                                          id = '${DateTime.now().microsecondsSinceEpoch}';
                                          widget.listOfPosts[indexOfPage].id = '';
                                          print(id);
                                        if(widget.listOfPosts[indexOfPage].author == null|| widget.listOfPosts[indexOfPage].author == ''||(name!= null && name!= ''&&widget.listOfPosts[indexOfPage].author != name)){
                                          print(name);
                                         setState(() {
                                           widget.listOfPosts[indexOfPage].author = name??"";
                                         }); 
                                        }
                                        widget.listOfPosts[indexOfPage].council = EVENT_COUNCIL;
                                        widget.listOfPosts[indexOfPage].sub = EVENT_SUB;
                                        widget.listOfPosts[indexOfPage].type = EVENT_TYPE;
                                        print('${widget.listOfPosts[indexOfPage]?.id}' + 'id to string');
                                        // Response res = requestPermission ? 
                                        //   await createEditPosts(widget.listOfPosts[indexOfPage],priority,isCreate: true)
                                        //   : await approvePost(widget.listOfPosts[indexOfPage]); 
                                        // .then((res){
                                          // if(res.statusCode == 200){
                                        await createEvent(id, widget.listOfPosts[indexOfPage]).then((value) {
                                          if(value == true){
                                            if(mounted){
                                              setState(() {
                                                _load = false;
                                              });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }
                                            showSuccessToast('Your Event has been created successfully !!!');
                                          }
                                          else{
                                            if(mounted){
                                              setState(() {
                                                _load = false;
                                              });
                                            }
                                            showErrorToast("Something went wrong while creating your event !!!");
                                          }
                                        });
                                            
                                      }, 
                                      icon: Icon(Entypo.publish), 
                                      label: Text('Create Event'
                                      )
                                    ),
                                  ),
                              ],
                            ),
                          ):Container()
                        ],
                      ),
                       _load?
                      Center(
                        child: Container(
                          color: Colors.black.withOpacity(0.8),
                          // height: 500.0,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          
                          child: Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                child: Text(
                                  !time ?
                                  'Creating Event ...'
                                  : 'Taking too much time,maybe your connectivity is slow',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                              ),
                              SizedBox(height:20),
                              SpinKitDualRing(color: Theme.of(context).accentColor),
                              
                            ],
                          ),),
                        ),
                      ) :Container(),
                    ],
                  )
                );
              },
          ),
      ),
    );
  }
  Future<bool> createEvent(String id,PostsSort postsSort)async{
    postsSort.id = id;
    postsSort.timeStamp = DateTime.now().millisecondsSinceEpoch;
    var post = postsSort.toMapSave();
    print(post);
    printPosts(postsSortFromJson(json.encode(post)));
    try{
      
      return await DatabaseProvider().insertPost(postsSortFromJson(json.encode(post))).then((value)async{
        print("SUCCESSFULLY CREATED EVENT !!!");
        await EventReminderNotification(
          'Event has started',reminder: postsSort,id: postsSort.timeStamp,
          time: DateTime.fromMillisecondsSinceEpoch(postsSort.startTime)).initiate;
        return true;
      });
    }catch(e){
      print("ERROR OCCURRED WHILE CREATING EVENT");
      print(e);
      return false;
    }
  }
  _buildChoice(String postTags) {
    List<Widget> _tag = List();
    List<String> tags = postTags.split(";");
    if(tags!=null){
      tags.removeAt(tags.length- 1);
      for (var i in tags) {
        if(i!=' ' || i!= null){
           _tag.add(Container(
        constraints: BoxConstraints(
          maxWidth: 120.0,
          // minWidth: 80.0,
        ),
        child: Chip(
          labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.purple: Colors.amber,
          label: Text(i.toString(), style: TextStyle(color: Colors.white)),
        ),
      ));
        }
    }
    }else{
      _tag.add(Container());
    }

    return _tag;
  }
}