import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/posts/create_edit_posts.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';

class PostList extends StatelessWidget {
  final String type;
  final String id;
  final List<dynamic> prefs;
  PostList(this.type,this.id,this.prefs);
  @override
  Widget build(BuildContext context) {
    if (allCouncilData.coordOfCouncil.length == 1) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            type.toLowerCase() == 'update' ?
              type[0].toUpperCase() + type.substring(1).toLowerCase() + ' Posts'
              : type[0].toUpperCase() + type.substring(1).toLowerCase()
          ),
          centerTitle: true,
        ),
        body: buildList(allCouncilData.coordOfCouncil[0]),
      );
    } else {
      return DefaultTabController(
        length: allCouncilData.coordOfCouncil.length, 
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              type.toLowerCase() == 'update' ?
              type[0].toUpperCase() + type.substring(1).toLowerCase() + ' Posts'
              : type[0].toUpperCase() + type.substring(1).toLowerCase()
            ),
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                for (var i in allCouncilData.coordOfCouncil)
                  Tab(text: convertToCouncilName(i),)
              ]
            ),
          ),
          body: TabBarView(
            children: [
              for (var i in allCouncilData.coordOfCouncil)
                buildList(i)
            ]
          ),
        )
      );
    }
  }
  Widget buildList(String council) {
    print(council);
    final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
    return FutureBuilder(
      future: type.toLowerCase() == 'update'?
        DBProvider().getAllPostswithQuery(GetPosts(queryColumn: 'council', queryData: council,id: id),orderBy: "timeStamp DESC")
          : DatabaseProvider(databaseName: 'drafts',tableName: 'Drafts').getAllPostswithQuery(GetPosts(queryColumn: 'council', queryData: council),orderBy: "timeStamp DESC"),
      builder: (context,snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if(snapshot != null && snapshot.data !=null && snapshot.data.length == 0){
              String text = allCouncilData.coordOfCouncil.length ==1 ?'try creating one': 'under this council';
              return Container(
                child: Center(
                  child: Text(
                    type.toLowerCase() == 'update'? 'You have not made any post ' + text 
                    :
                    'You have not saved any post $text'),),);
            }else{
              return AnimatedList(
                key: _listKey,
                initialItemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, index,animation) {
                  var arrayOfPosts = snapshot.data.toList();
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Dismissible(
                      movementDuration: Duration(milliseconds:30),
                      resizeDuration: Duration(milliseconds: 60),
                      dismissThresholds: {DismissDirection.endToStart : 0.8},
                      background: Card(
                        color: Colors.red,
                        margin: index==0? EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0)
                        : EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
                              'Delete',
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
                      confirmDismiss: (DismissDirection direction){
                        return confirmDismissDialog(arrayOfPosts[index],_listKey,index,context);
                      },
                      child: Card(
                        elevation: 5.0,
                      margin: index==0? EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0)
                        : EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.0),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                      return CreateEditPosts(type, index, arrayOfPosts[index]); 
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
                },
              );
            }
            break;
          default: return Center(child: CircularProgressIndicator(),);
        }
      }
    );
  }
  confirmDismissDialog(PostsSort postsSort,_listKey,int index,context) {
    return showDialog<bool>(
      barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  Text(
                    ' Delete this Post ?',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              content: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      type.toLowerCase() == 'update' ?
                      'Doing this will remove this post for everyone'
                     : 'Doing this will permanently delete this file',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                        'Note: You will not be able to recover this file later',
                        style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              return false;
                            },
                            child: Text('Dismiss'),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Container(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            onPressed: () async {
                              // a
                              showInfoToast('Deleting post');
                              Navigator.pop(context);
                              _listKey.currentState.removeItem(
                                index,
                                (BuildContext context,Animation<double> animation){
                                  return Container();
                                }
                              );
                              if(type.toLowerCase() == 'drafts'){
                                return await deletePostFromList(postsSort).then((bool status){
                                  if(status){
                                    showSuccessToast('Draft deleted successfully');
                                    return true;
                                  }else{
                                    showErrorToast('An error occurred while deleteing this post');
                                    _listKey.currentState.insertItem(index);
                                    return false;
                                  }
                                });
                              }
                              else{
                                Response res = await deletePost(
                                  postsSort
                                );
                                if (res.statusCode == 200) {
                                  DBProvider().deletePost(postsSort.id);
                                  showSuccessToast('Deleted post successfully');
                                  return true;
                                  // return writeContent('people', json.encode(widget.peopleData));
                                } else {
                                  // setState(() {
                                  //   _loadingDelete = false;
                                  // });
                                  showErrorToast('An error occurred while deleteing this post');
                                  _listKey.currentState.insertItem(index);
                                  return false;
                                  // Navigator.pop(context);
                                }
                              }
                            },
                            child: Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  ]));
        });
  }
  Future<bool> deletePostFromList(PostsSort postsSort)async{
    if (postsSort.url != null) {
      clearSelection(postsSort.url);
    }
    return await DatabaseProvider(databaseName: 'drafts',tableName: 'Drafts').deletePost(postsSort.id).then((changes){
      if(changes!=0){
        return true;
      }else{
        return false;
      }
    });
  }
  Future<bool> clearSelection(String url) async {
    try {
      StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl(url);
      return await storageReference.delete().then((_) {
        return true;
      }).catchError((onError){
        print(onError);
        // showErrorToast('Failed!!!');
        return false;
      });
    // StorageUploadTask uploadTask = storageReference.putFile(_image);
  
    } catch (e) {
      print(e);
      return false;
    }
}
}