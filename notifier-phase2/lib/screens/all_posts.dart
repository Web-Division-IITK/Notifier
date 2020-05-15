import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:notifier/model/hive_model.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/search_post.dart';
import 'package:notifier/widget/showtoast.dart';

class AllPostGetData extends StatelessWidget {
  final UserModel data;
  AllPostGetData(this.data);
  // final tabController = TabController();
  @override
  Widget build(BuildContext context) {
    // var data = DataHolderAndProvider.of(context).data.value;
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (contexts) {
          return Scaffold(
            appBar: AppBar(
              title:Text('Posts'),
              bottom: TabBar(
                tabs: [
                Tab(
                  text: 'Posts'
                ),
                Tab(text: 'All posts',)
              ]),
              actions: <Widget>[
                Builder(
                  builder: (context) {
                    return IconButton(icon: Icon(Icons.search), 
                    tooltip: 'Search Post',
                      onPressed: ()async{
                        // switch (DefaultTabController.of(contexts).index) {
                          // case 0:
                          // return await _fetchData(data).then((list)async{
                          //   return await Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (context){
                          //     return SearchPost(list.reversed.toList(),'post');
                          //   }
                          // ));
                          // });
                            // break;
                          // default: 
                        return await DBProvider().getAllPosts().then((list)async{
                          return await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context){
                            return SearchPost(list,'post');
                          }
                        ));
                        });
                        // };
                        
                        // return showSearch(context: context, 
                        //   delegate: SearchDelegate()
                        
                        // );
                      }
                    );
                  }
                )
              ],
            ),
            body: StatefulBuilder(
              builder: (context,setState){
                void callBack(){
                  setState((){});
                }
                return TabBarView(
                  children: [
                    FutureBuilder(
                      future: _fetchData(data.prefs),
                      builder: (context,snapshot){
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            if(snapshot!=null && snapshot.data!=null && snapshot.data.length!=0){
                              return PostsPage(snapshot.data.toList(), 'post',data);
                            }else{
                              return Container(child: Center(child: Text('No post exists right now'),),);
                            }
                            break;
                          default: return Container(child: Center(child: CircularProgressIndicator(),),);
                        }
                      }
                    ),
                    FutureBuilder(
                      future: DBProvider().getAllPosts(),
                      builder: (context,AsyncSnapshot<List<PostsSort>> snapshot){
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            if(snapshot!=null && snapshot.data!=null && snapshot.data.length!=0){
                              return PostsPage(snapshot.data.toList(), 'all',data);
                            }else{
                              return Container(child: Center(child: Text('No post exists right now'),),);
                            }
                            break;
                          default: return Container(child: Center(child: CircularProgressIndicator(),),);
                        }
                      }
                    )
                  ]
                );
              }
            )
          );
        }
      )
    );
  }
  Future<List<PostsSort>>_fetchData(data) async{
    var list = await DBProvider().getAllPosts();
    return list == null || list.length == 0? 
      []
      : Future.microtask((){
        list.retainWhere((test)=> data.contains(test.sub));
        return Future.delayed(Duration(milliseconds: 20),()=>list);
      });
  }
  
}

// }
class DoubleHolder {
  double value = 0.0;
}

class PostsPage extends StatefulWidget {
  final DoubleHolder offset = new DoubleHolder();
  final List<PostsSort> data;
  final String type;
  final UserModel model;
  PostsPage(this.data,this.type,this.model);
   double getOffsetMethod() {
    return offset.value;
  }

  void setOffsetMethod(double val) {
    offset.value = val;
  }
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>  with AutomaticKeepAliveClientMixin<PostsPage>{
  ScrollController scrollController;
  DateTime timeOfRefresh;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // scrollController.addListener((){});
    scrollController = new ScrollController(
        initialScrollOffset: widget.getOffsetMethod()
    );
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LiquidPullToRefresh(
      showChildOpacityTransition: false,
      key: Key(widget.type),
      onRefresh: ()async{
        // print(timeOfRefresh);
        if(timeOfRefresh == null){
        
          await refreshCallbackTOFirebase(context);
        }else if(DateTime.now().second - timeOfRefresh.second > 30 && widget.type != 'all'){
          await refreshCallbackTOFirebase(context);
        }else if(DateTime.now().minute - timeOfRefresh.minute > 5 && widget.type == 'all'){
          await refreshCallbackTOFirebase(context); 
        }
        else{
         await Future.delayed(Duration(seconds: 2) , () => true);
        }
        timeOfRefresh = DateTime.now();
      },
      child:  ListView.builder(
        padding: EdgeInsets.all(16.0),
        controller: scrollController,
        shrinkWrap: true,
        itemCount: widget.data.length,
        // reverse: true,
        itemBuilder: (context,index){
          var i =  widget.data[index];
          i.dateAsString = convertDateToString(DateTime.fromMillisecondsSinceEpoch(i.timeStamp));
          if(widget.data.firstWhere((test){
            return convertDateToString(DateTime.fromMillisecondsSinceEpoch(test.timeStamp)) 
              == convertDateToString(DateTime.fromMillisecondsSinceEpoch(i.timeStamp));
          }) == i){
            return Column(
              key: ValueKey(i.timeStamp),
              children: <Widget>[
                Container(
                  child: Center(
                    child: Text(i.dateAsString),
                  ),                                            
                ),
                Container(
                  child: PostTile(index,widget.data,widget.type),
                )
              ],
            );
          }else{
            return Container(
              key: ValueKey(i.timeStamp),
                child: PostTile(index,widget.data,widget.type)
            );
          }
        }
      ),
    );
  }

