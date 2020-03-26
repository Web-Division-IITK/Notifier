import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:notifier/screens/posts/notification/notification.dart';

 
class NotfUpdate extends StatefulWidget {
  final int index;
  final timenots;
  NotfUpdate(this.timenots,this.index);
  @override
  _NotfUpdateState createState() => _NotfUpdateState();
}

class _NotfUpdateState extends State<NotfUpdate> {
  double boxHeigth ;
   PanelController _panelController = PanelController();
  @override
  Widget build(BuildContext context) {
    boxHeigth =  MediaQuery.of(context).size.height*0.8;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // elevation: 0.0,
        // centerTitle: true,
        title: 
           Text(widget.timenots['title']),
          // style: TextStyle(color: postitiveColor),
       
      ),
      body: SlidingUpPanel(
        parallaxEnabled: true,
        parallaxOffset: 1.0,
        // isA
        controller: _panelController,
        slideDirection: SlideDirection.DOWN,
        borderRadius: BorderRadius.circular(16.0),
        // renderPanelSheet: false,
        minHeight: MediaQuery.of(context).size.height*0.8,
        maxHeight: MediaQuery.of(context).size.height*0.5,
        // panel: Text(widget.timenots['title']),
        // panelBuilder: (BuildContext context){
          isDraggable: true,
        // },
        // renderPanelSheet: false,
        onPanelSlide: (v){
          setState(() {
            boxHeigth = MediaQuery.of(context).size.height * (0.8 - v*0.3);
            // print(boxHeigth);
          });
        },
        panel: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.black
          ),
          height: this.boxHeigth,
      // width: MediaQuery.of(context).size.width,
      // child: Image.asset(
      //                   'assets/ECDC.jpg',
      //                   fit: BoxFit.fill,
      //                 ),
    ),
        body: Container()
      )      
    );
  }
}

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