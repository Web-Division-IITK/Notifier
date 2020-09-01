import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/main.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/beautify_body.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';

class PostDescription extends StatefulWidget {
  /// list of posts which contains all posts for one post just pass the PostsSort parameter inside []
  final List<PostsSort> listOfPosts;
  /// index of the page that is to be displayed default is zero
  final int index;
  final String type;
  PostDescription({@required this.listOfPosts,@required this.type,this.index = 0});
  @override
  _PostDescriptionState createState() => _PostDescriptionState();
}
const String feature1 = 'feature5',
  feature2= 'feature6';

class _PostDescriptionState extends State<PostDescription> with SingleTickerProviderStateMixin {
  AnimationController _animationController ;
  Animation<Color> _colorTween;
  PageController _pageController;
  // final  List<String> steps = [
  //   'AddAsReminder',
  //   'AddAsBookmark',
  //   // 'NotificationV'
  // ];
  bool requestPermission = false;
  bool _load = false;
  bool priority = false;
  var time = false;
  var result = '';
  @override
  void initState() {
    // if(ids.contains(id)|| allCouncilData.level3.contains(id)){
    //   priority = true;
    // }
    print(ids.toString() + id);
    print(!ids.contains(id));
    if(!ids.contains(id)){
      setState(() {
        requestPermission = true; 
      });
    }
    else{
      setState(() {
        requestPermission = false;
      });
    }
    if(!widget.type.toLowerCase().contains('display') && widget.type.toLowerCase() != 'bookmarks' &&widget.type.toLowerCase() !='reminder' 
                      && (ids.contains(id)|| allCouncilData.level3.contains(id))){
                         WidgetsBinding.instance.addPostFrameCallback((_){
      FeatureDiscovery.discoverFeatures(context,
        const <String>{'AddPriority'
        },
      );
    });
                      }
     if(widget.type.contains('all')||
                      (widget.type.toLowerCase().contains('display') ||
                      widget.type.toLowerCase() =='notification'||widget.type.toLowerCase() =='reminder' )){
                        WidgetsBinding.instance.addPostFrameCallback((_){
      FeatureDiscovery.discoverFeatures(context,
        const <String>{
          feature1,
          feature2
        },
      );
    });
                      }
    
    // _load = true;
    // if(widget.type == 'notification'){
    //   DBProvider().getAllPosts().then((list){
    //     setState(() {
    //       widget.listOfPosts..addAll(list);
    //     });
    //   });
    // }
    _animationController = AnimationController(vsync: this);
    _colorTween = _animationController.drive(
      ColorTween(
        begin:Colors.yellow,
        end:Colors.blue
      )
    );
    _pageController = PageController(
      initialPage: widget.index,
    );
    // _animationController.repeat()
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    
      // print((!widget.type.toLowerCase().contains('display') && widget.type.toLowerCase() != 'bookmarks' &&widget.type.toLowerCase() !='reminder' 
      //                 &&( ids.contains(id)|| allCouncilData.level3.contains(id))));
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
                      (!widget.type.toLowerCase().contains('display') && widget.type.toLowerCase() != 'bookmarks' &&widget.type.toLowerCase() !='reminder' 
                        && (ids.contains(id)|| allCouncilData.level3.contains(id)))?
                      DescribedFeatureOverlay(
                        featureId: 'AddPriority', 
                        description: Text('You can set priority of post as Max or remain as default ;by default it is set to default notification priority set by user'),
                        title: Text('Set Priority'),
                        backgroundColor: Theme.of(context).brightness == Brightness.dark? Colors.accents[3] : Colors.accents[6],
                        // textColor: Colors.white,  
                        targetColor: Theme.of(context).appBarTheme.color,
                        onDismiss: ()async{
                          try {
                              FeatureDiscovery.completeCurrentStep(context);
                            //  FeatureDiscovery.dismissAll(context);
                           } catch (e) {
                             print(e);
                           }
                          return true;
                        },
                        tapTarget: Wrap(
                          // spacing: 5.0,
                          children: <Widget>[
                            // Text('Set priority'),
                            AbsorbPointer(
                              absorbing: true,
                              child: Switch(value: priority, 
                                onChanged: (value){
                                  setState(() {
                                    priority = value;
                                  });
                                }
                              ),
                            ),
                          ],
                        ), 
                        child:  Row(
                          // spacing: 5.0,
                          children: <Widget>[
                            Text('Set priority',
                              style: TextStyle(
                                color: Theme.of(context).appBarTheme.textTheme.headline1.color
                              ),
                            ),
                            Switch(
                              activeColor: Theme.of(context).brightness == Brightness.dark? Colors.accents[3] : Colors.accents[6],
                              value: priority, 
                              onChanged: (value){
                                setState(() {
                                  priority = value;
                                });
                              }
                            ),
                          ],
                        ), 
                      )
                      : Container(),
                      ((((widget.type.toLowerCase().contains('display') || widget.type.contains('all')) || widget.type.toLowerCase() == 'reminder')
                        && widget.listOfPosts[indexOfPage].endTime > DateTime.now().millisecondsSinceEpoch
                        && widget.listOfPosts[indexOfPage].startTime != 0 && widget.listOfPosts[indexOfPage].startTime!=null 
                        && widget.listOfPosts[indexOfPage].endTime != 0 && widget.listOfPosts[indexOfPage].endTime!=null)) ?
                      DescribedFeatureOverlay(
                        featureId: feature1,
                        tapTarget: Icon(Ionicons.ios_notifications_outline,
                            size: 26.0,),
                        title: Text('Add Post to Reminder'),
                        targetColor: Theme.of(context).appBarTheme.color,
                        description: Text('You can add a post (if the post contains both a start time and a end Time) to set reminder''This reminder would be displayed 10 minutes before the begining of ''an event.'
                        
                          ),
                          onDismiss: ()async{
                           try {
                              FeatureDiscovery.completeCurrentStep(context);
                            //  FeatureDiscovery.dismissAll(context);
                           } catch (e) {
                             print(e);
                           }
                          return true;
                        },
                        backgroundColor:Theme.of(context).brightness == Brightness.dark?
                          Colors.accents[3]:Colors.accents[2],
                        contentLocation: ContentLocation.below,
                        // textColor: Colors.white,
                        onOpen: ()async{
                          print('true for featuredis');
                          return true;
                        },
                        onComplete: ()async{
                          return true;
                        },
                        // targetColor: Theme.of(context).brightness == Brightness.dark?
                        //   Colors.accents[3]:Colors.accents[2],
                        child: IconButton(
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
                                    await ReminderNotification('An event you have saved is starting in $min',reminder: widget.listOfPosts[indexOfPage],
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
                          // }
                        // printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: widget.listOfPosts[indexOfPage].id)));
                            // });
                          }

                        ),
                      )
                      : ((((widget.type.toLowerCase().contains('display') || widget.type.contains('all')) || widget.type.toLowerCase() == 'reminder')
                        && (widget.listOfPosts[indexOfPage].startTime != 0 || widget.listOfPosts[indexOfPage].startTime!=null 
                        || widget.listOfPosts[indexOfPage].endTime != 0 || widget.listOfPosts[indexOfPage].endTime!=null))) ?
                      DescribedFeatureOverlay(
                        featureId: feature1,
                        tapTarget: Icon(Ionicons.ios_notifications_off,
                        ),
                        title: Text('Add Post to Reminder'),
                        description: Text('You can tap on this bell icon to set a post whose start and end time is mentioned as a reminder. ''This reminder would dispatch a notification 10 minutes before the begining of ''an event'
                        
                          ),
                        targetColor: Theme.of(context).appBarTheme.color,
                        backgroundColor:Theme.of(context).brightness == Brightness.dark?
                          Colors.accents[3]:Colors.accents[2],
                        contentLocation: ContentLocation.below,
                        // textColor: Colors.white,
                        onOpen: ()async{
                          print('true for featuredis');
                          return true;
                        },
                        onDismiss: ()async{
                          try {
                              FeatureDiscovery.completeCurrentStep(context);
                            //  FeatureDiscovery.dismissAll(context);
                           } catch (e) {
                             print(e);
                           }
                          return true;
                        },
                        onComplete: ()async{
                          return true;
                        },
                        child: IconButton(
                          // tooltip: widget.listOfPosts[indexOfPage].endTime == null || 
                          //   widget.listOfPosts[indexOfPage].endTime ==0 ? 'Can\'t add reminder for no endTime'
                          //     : 'Can\'t add reminder when the event has already finished',
                          icon: Icon(
                            Ionicons.ios_notifications_off
                          ),
                          disabledColor: Theme.of(context).brightness == Brightness.dark ? Colors.white:Colors.black,
                          iconSize: 26.0,
                          // : Icon(MaterialIcons.bookmark_border),
                          onPressed: null,
                        ),
                      ):Container(),
                      (widget.type.contains('all')||
                        (widget.type.toLowerCase().contains('display') ||
                        widget.type.toLowerCase() =='notification'||widget.type.toLowerCase() =='reminder' ))?
                      DescribedFeatureOverlay(
                        featureId: feature2,
                        tapTarget: Icon(MaterialIcons.bookmark_border, size: 26.0, ),
                        title: Text('Add Post to bookmark'),
                        targetColor: Theme.of(context).appBarTheme.color,
                        description: Text('You can clasify any post as your bookmark and the selected post would also be visible in the bookmarks section'),
                        contentLocation: ContentLocation.below,
                        onOpen: ()async{
                          print('true for featured bookmark is');
                          return true;
                        },
                        onDismiss: ()async{
                          try {
                              FeatureDiscovery.completeCurrentStep(context);
                            //  FeatureDiscovery.dismissAll(context);
                           } catch (e) {
                             print(e);
                           }
                          return true;
                        },
                        backgroundColor: Theme.of(context).brightness == Brightness.dark?
                          Colors.accents[3]:Colors.accents[14],
                        // textColor: Colors.white,
                        // targetColor: Theme.of(context).brightness == Brightness.dark?
                          // Colors.accents[3]:Colors.accents[13], 
                        child: IconButton(
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
                                      // DataHolderAndProvider.of(context).data.value.globalPostMap[widget.listOfPosts[indexOfPage].id].bookmark = false ;
                                      // DataHolderAndProvider.of(context).data.value.globalPostsArray.firstWhere((test) => test.id == widget.listOfPosts[indexOfPage].id).bookmark = false ;
                                      // DataHolderAndProvider.of(context).data.refresh();
                                await DBProvider().updateQuery(GetPosts(queryColumn: 'bookmark', queryData: (widget.listOfPosts[indexOfPage].bookmark?1:0),id:widget.listOfPosts[indexOfPage].id));
                                  if(widget.listOfPosts[indexOfPage].bookmark ==true){
                                    showSuccessToast('Bookmarked');
                                  }else{
                                        // showInfoToast('Removed From Saved');
                                      }
                                  printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: widget.listOfPosts[indexOfPage].id)));
                                },
                          ),
                      ):Container(),
                    ],
                  ),
                  body:Stack(
                    children: <Widget>[
                     ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          // RaisedButton(onPressed: (){
                          //   FeatureDiscovery.clearPreferences(context, const<String>{
                          //     feature1,
                          //     feature2
                          //   });
                          // }),
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
                                  // decoration: BoxDecoration(
                                  //                 border:Border.all()
                                  //               ),
                                  padding:EdgeInsets.all(16.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // SizedBox(height:10.0),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                                // alignment: Alignment.center,
                                          child: AutoSizeText(
                                            widget.listOfPosts[indexOfPage].title,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            style: TextStyle(fontSize: 35.0),
                                          ),
                                        ),
            /*                      Center(
                                                child:*/ Text(widget.listOfPosts[indexOfPage].sub,
                                                    // 'Science and Technology Council',
                                                    style: TextStyle(fontSize: 17.0)),
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
                                // Spacer(),
                                /*Flexible(
                                  flex: 2,
                                  child:*/ Container(
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
                                // ),
                                // Spacer(),
                                /*Flexible(
                                  flex: 2,
                                  child: */Container(
                                    height: 40,
                                    child: RaisedButton.icon(
                                      elevation: 10.0,
                                      color: Colors.green,
                                      splashColor: Colors.green[900],
                                      onPressed: ()async{
                                        var id;
                                        
                                        if(widget.type.toLowerCase() == 'create'){
                                          id = '${DateTime.now().microsecondsSinceEpoch}';
                                          widget.listOfPosts[indexOfPage].id = '';
                                          print(id);
                                        }
                                        else{
                                          id = widget.listOfPosts[indexOfPage].id;
                                        }
                                        if(widget.listOfPosts[indexOfPage].author == null|| widget.listOfPosts[indexOfPage].author == ''||(name!= null && name!= ''&&widget.listOfPosts[indexOfPage].author != name)){
                                          print(name);
                                         setState(() {
                                           widget.listOfPosts[indexOfPage].author = name;
                                         }); 
                                        }
                                        // print(widget.listOfPosts[indexOfPage].toMapSave());
                                        print(widget.listOfPosts[indexOfPage].id + 'id tot string');
                                        await saveAsDrafts(id,widget.listOfPosts[indexOfPage], widget.listOfPosts[indexOfPage].council).then((bool status){
                                            if(status){
                                              
                                              showSuccessToast('Post saved as drafts successfully');
                                              // Navigator.pop(context);
                                              // Navigator.pop(context);
                                            }else{
                                              showErrorToast('An error occured while saving post');
                                            }
                                          });
                                      }, 
                                      icon: Icon(MaterialCommunityIcons.file_download_outline), 
                                      label: Text(
                                        'Save As Draft'
                                      )
                                    ),
                                  ),
                                // ),
                                // Spacer(),
                                /*Flexible(
                                  flex: 2,
                                  child: */Container(
                                    // width:150.0,
                                    constraints: BoxConstraints(
                                      minWidth: 150
                                    ),
                                    height: 40,
                                    child: RaisedButton.icon(
                                      elevation: 10.0,
                                      highlightElevation: 5.0,
                                      onPressed: ()async{
                                        requestPermission? 
                                        showInfoToast('Sending Request'):
                                        showInfoToast('Publishing Post');
                                        setState(() {
                                          _load = true;
                                          // time = DateTime.now();
                                          
                                        });
                                        if(widget.type.toLowerCase().contains('drafted post')){
                                          widget.listOfPosts[indexOfPage].id = '';
                                        }
                                        Future.delayed(Duration(seconds: 10),(){
                                          if(mounted){setState(()=>time = true);}
                                        });
                                        print('${widget.listOfPosts[indexOfPage]?.id}' + 'id tot string');
                                        await publishPosts(null, widget.listOfPosts[indexOfPage],priority,permission: requestPermission).then((res){
                                          if(res.statusCode == 200){
                                            
                                            if(mounted){
                                              setState(() {
                                              _load = false;
                                            });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }
                                            requestPermission? 
                                            showSuccessToast('Your request has been send')
                                            : showSuccessToast('Your Posts has been published Successfully');
                                          }
                                          else{
                                            setState(() {
                                              _load = false;
                                            });
                                            requestPermission ?
                                            showErrorToast('Error while sending requset')
                                            :showErrorToast('Error while publishing posts '+'!!!');
                                          }
                                        });
                                      }, 
                                      icon: Icon(Entypo.publish), 
                                      label: Text(
                                        requestPermission ? 
                                        'Request Approval'
                                        :'Publish'
                                      )
                                    ),
                                  ),
                                // ),
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
                                  (requestPermission ? 'Sending request Approval'
                                  : 'Publishing Post')
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
  Future<bool> saveAsDrafts(String id,PostsSort postsSort,String council)async{
    var post = postsSort.toMapSave();
    post['id'] =id;
    print(post);
    printPosts(postsSortFromJson(json.encode(post)));
    return await DatabaseProvider(databaseName: 'drafts',tableName: 'Drafts').insertPost(postsSortFromJson(json.encode(post))).then((var v){
      if(v!=null){
        return true;
      }else{
        return false;
      }
    });
    // return await fileExists('drafts').then((bool status)async{
    //   if(status){
    //     return await readContent('drafts').then((draftsData)async{
    //       if(draftsData == null || draftsData[council].length==0){
    //         draftsData.update(council,(_)=>[{id:post}], ifAbsent: () =>[{id:post}]);
    //         return await writeContent('drafts',json.encode(draftsData));
    //       }
    //       else{
    //         draftsData.update(council, (v){
    //           v.insert(0,{id:post});
    //           return v;
    //         },ifAbsent: ()=>[{id:post}]);
    //         return await writeContent('drafts', json.encode(draftsData));
    //       }
    //     });
    //   }else{
    //     Map<String,dynamic> data = {};
    //     data.update(council,(_)=>[{id:post}], ifAbsent: () =>[{id:post}] );
    //     return await writeContent('drafts',json.encode(data));
    //   }
    // });
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