  refreshCallbackTOFirebase(context)async{
    await p1('5',owner: widget.model.id).then((var status) async{
      if(status == null){
        //do nothing
      }else if(status){
        // await DBProvider().getAllPosts().then((var list){
          // list.
          // DataHolderAndProvider.of(context).data.value = SendToChildren(
          //   // globalPostMap:{for(var i in list) i.id:i},
          //   globalPostsArray: list.toList(),
          //   prefs: widget.data.prefs
          // );
          // DataHolderAndProvider.of(context).data.refresh();
        // });
      }
      else{
        // do nothing
      }
    });
  }
}

class PostTile extends StatefulWidget {
  final List<PostsSort> postArray;
  final int index;
  final String type;
  PostTile(this.index,this.postArray,this.type);
  @override
  _PostTileState createState() => _PostTileState(this.index,this.postArray);
}

class _PostTileState extends State<PostTile> {
  final List<PostsSort> postArray;
  final int index;
  _PostTileState(this.index,this.postArray);
  Timer timer;
  var time;
  @override
  void initState() { 
    super.initState();
    var timeStamp = DateTime.fromMillisecondsSinceEpoch(postArray[widget.index].timeStamp);
      postArray[widget.index].dateAsString = convertDateToString(timeStamp);
    switch (postArray[widget.index].dateAsString) {
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
    timer = Timer.periodic(Duration(minutes: 1), (timer){
      switch (postArray[widget.index].dateAsString) {
        case 'Today':{
          if (DateTime.now().difference(timeStamp).inMinutes <60 ) {
            var d;
            switch (d=DateTime.now().difference(timeStamp).inMinutes) {
              case 0: setState(() {
                time ='now';
              });
                break;
              default: time = '$d minutes ago';
            }
          } else {
            setState(() {
              time = DateFormat("hh:mm a").format(timeStamp);
              timer.cancel();
            });
          }
        }
        break;
        default: setState((){
          time = DateFormat("hh:mm a, dd MMMM yyyy").format(timeStamp);
        timer.cancel();
        });
      }
    });
  }
  @override
  void dispose() { 
    super.dispose();
    timer?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
        //   return showGeneralDialog<bool>(context: context, 
        //   pageBuilder: (context,value1,value2){
        //     return Dialog(
        //       child:PostDescription(listOfPosts: postArray, type: 'display' + ' ${widget.type}',index: index,)
        //     );
        //   }
        // );
          return Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return FeatureDiscovery(child: PostDescription(listOfPosts: postArray, type: 'display' + ' ${widget.type}',index: index,));
          }));
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 15.0,
              right: 0.0,
                  child: IconButton(
                    tooltip: 'Save Post',
                    icon: postArray[index].bookmark?Icon(
                      MaterialIcons.bookmark
                    ): Icon(MaterialIcons.bookmark_border),
                    onPressed: ()async{
                      setState(() {
                        postArray[index].bookmark = !postArray[index].bookmark;
                        
                      });
                      // DataHolderAndProvider.of(context).data.value.globalPostMap[postArray[index].id].bookmark = false ;
                      // DataHolderAndProvider.of(context).data.value.globalPostsArray.firstWhere((test) => test.id == postArray[index].id).bookmark = false ;
                      // DataHolderAndProvider.of(context).data.refresh();
                      await DBProvider().updateQuery(GetPosts(queryColumn: 'bookmark', queryData: (postArray[index].bookmark?1:0),id:postArray[index].id));
                      if(postArray[index].bookmark ==true){
                        showSuccessToast('Bookmarked');
                      }else{
                        // showInfoToast('Removed From Saved');
                      }
                      printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: postArray[index].id)));
                    }),
          ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: AutoSizeText(
                    // timenot['club'],
                      postArray[index].sub,
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
                  padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
                  child: AutoSizeText(postArray[index].title,
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
                    maxWidth: MediaQuery.of(context).size.width - 84.0,
                  ),
                  child: AutoSizeText(
                    // timenot['message'],
                    postArray[index].message,
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