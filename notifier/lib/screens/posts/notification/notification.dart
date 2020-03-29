import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/posts/notification/not_info.dart';
import 'package:notifier/services/databse.dart';
import 'package:notifier/services/function.dart';

class MessageHandler extends StatefulWidget {
  final String uid;
  final Function loadSnt; 
  MessageHandler(this.uid,this.loadSnt);
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

List<SortDateTime> sortedarray = List();

class _MessageHandlerState extends State<MessageHandler> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  List<String> title = List();
  List<String> body = List();
  String display;
  String bodyMsg;
  String data;
  List<TableRow> tableRows = List();
  ScrollController _controller;
  bool newNotf = false;

  // bool load = true;
  void loadEVERY() async {
    // load = true;
    await procedure().then((var v) {
      print(v.toString() + ':procedure line29 notification.dart');
      if (v != null && v) {
        setState(() {
          addStringToSF(DateTime.now().toIso8601String());
          readContent('snt').then((var val) {
            print('snt values line34 of not.dart:' + val.toString());
            val.keys.forEach((key) {
              if (val[key]['exists'] == false) {
                // print('values whoose esists is false line46 not.dart:'+val[key].toString());
                // val.remove(key);
              } else {
                if (!sortedarray.contains(SortDateTime(
                    key,
                    DateTime.parse(val[key]['timeStamp'])
                        .toUtc()
                        .millisecondsSinceEpoch,
                    val[key]))) {
                  sortedarray.add(SortDateTime(
                      key,
                      DateTime.parse(val[key]['timeStamp'])
                          .toUtc()
                          .millisecondsSinceEpoch,
                      val[key]));
                }
              }
            });
          });
        });
      }

      // print(v);
    });
  }

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
    newNotf = false;
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage :$message" + ' isthe message');
        setState(() {
          // addStringToSF(DateTime.now().toIso8601String());
          widget.loadSnt();
          newNotf = true;
          bodyMsg = message['notification']['body'];
          data = message['data']['message'];
          display = message['notification']['title'];
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume : $message" + 'is fromResume');
        setState(() {
          // addStringToSF(DateTime.now().toIso8601String());
          // loadEVERY();
          newNotf = true;
          bodyMsg = message['notification']['body'];
          display = message['notification']['title'];
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message" + ':is fromLaunch');
        setState(() {
          // addStringToSF(DateTime.now().toIso8601String());
          // loadEVERY();
          newNotf = true;
          bodyMsg = message['notification']['body'];
          display = message['notification']['title'];
        });
        // onUpdate(prefsel)
      },
      // onBackgroundMessage: (Map<String,dynamic> message) async{
      //    print("onLaunch: $message"+ ':is fromLaunch');
      //    setState(() {
      //       bodyMsg = message['notification']['body'];
      //     display = message['notification']['title'];

      //   });
      // }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        newNotf
            ? Text('You May have new Notifications please pull to referesh')
            : Container(),
        Container(
            padding: newNotf ? EdgeInsets.only(top: 30.0) : null,
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
                controller: _controller,
                itemCount: sortedarray.length,
                itemBuilder: (BuildContext context, int index) {
                  // if(sortedarray[index]['uid'])
                  // print(sortedarray.length);
                  print(sortedarray[index].value['exists']);
                  return (sortedarray[index].value['exists'] == null ||
                          !sortedarray[index].value['exists'])
                      ? Container()
                      : Container(
                        margin:  const EdgeInsets.symmetric(horizontal: 16.0),
                          child: card(sortedarray[index].value, index),
                        );
                })),
      ],
    );
  }

  Widget card(timenot, index) {
    DateTime postTime= DateTime.parse(timenot['timeStamp']);
    var time;
  if(DateTime.now().day == postTime.day && DateTime.now().month == postTime.month && DateTime.now().year == postTime.year ){
     if( DateTime.now().hour == postTime.hour||(DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch)<3600000){
       switch (DateTime.now().minute - postTime.minute){
         case 0: 
           time = 'now';
         
         break;
         default: 
           var i = ((DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) /60000).round();
           time = '$i minutes ago';
        
       }
     }
     else{
       
       time = 'Today, '+DateFormat('kk:mm').format(postTime);
     
     }
    }
    else{
  
       time = DateFormat('d MMMM, yyyy : kk:mm')
        .format(postTime);
    
    }
    
    // print((DateTime.parse(timenot['timeStamp']));
    // print()
    // print(time);

    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          // return Description(index);
          return NotfDesc(index);
        }));
      },
      child: Card(
          elevation: 5.0,
          margin: EdgeInsets.symmetric(vertical: 16.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          clipBehavior: Clip.antiAlias,
          // child: Padding(
          // padding: const EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 0.0),
          child: Container(
              // height: 400.0,
              height:MediaQuery.of(context).size.height*0.76,
              // width: 500.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Hero(
                      tag: 'image$index',
                      child: CachedNetworkImage(
                        fit:BoxFit.fitWidth,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        imageUrl: timenot['url'],
                      ),
                      // child: Image.asset(
                      //   'assets/ECDC.jpg',
                      //   fit: BoxFit.fill,
                      // ),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0.0, 10.0, 10000.0, 0.0),
                      color: Colors.black.withOpacity(0.6),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          // color: Colors.black.withOpacity(0.6),
                          margin: const EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                // margin: const EdgeInsets.fromLTRB(
                                //     16.0, 0.0, 10.0, 0.0),
                                // padding: EdgeInsets.symmetric(horizontal: 10.0),

                                child: Text(
                                  timenot['title'],
                                  style: TextStyle(
                                      fontSize: 30.0, color: Colors.white),
                                ),
                              ),
                              Chip(
                                backgroundColor: Colors.green[900],
                                label: Row(
                                  children: <Widget>[
                                    // Icon(
                                    //   Icons.attachment,
                                    //   size: 20.0,
                                    // ),
                                    Text(
                                      timenot['sub'][0],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    // height: 300.0,
                    // bottom: 0.0,
                    // left: 20.0,
                    // width: 300.0,
                    // child: Align(
                      // alignment: Alignment.bottomLeft,
                      // child: ClipRect(
                        
                        child: Container(
                          // width:300.0,
                          // height: 40.0,
                          color: Colors.black.withOpacity(0.6),
                          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 1500.0, 10.0),
                          
                          child: Column(
                            
                            crossAxisAlignment: CrossAxisAlignment.start,
                            
                            children: <Widget>[
                               Container(
                                 padding: const EdgeInsets.fromLTRB(
                                      0.0, 5.0, 0.0, 0.0),
                                  child: Text(
                                    timenot['message'],
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              
                               Container(
                                  constraints: BoxConstraints(
                                    maxHeight: 100.0,
                                    minWidth: 300.0,
                                    maxWidth: 300.0),
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 5.0, 0.0, 0.0),
                                  child: Wrap(
                                    // child: Text('jhfgv')
                                    children: _buildChoice(timenot),
                                  ),
                                ),
                              Container(
                                // color: Colors.black.withOpacity(0.4),
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 15.0, 0.0, 0.0),
                                child: Text(
                                  time,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // ),
                    // ),
                  ),
                  // Positioned(
                  //     bottom: 40.0,
                  //     child: Container(
                  //       height:80.0,
                  //       width: 295.0,
                  //       // color: Colors.blue,
                  //       child: Wrap(
                  //         // child: Text('jhfgv')
                  //         children: _buildChoice(timenot),
                  //       ),
                  //     )),
                  // Align(
                  //   alignment:Alignment.bottomLeft
                  // )
                  // Positioned(
                  //   bottom: 10.0,
                  //   child: Container(
                  //     color: Colors.black.withOpacity(0.4),
                  //      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 0.0),
                  //     child: Text(time,style: TextStyle(
                  //              color: Colors.white),
                  //       ),),
                  // )
                ],
              )
              // )
              )),
    );
  }

  _buildChoice(timenot) {
    List<Widget> _tag = List();
    // List<String> tags = timenot['tags'];
    _tag.add(
      Text('Tags : ', style: TextStyle(color: Colors.white, fontSize: 15.0)),
    );
    for (var i in timenot['tags']) {
      var index = timenot['tags'].indexOf(i);
      if (index != (timenot['tags'].length - 1)) {
        _tag.add(
          ConstrainedBox(
              constraints: BoxConstraints(
                  // maxWidth: 120.0,
                  minWidth: 50.0),
              // padding: const EdgeInsets.all(2.0),
              child: Text(i + ' ,', style: TextStyle(color: Colors.white))),
        );
      } else {
        _tag.add(
          ConstrainedBox(
              constraints: BoxConstraints(
                  // maxWidth: 120.0,
                  minWidth: 50.0),
              // padding: const EdgeInsets.all(2.0),
              child: Text(i, style: TextStyle(color: Colors.white))),
        );
      }
    }
    return _tag;
  }
}

class Description extends StatefulWidget {
  final int index;
  Description(this.index);
  @override
  _DescriptionState createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(sortedarray[widget.index].value['title'])),
      body: Container(
        // color:Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              top: 20.0,
              child: Container(
                // padding: EdgeInsets.symmetric(horizontal: 20.0),
                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.only(
                //         bottomLeft: Radius.circular(16.0),
                //         bottomRight: Radius.circular(16.0)),
                // color: Colors.black),
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                child: Hero(
                    tag: 'image$widget.index',
                    // child: Image.asset(
                    //   'assets/ECDC.jpg',
                    //   fit: BoxFit.fill,
                    //   // height: MediaQuery.of(context).size.height * 0.5,
                    // ),
                    child: CachedNetworkImage(
                      fit: BoxFit.fitWidth,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      imageUrl: sortedarray[widget.index].value['url'],
                       errorWidget: (context, url, error) => Icon(Icons.error),
                    )),
                //     child: Image(
                // image: CachedNetworkImageProvider(
                //   sortedarray[widget.index].value['url'],
                // ),
                //     ),
                // ),
              ),
            ),
           
            Positioned(
              top: MediaQuery.of(context).size.height * 0.31,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black.withOpacity(0.6)),
            ),
            Positioned(
                left: 20.0,
                top: MediaQuery.of(context).size.height * 0.315,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      sortedarray[widget.index].value['title'],
                      style: TextStyle(color: Colors.white, fontSize: 35.0),
                    ),
                    Text(sortedarray[widget.index].value['sub'][0],
                        style: TextStyle(color: Colors.white, fontSize: 20.0)),
                  ],
                )),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.44,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0))),
                  elevation: 6.0,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0)),
                        // color: Colors.yellow),
                      ),
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: MediaQuery.of(context).size.width - 16.0,
                      child: ListView(
                        padding: EdgeInsets.only(top: 8.0),
                        children: <Widget>[
                          Wrap(
                            children:
                                _buildChoice(sortedarray[widget.index].value),
                          ),
                          Text(sortedarray[widget.index].value['message'],
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.black)),
                          SizedBox(height: 20.0),
                          Title(
                              child: Text(
                                sortedarray[widget.index].value['body'],
                                style: TextStyle(
                                  fontSize: 20.0,
                                  // color:Colors.white
                                ),
                              ),
                              color: Colors.white),
                        ],
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildChoice(timenot) {
    List<Widget> _tag = List();
    // List<String> tags = timenot['tags'];
    for (var i in timenot['tags']) {
      _tag.add(Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 120.0,
          ),
          child: Chip(
            backgroundColor: Colors.teal[900],
            label: Text(i.toString(), style: TextStyle(color: Colors.white)),
          ),
        ),
      ));
    }

    return _tag;
  }
}

