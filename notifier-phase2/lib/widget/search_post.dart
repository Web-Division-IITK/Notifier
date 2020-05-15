import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';

class SearchPost extends StatefulWidget {
  final List<PostsSort> list;
  final String type;
  SearchPost(this.list,this.type);
  @override
  _SearchPostState createState() => _SearchPostState();
}

class _SearchPostState extends State<SearchPost> {
  final _controller = TextEditingController();
  List<PostsSort> array = [];
  StreamController<List<PostsSort>> streamController = new StreamController();
  StreamController<String> streamControllerText = new StreamController();
  @override
  void initState() { 
    super.initState();
    streamController.add(widget.list);
    // streamController = StreamController.broadcast();
    _controller.addListener((){});
    streamControllerText.add(_controller.text);
    // streamController.add(null);
    // streamController.add(widget.list);
    // setState(() {
    //   _searchPostFromString(null);
    // });
    // streamController.sink.add(widget.list);
  }
  @override
  void dispose() {
    super.dispose();
    streamController?.close();
    streamControllerText?.close();
    // streamController.
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Container(
          height: 50.0,
          margin: EdgeInsets.only(right: 20.0),
          // padding: EdgeInsets.symmetr/ic(vertical: 16.0),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            maxLines: 1,
            autofocus: true ,
            keyboardType: TextInputType.text,
            onSubmitted:(text)=> _searchPostFromString(text),
            onChanged:(text)=> _searchPostFromString(text),
            style: TextStyle(
              color:Colors.black
            ),
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.all(2.0),
              focusColor: Colors.black,
              hoverColor: Colors.black,
              hintText: 'Search',
              // hintText: _controller.text.isEmpty?'Search with title, club/ entity, council and tags of post' : null,
              hintStyle: TextStyle(
                color: Colors.black,
                // fontSize: 8.0
              ),
              suffixIcon: StreamBuilder(
                stream: streamControllerText.stream,
                builder: (context,AsyncSnapshot<String> snapshot) {
                  if(snapshot == null || snapshot.data == null || snapshot.data.isEmpty){
                    return Icon(Icons.ac_unit,color: Colors.white,size: 5,);
                  }
                  return IconButton(icon: Icon(Icons.close), 
                    onPressed: (){
                      // setState(() {
                        
                        // _controller.clear();
                        _controller.text = '';
                        streamControllerText.add('');
                      // });
                    },
                    splashColor: null,
                    enableFeedback: false,
                  );
                }
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(width: 1.0,style: BorderStyle.solid)
              ),
              prefixIcon: Icon(Icons.search,
                color: Theme.of(context).accentColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              )
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: streamController.stream,
        builder: (context,snapshot){
            print('done');
            // print(snapshot.data);
            // print(snapshot.connectionState); 
              if(snapshot.hasData){
                switch (snapshot.data.length) {
                  case 0: return Container(
                      child: Center(child: Wrap(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(MaterialIcons.sentiment_neutral,size: 35.0,),
                                  SizedBox(width:10.0),
                                  Text('No post found for the\n following query.',
                                    textAlign: TextAlign.center,
                                    style:TextStyle(
                                      fontSize: 18.0
                                    )
                                  ),
                                ],
                              ),
                              Text('\nYou can search only with title, \nclub/entity, tags and\n council ( also short forms like snt ) of a post',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),),
                    );
                    break;
                    // snapshot.data = snapshot.data.reversed.toList();
                  default: return ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: snapshot.data.length,
                    // reverse: true,
                    itemBuilder: (context,index){
                      var i =  snapshot.data[index];
                      i.dateAsString = convertDateToString(DateTime.fromMillisecondsSinceEpoch(i.timeStamp));
                      if(snapshot.data.firstWhere((test){
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
                              child: PostTile(index,snapshot.data,widget.type),
                            )
                          ],
                        );
                      }else{
                        return Container(
                          key: ValueKey(i.timeStamp),
                            child: PostTile(index,snapshot.data,widget.type)
                        );
                      }
                    } 
                  );
                }
              }
              else{
                print('no datra');
                return Container(
                  child: Center(child: CircularProgressIndicator(),),
                );
              }
            //   break;
            // default: return Container(
            //   child: Center(child: CircularProgressIndicator(),),
            // );
          // }
        }
      ), 
    );
  }
  _searchPostFromString(String query){
    query = query!=null?query.toLowerCase():query;
    streamController.add(null);
    streamControllerText.add(query);
    // print('wuery $query');
    if(query == null ||query.isEmpty){
      // return Stream.fromIterable(widget.list);
      
      widget.list.sort((a,b)=>b.timeStamp.compareTo(a.timeStamp)); 
      setState(() {
        streamController.add(widget.list);
      });
      return;
    }else{
      widget.list.forEach((element){
        if(element.sub.toLowerCase().contains(query) 
          || element.title.toLowerCase().contains(query)  
          || element.council.toLowerCase().contains(query)
          || element.tags.toLowerCase().contains(query)
          || councilNameTOfullForms(element.council.toLowerCase()).toLowerCase().contains(query)){
            // print(true);
            array = updateDataInList(array, element);
            array.sort((a,b)=>b.timeStamp.compareTo(a.timeStamp)); 
            // streamController.sink.add(array);
          }
        else{
          array.removeWhere((test)=>test.id == element.id);
          
            array.sort((a,b)=>b.timeStamp.compareTo(a.timeStamp)); 
          
        }
      });
      // print('wuery ${widget.list}');
      streamController.add(array);
    }
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
    timer.cancel();
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
            return PostDescription(listOfPosts: postArray, type: 'display' + ' ${widget.type}',index: index,);
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