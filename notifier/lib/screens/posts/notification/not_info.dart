

// import 'dart:html';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:notifier/screens/posts/notification/notification.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class NotfDesc extends StatefulWidget {
  final int index;
  final List <int> indices;
  final String timeStamp;
  NotfDesc(this.index,this.indices,this.timeStamp);
  @override
  _NotfDescState createState() => _NotfDescState();
}

class _NotfDescState extends State<NotfDesc> {
  PageController _controller;
  @override
  void initState() { 
    _controller = PageController(
      initialPage: widget.indices.indexOf(widget.index),
    );
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  var position;
  @override
  Widget build(BuildContext context) {
    // print(widget.indices);
    return PageView.builder(
      controller: _controller,
      onPageChanged: (index){
        setState(() {
          position = widget.indices[index];
        });
      },
      itemCount: widget.indices.length,
      itemBuilder: (context,index){
        DateTime postTime = DateTime.parse(sortedarray[widget.indices[index]].value['timeStamp']);
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
                  time = DateFormat('h:mm a').format(postTime);
                  day = 'Today';
                }
              } else {
                time = DateFormat('h:mm a: d MMMM, yyyy').format(postTime);
                day = DateFormat('d MMMM, yyyy').format(postTime);
              }
      return Scaffold(
        // appBar: AppBar(title: Text(sortedarray[widget.index].value['title'])),
        body: ListView(
          children: <Widget>[
            Card(
              elevation: 0.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Hero(
                        tag: 'image' + widget.indices[index].toString(),
                        child:sortedarray[widget.indices[index]].value['url']==null ||sortedarray[widget.indices[index]].value['url'] == ''?
                        Container():
                         CachedNetworkImage(
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                              Container(height:200.0,
                                child: Center(child: CircularProgressIndicator())),
                          imageUrl: sortedarray[widget.indices[index]].value['url'],
                          // cacheManager:CacheStorage,
                          errorWidget: (context, url, error) => Container(height:200.0,
                          child: Center(child: Text('Error loading Image',
                            style: TextStyle(
                              color:Colors.red
                            ),
                          ),)
                          ),
                        )),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: (){
                        Navigator.pop(context);
                      },  
                    )
                  )
                ],
              ),
            ),
            
                Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    margin: EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 10.0),
                    child: Stack(
                        children: <Widget>[
                          // Positioned(
                          //   right: 0.0,
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(top:8.0,right: 16.0),
                          //     child: Text(time,
                          //       style: TextStyle(
                          //         fontSize: 12.0,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Container(
                      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 30.0),
                      child: 
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                // alignment: Alignment.center,
                                child: AutoSizeText(
                                  sortedarray[widget.indices[index]].value['title'],
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 35.0),
                                ),
                              ),
    /*                      Center(
                                child:*/ Text(sortedarray[widget.indices[index]].value['sub'][0],
                                    // 'Science and Technology Council',
                                    style: TextStyle(fontSize: 20.0)),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(top:8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  children: _buildChoice(sortedarray[widget.indices[index]].value),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top:16.0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right:8.0),
                                      child: Icon(Icons.calendar_today,
                                        size: 30.0,
                                      ),
                                    ),
                                    Text(DateFormat("dd MMMM yyyy").format(DateTime.now())),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top:16.0),
                                child: Linkify(
                                  // data:
                                  text: sortedarray[widget.indices[index]].value['body'],
                                  // options: LinkifyOptions(humanize: false),
                                  // onTap: ,
                                  onOpen:_onOpen,
                                    // if(u.url is UrlElement){
                                    // _launchUrl(u.url);
                                    // }
                                  // },
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      // color:Colors.white
                                      ),
                                  // linkStyle: TextStyle(
                                  //   color: Colors.blue,
                                  // ),
                                ),
                              ),
                              // Text(sortedarray[widget.indices[index]].value['message'],
                              //     style: TextStyle(
                              //         fontSize: 30.0, color: Colors.black)),
                              // SizedBox(height: 20.0),
                              // Text(
                              //       sortedarray[widget.indices[index]].value['body'],
                              //       style: TextStyle(
                              //         fontSize: 20.0,
                              //         // color:Colors.white
                              //       ),
                              // ),
                              // RaisedButton(
                              //   onPressed: () {
                              //     _launchUrl('https://www.wikipedia.com');
                              //   },
                              //   child: Text('hello'),
                              // )
                            ],
                          ),
                        
                      
                    )
                        ]
                )),
              ],
            )
        //   ],
        // ),
      );
      }
    );
  }
  Future<void> _onOpen(LinkableElement link) async {
    print(link.url);
    if(link.url.startsWith('https://') || link.url.startsWith('http://')){
      print('islink');
      if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
    }
    // else if(link.url.contains('mailto:')){
    //   var url = link.url;
    //   print(link.url);
      
    //    if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $link';
    // }
    // }
    // else{
    //   var url = "tel:$link.url";   
    // if (await canLaunch(url)) {
    //    await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // } 
    // }
    
  }
  Future<void> launchCaller(String number) async {
    var url = "tel:$number";   
    if (await canLaunch(url)) {
       await launch(url);
    } else {
      throw 'Could not launch $url';
    }   
}
launchMail(String mailId) async{
  var url = "mailto:$mailId?subject=<subject>&body=<body>";
  if(await canLaunch(url)){
    await launch(url);
  }else{
    throw 'Couldn\'t mail this time';
  }
}


  _buildChoice(timenot) {
    List<Widget> _tag = List();
    // List<String> tags = timenot['tags'];
    print(timenot['tags']);
    if(timenot['tags']!=null){
      for (var i in timenot['tags']) {
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
    }else{
      _tag.add(Container());
    }

    return _tag;
  }
}

_launchUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
// class NotfUpdate extends StatefulWidget {
//   final int index;
//   final timenots;
//   NotfUpdate(this.timenots,this.index);
//   @override
//   _NotfUpdateState createState() => _NotfUpdateState();
// }

// class _NotfUpdateState extends State<NotfUpdate> {
//   double boxHeigth ;
//    PanelController _panelController = PanelController();
//   @override
//   Widget build(BuildContext context) {
//     boxHeigth =  MediaQuery.of(context).size.height*0.8;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         // backgroundColor: Colors.white,
//         // elevation: 0.0,
//         // centerTitle: true,
//         title:
//            Text(widget.timenots['title']),
//           // style: TextStyle(color: postitiveColor),

//       ),
//       body: SlidingUpPanel(
//         parallaxEnabled: true,
//         parallaxOffset: 1.0,
//         // isA
//         controller: _panelController,
//         slideDirection: SlideDirection.DOWN,
//         borderRadius: BorderRadius.circular(16.0),
//         // renderPanelSheet: false,
//         minHeight: MediaQuery.of(context).size.height*0.8,
//         maxHeight: MediaQuery.of(context).size.height*0.5,
//         // panel: Text(widget.timenots['title']),
//         // panelBuilder: (BuildContext context){
//           isDraggable: true,
//         // },
//         // renderPanelSheet: false,
//         onPanelSlide: (v){
//           setState(() {
//             boxHeigth = MediaQuery.of(context).size.height * (0.8 - v*0.3);
//             // print(boxHeigth);
//           });
//         },
//         panel: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16.0),
//             color: Colors.black
//           ),
//           height: this.boxHeigth,
//       // width: MediaQuery.of(context).size.width,
//       // child: Image.asset(
//       //                   'assets/ECDC.jpg',
//       //                   fit: BoxFit.fill,
//       //                 ),
//     ),
//         body: Container()
//       )
//     );
//   }
// }

// class CustomSlider extends StatelessWidget {
//   // double totalWidth = 200.0;
//   // double percentage;
//   // Color positiveColor;
//   // Color negetiveColor;
//   double location;

//   CustomSlider({this.location});

//   @override
//   Widget build(BuildContext context) {
//     // print((percentage / 100) * totalWidth);
//     // print((1 - percentage / 100) * totalWidth);
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: location,
//       // decoration: BoxDecoration(
//       //     color: negetiveColor,
//       //     border: Border.all(color: Colors.black, width: 2.0)),
//       child: Image.asset(
//                         'assets/ECDC.jpg',
//                         fit: BoxFit.fill,
//                       ),
//     );
//   }
// }