// class Description extends StatelessWidget {
//   final int index;
//   Description(this.index);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: CustomScrollView(
//           slivers:<Widget> [
//             SliverAppBar(
//           // title: Text(sortedarray[index]['title']),
//           expandedHeight: MediaQuery.of(context).size.height*0.7,
//           // floating :false,
//           pinned: true,
//           // bottom: ,
//           flexibleSpace: FlexibleSpaceBar(
//             // collapseMode: Col,
//             title: Container(
//               // color: Colors.black.withOpacity(0.4),
//               child: Text(sortedarray[index].value['title'])),
//             background: Container(
//             // height: 250.0,
//             // width: 300.0,
//             child: sortedarray[index].value['url'] == 'url'
//                 ? Hero(
//                     tag: 'image$index',
//                     // child: Image.network(
//                     //   sortedarray[index]['url'],
//                     //   fit: BoxFit.fill,
//                     // ),
//                     child: Image.asset(
//                       'assets/ECDC.jpg',
//                       fit: BoxFit.fill,
//                     ),
//                   )
//                 : Container()),
//           ),
//             ),
//             SliverFillRemaining(
//               child: Container(
//           alignment: Alignment.bottomCenter,
//           color: Colors.white70,
//           child: Column(
//             children: <Widget>[
//               Text(sortedarray[index].value['title']),
//               Row(children: <Widget>[
//                 for (var i in sortedarray[index].value['tags']) Text(i),
//               ])
//             ],
//           ),
//         )
//             ),
//           ]

//       //   ListView(
//       // children: <Widget>[
//       //   Container(
//       //       height: 250.0,
//       //       width: 300.0,
//       //       child: sortedarray[index]['url'] == 'url'
//       //           ? Hero(
//       //               tag: 'image$index',
//       //               // child: Image.network(
//       //               //   sortedarray[index]['url'],
//       //               //   fit: BoxFit.fill,
//       //               // ),
//       //               child: Image.asset(
//       //                 'assets/ECDC.jpg',
//       //                 fit: BoxFit.fill,
//       //               ),
//       //             )
//       //           : Container()),
//       //   Container(
//       //     alignment: Alignment.bottomCenter,
//       //     color: Colors.white70,
//       //     child: Column(
//       //       children: <Widget>[
//       //         Text(sortedarray[index]['title']),
//       //         Row(children: <Widget>[
//       //           for (var i in sortedarray[index]['tags']) Text(i),
//       //         ])
//       //       ],
//       //     ),
//       //   )
//       // ],
//     ));
//   }
// }
