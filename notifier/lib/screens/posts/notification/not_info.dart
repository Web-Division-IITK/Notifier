import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:notifier/screens/posts/notification/notification.dart';

 class NotfDesc extends StatefulWidget {
   final int index;
   NotfDesc(this.index);
   @override
   _NotfDescState createState() => _NotfDescState();
 }
 
 class _NotfDescState extends State<NotfDesc> {
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: Text(sortedarray[widget.index].value['title'])),
       body: ListView(
         children: <Widget>[
           
               Card(
                 elevation:0.0,
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
               ),
            
           
               Card(
                 elevation:5.0,
                 shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                           Radius.circular(16.0))),
                 margin: EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 10.0),
                 child: Container(
                   padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 30.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: <Widget>[
                       Center(
                         child: Text(
                            sortedarray[widget.index].value['title'],
                            style: TextStyle( fontSize: 35.0),
                      ),
                       ),
                      Center(
                        child: Text(sortedarray[widget.index].value['sub'][0],
                            style: TextStyle( fontSize: 20.0)),
                      ),
                          Wrap(
                            spacing: 8.0,
                              children:
                                  _buildChoice(sortedarray[widget.index].value),
                            ),
                            // Text(sortedarray[widget.index].value['message'],
                            //     style: TextStyle(
                            //         fontSize: 30.0, color: Colors.black)),
                            // SizedBox(height: 20.0),
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
                   ),
                 )
               )
             
         ],
       ),
     );
   }
   _buildChoice(timenot) {
    List<Widget> _tag = List();
    // List<String> tags = timenot['tags'];
    for (var i in timenot['tags']) {
      _tag.add(
        Container(
          constraints: BoxConstraints(
            maxWidth: 120.0,
            // minWidth: 80.0,
          ),
          child: Chip(
            labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
            backgroundColor: Colors.teal[900],
            label: Text(i.toString(), style: TextStyle(color: Colors.white)),
          ),
        
      ));
    }

    return _tag;
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