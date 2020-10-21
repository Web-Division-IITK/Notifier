import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/widget/showtoast.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime time = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(title: Text("Events")),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.add),
          ),
          body: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(
                    DateTime.now().year - 10,
                  ),
                  lastDate: DateTime(DateTime.now().year + 30),
                  onDateChanged: (dateTime) {
                    setState(() {
                      time = dateTime;
                    });
                  },
                  currentDate: DateTime.now(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0,left: 16,bottom: 10),
                child: Text(
                  "Personal Events",
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.left,
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16.0, 0, 16, 0),
                  child: FutureBuilder(
                      future: /* Future.sync(() => (*/
                          DatabaseProvider().getAllPostswithDate(time),
                      // )),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            List<PostsSort> array =
                                (snapshot == null || snapshot.data == null)
                                    ? []
                                    : snapshot.data;
                            if (array.length == 0) {
                              return Container(
                                height: 80.0,
                                child: Center(
                                  child: Text('No post available right now'),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                displayCalendarContent(array),
                                Container(
                                    padding: EdgeInsets.only(bottom: 8),
                                    alignment: Alignment.bottomRight,
                                    child: RichText(
                                        text: TextSpan(
                                            text: "See All ...",
                                            style: TextStyle(
                                                fontFamily: "Raleway",
                                                fontSize: 12.0,
                                                color: Colors.blue),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Navigator.of(context).push(MaterialPageRoute(
                                                //       //   builder: (BuildContext context) {
                                                //       //     return AllPostGetData(widget.userModel);}));
                                              }))),
                              ],
                            );
                            break;
                          default:
                            return Container(
                                height: 80,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ));
                        }
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16,left: 16,bottom: 10),
                child: Text(
                  "My Events",
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.left,
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16.0, 0, 16, 0),
                  child: FutureBuilder(
                      future: /* Future.sync(() => (*/
                          DatabaseProvider().getAllPostswithDate(time),
                      // )),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            List<PostsSort> array =
                                (snapshot == null || snapshot.data == null)
                                    ? []
                                    : snapshot.data;
                            if (array.length == 0) {
                              return Container(
                                height: 80.0,
                                child: Center(
                                  child: Text('No post available right now'),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                displayCalendarContent(array),
                                Container(
                                    padding: EdgeInsets.only(bottom: 8),
                                    alignment: Alignment.bottomRight,
                                    child: RichText(
                                        text: TextSpan(
                                            text: "See All ...",
                                            style: TextStyle(
                                                fontFamily: "Raleway",
                                                fontSize: 12.0,
                                                color: Colors.blue),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Navigator.of(context).push(MaterialPageRoute(
                                                //       //   builder: (BuildContext context) {
                                                //       //     return AllPostGetData(widget.userModel);}));
                                              }))),
                              ],
                            );
                            break;
                          default:
                            return Container(
                                height: 80,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ));
                        }
                      }),
                ),
              )
            ],
          )),
    );
  }

  void student() async {
    await DatabaseProvider().getAllPosts().then((value) {
      value.forEach((element) {
        // element.startTime
      });
    });
  }

  Widget displayCalendarContent(List<PostsSort> array) {
    return ListView.builder(
        // padding: EdgeInsets.only(top: 16),
        shrinkWrap: true,
        itemCount: array.length > 1 ? 1 : array.length,
        itemBuilder: (content, index) {
          return Container(
              // child: StreamBuilder(
              //   stream: Stream.periodic(Duration(minutes: 1)),
              //   builder: (context, snapshot) {
              child: Tile(
            key: ValueKey(DateTime.now().millisecondsSinceEpoch),
            index: index,
            arrayWithPrefs: array,
          )
              //   }
              // ),
              );
        });
  }
}

class Tile extends StatefulWidget {
  final int index;
  final List<PostsSort> arrayWithPrefs;
  Tile({key, this.index, /*this.time,*/ this.arrayWithPrefs /*,this.stream*/})
      : super(key: key);
  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<Tile> {
  // Timer timer;
  var time;
  @override
  void initState() {
    super.initState();
    var timeStamp = DateTime.fromMillisecondsSinceEpoch(
        widget.arrayWithPrefs[widget.index].timeStamp);
    time = DateFormat("hh:mm a, dd MMMM yyyy").format(timeStamp);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () async {
          return await Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return FeatureDiscovery(
                child: PostDescription(
              listOfPosts: widget.arrayWithPrefs,
              type: 'display',
              index: widget.index,
            ));
          }));
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 15.0,
              right: 0.0,
              child: IconButton(
                  tooltip: 'Save Post',
                  icon: widget.arrayWithPrefs[widget.index].bookmark
                      ? Icon(MaterialIcons.bookmark)
                      : Icon(MaterialIcons.bookmark_border),
                  onPressed: () async {
                    setState(() {
                      widget.arrayWithPrefs[widget.index].bookmark =
                          !widget.arrayWithPrefs[widget.index].bookmark;
                    });
                    // DataHolderAndProvider.of(context).data.value.globalPostMap[widget.arrayWithPrefs[index].id].bookmark = false ;
                    // DataHolderAndProvider.of(context).data.value.globalPostsArray.firstWhere((test) => test.id == widget.arrayWithPrefs[index].id).bookmark = false ;
                    // DataHolderAndProvider.of(context).data.refresh();
                    await DBProvider().updateQuery(GetPosts(
                        queryColumn: 'bookmark',
                        queryData: (widget.arrayWithPrefs[widget.index].bookmark
                            ? 1
                            : 0),
                        id: widget.arrayWithPrefs[widget.index].id));
                    if (widget.arrayWithPrefs[widget.index].bookmark == true) {
                      showSuccessToast('Bookmarked');
                    } else {
                      // showInfoToast('Removed From Saved');
                    }
                    // printPosts(await DBProvider().getPosts(GetPosts(queryColumn: 'id',queryData: widget.arrayWithPrefs[widget.index].id)));
                  }),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: AutoSizeText(widget.arrayWithPrefs[widget.index].sub,
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
                      maxWidth: MediaQuery.of(context).size.width - 90),
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
