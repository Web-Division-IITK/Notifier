import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/posts/notification/not_info.dart';
import 'package:notifier/services/databse.dart';
import 'package:notifier/services/function.dart';

List<SortDateTime> sortedarray = List();
class MessageHandlerNotf extends StatefulWidget {
  final String uid;
  final Function loadSnt; 
  MessageHandlerNotf(this.uid,this.loadSnt);
  @override
  _MessageHandlerNotfState createState() => _MessageHandlerNotfState();
}

class _MessageHandlerNotfState extends State<MessageHandlerNotf> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  List<String> title = List();
  List<String> body = List();
  
  List<TableRow> tableRows = List();
  ScrollController _controller;
  bool newNotf = false;
  List<int> indices =[];

  // bool load = true;
  // void loadEVERY() async {
  //   // load = true;
  //   await procedure().then((var v) {
  //     print(v.toString() + ':procedure line29 notification.dart');
  //     if (v != null && v) {
  //       setState(() {
  //         addStringToSF(DateTime.now().toIso8601String());
  //         readContent('snt').then((var val) {
  //           print('snt values line34 of not.dart:' + val.toString());
  //           val.keys.forEach((key) {
  //             if (val[key]['exists'] == false) {
  //               // print('values whoose esists is false line46 not.dart:'+val[key].toString());
  //               // val.remove(key);
  //             } else {
  //               if (!sortedarray.contains(SortDateTime(
  //                   key,
  //                   DateTime.parse(val[key]['timeStamp'])
  //                       .toUtc()
  //                       .millisecondsSinceEpoch,
  //                   val[key]))) {
  //                 sortedarray.add(SortDateTime(
  //                     key,
  //                     DateTime.parse(val[key]['timeStamp'])
  //                         .toUtc()
  //                         .millisecondsSinceEpoch,
  //                     val[key]));
  //               }
  //             }
  //           });
  //         });
  //       });
  //     }

  //     // print(v);
  //   });
  // }

  // @override
  // void initState() {
  //   _controller = ScrollController();
  //   super.initState();
  //   newNotf = false;
  //   _fcm.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       print("onMessage :$message" + ' isthe message');
  //       setState(() {
  //         // addStringToSF(DateTime.now().toIso8601String());
  //         widget.loadSnt();
  //         newNotf = true;
  //         bodyMsg = message['notification']['body'];
  //         data = message['data']['message'];
  //         display = message['notification']['title'];
  //       });
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       print("onResume : $message" + 'is fromResume');
  //       setState(() {
  //         // addStringToSF(DateTime.now().toIso8601String());
  //         // loadEVERY();
  //         newNotf = true;
  //         bodyMsg = message['notification']['body'];
  //         display = message['notification']['title'];
  //       });
  //     },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       print("onLaunch: $message" + ':is fromLaunch');
  //       setState(() {
  //         // addStringToSF(DateTime.now().toIso8601String());
  //         // loadEVERY();
  //         newNotf = true;
  //         bodyMsg = message['notification']['body'];
  //         display = message['notification']['title'];
  //       });
  //       // onUpdate(prefsel)
  //     },
  //     // onBackgroundMessage: (Map<String,dynamic> message) async{
  //     //    print("onLaunch: $message"+ ':is fromLaunch');
  //     //    setState(() {
  //     //       bodyMsg = message['notification']['body'];
  //     //     display = message['notification']['title'];

  //     //   });
  //     // }
  //   );
  // }
  Iterable<Widget> get arrayofTime sync*{
    // indices.add(sortedarray.indexOf(sortedarray.iterator.current));
    for (var i in sortedarray) {
      if(!indices.contains(sortedarray.indexOf(i))){
        indices.add(sortedarray.indexOf(i));
      }
      DateTime postTime = DateTime.parse(i.value['timeStamp']);
      var time;var day;
      // var dayTime = DateFormat('d mm yyyy').format;
      if (DateTime.now().day == postTime.day && DateTime.now().month == postTime.month && DateTime.now().year == postTime.year) {
                if (DateTime.now().hour == postTime.hour ||
                    (DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) < 3600000) {
                  switch (DateTime.now().minute - postTime.minute) {
                    case 0:
                      time = 'now';
                      day = 'Today';
                      break;
                    default:
                      var i = ((DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) /60000)
                          .round();
                      time = '$i minutes ago';
                      day = 'Today';
                  }
                } else {
                  time = DateFormat('kk:mm').format(postTime);
                  day = 'Today';
                }
              } else {
                time = DateFormat('d MMMM, yyyy : kk:mm').format(postTime);
                day = DateFormat('d MMMM, yyyy').format(postTime);
              }
      switch(i.dateasString){
        case 'Today':{
          if (sortedarray.firstWhere((test){
            return (test.dateasString == 'Today' && (test.value['exists'] == null || test.value['exists']))?
            true : false;
          }) == i) {
            yield Column(
               children: <Widget>[
                 Container(child: Text('Today'),),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    )
               ],
             );
          } else {
            yield (i.value['exists'] == null ||
                      !i.value['exists'])
                  ? Container()
                  // : time ==  ?
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    );
          }
        } 
          break;
        case 'Yesterday' : {
          if (sortedarray.firstWhere((test){
            return (test.dateasString == 'Yesterday' && (test.value['exists'] == null || test.value['exists']))?true:false;
          }) == i) {
             yield Column(
               children: <Widget>[
                 Container(child: Text('Yesterday'),),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    )
               ],
             );
          } else {
            yield (i.value['exists'] == null ||
                      !i.value['exists'])
                  ? Container()
                  // : time ==  ?
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    );
          }
        }
          break;
        default: if (sortedarray.firstWhere((test){
          return (test.dateasString == day && (test.value['exists'] == null || test.value['exists']))?true:false;
        }) == i) {
          yield Column(
               children: <Widget>[
                 Container(child: Text(day),),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    )
               ],
             );
        } else {
          yield (i.value['exists'] == null ||
                      !i.value['exists'])
                  ? Container()
                  // : time ==  ?
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    );
        }
        break;
      } 
    }
  }
  @override
  Widget build(BuildContext context) {
    return 
        Container(
            padding: EdgeInsets.only(top: 10.0) ,
            child: ListView(
              children: arrayofTime.toList(),
            )
            // child: ListView.builder(
            //   physics: AlwaysScrollableScrollPhysics(),
            //     controller: _controller,
            //     itemCount: sortedarray.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       // if(sortedarray[index]['uid'])
            //       // print(sortedarray.length);
            //       DateTime postTime = DateTime.parse(sortedarray[index].value['timeStamp']);
            // var time;
            // var day;
            // if (DateTime.now().day == postTime.day && DateTime.now().month == postTime.month && DateTime.now().year == postTime.year) {
            //   if (DateTime.now().hour == postTime.hour || (DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) < 3600000) {
            //     switch (DateTime.now().minute - postTime.minute) {
            //       case 0:
            //         time = 'now';
            //         day = 'Today';
            //         break;
            //       default:
            //         var i = ((DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) /60000).round();
            //         time = '$i minutes ago';
            //         day = 'Today';
            //     }
            //   } else {
            //     time = 'Today, ' + DateFormat('kk:mm').format(postTime);
            //     day = 'Today';
            //   }
            // } else {
            //   time = DateFormat('d MMMM, yyyy : kk:mm').format(postTime);
            //   day = DateFormat('d MMMM, yyyy').format(postTime);
            // }
            // return (sortedarray[index].value['exists'] == null ||
            //         !sortedarray[index].value['exists'])
            //     ? Container()
            //     // : time ==  ? 
            //     :Container(
            //         margin: const EdgeInsets.symmetric(horizontal: 16.0),
            //         child: tile(sortedarray[index].value, index,time),
            //       );
            //     })
            );
     
  }
  Widget tile(timenot, index,time) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          return Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return NotfDesc(index,indices,time);
          }));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              child: AutoSizeText(timenot['sub'][0],
                  // 'Science and Texhnology Council',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.blueGrey
                        : Colors.white70,
                    // fontWeight: FontStyle.italic,
                    fontSize: 13.0,
                  )),
            ),
            Container(
              // alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
              child: AutoSizeText(timenot['title'],
                  // 'Sit commodo fugiat duis consectetur sunt ipsum cupidatat adipisicing mollit et magna duis.',
                  minFontSize: 18.0,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  )),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
              child: AutoSizeText(
                timenot['message'],
                // 'Dolor consectetur in dolore anim reprehenderit velit pariatur veniam nostrud id ex exercitation.',
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16.0,
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
                    fontSize: 10.0,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey
                        : Colors.white70,
                  ),
                )),
          ],
        ),
      ),
    );}
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
          return NotfDesc(index,indices,time);
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
              width:double.infinity,
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
                      // width: double.infinity,
                      padding: EdgeInsets.fromLTRB(0.0, 10.0,10000.0, 0.0),
                      color: Colors.black.withOpacity(0.6),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          // color: Colors.black.withOpacity(0.6),
                          margin: const EdgeInsets.fromLTRB(16.0, 5.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width -64.0,
                                constraints: BoxConstraints(
                                  maxHeight: 60.0
                                ),
                                // margin: const EdgeInsets.fromLTRB(
                                //     16.0, 0.0, 10.0, 0.0),
                                // padding: EdgeInsets.symmetric(horizontal: 10.0),

                                // child: FittedBox(
                                //   alignment: Alignment.topLeft,
                                //   fit: BoxFit.scaleDown,
                                  child: AutoSizeText(
                                    timenot['title'],
                                    maxLines:2,
                                    style: TextStyle(
                                        fontSize: 30.0, color: Colors.white),
                                  ),
                                // ),
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
                                 constraints: BoxConstraints(
                                   minHeight: 30.0

                                 ),
                                 width: MediaQuery.of(context).size.width - 64.0,
                                 padding: const EdgeInsets.fromLTRB(
                                      0.0, 5.0, 0.0, 0.0),
                                  child: AutoSizeText(
                                    timenot['message'],
                                    // 'LoremReprehenderit aliquip do deserunt quis enim.Aute enim quis est incididunt.',
                                    maxFontSize: 20.0,
                                    minFontSize: 15.0,
                                    maxLines:2,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                      
                                    ),
                                  ),
                                ),
                              
                               Container(
                                  constraints: BoxConstraints(
                                    maxHeight: 100.0,
                                    // minWidth: 300.0,
                                    maxWidth: MediaQuery.of(context).size.width -60.0
                                    ),
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 5.0, 0.0, 0.0),
                                  // child: ListView.builder(
                                  //   scrollDirection: Axis.horizontal,
                                  //   itemCount: timenot['tags'].length,
                                  //   itemBuilder: (BuildContext context,int index){
                                  //     return  AutoSizeText(
                                  //   // 'Consequat excepteur ',
                                  //   timenot['tags'][index],
                                  //   style: TextStyle(color: Colors.white),
                                  //   maxLines: 3,
                                  //   // minFontSize: 8.0,
                                  //   // maxFontSize: ,
                                  // );
                                  //   })
                                  
                                  // child: AutoSizeText(
                                  //   'Consequat excepteur ',
                                  //   style: TextStyle(color: Colors.white),
                                  //   maxLines: 3,
                                  //   // minFontSize: 8.0,
                                  //   // maxFontSize: ,
                                  // )
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
    // timenot['tags'] = ['lecture','hello','juke','nbvjvj','jhhgv','ghgffhgf','hjfjhgfghfcgjc','hjgj','vdgc'];
    _tag.add(
      Text('Tags : ', style: TextStyle(color: Colors.white, fontSize: 15.0)),
    );
    for (var i in timenot['tags']) {
      var index = timenot['tags'].indexOf(i);
      if (index != (timenot['tags'].length - 1)) {
        _tag.add(
          Text(timenot['tags'][index] + ' , ', style: TextStyle(color: Colors.white)),
        );
      } else {
        _tag.add(
           Text(i, style: TextStyle(color: Colors.white)),
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
