import 'package:notifier/screens/maps/helper/ui_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class ExploreContentWidget extends StatefulWidget {

  final List imagesOfStarAttractions;
  final double currentExplorePercent;
  final GoogleMapController mapController;
  final Function animateExplore;
  ExploreContentWidget({Key key, this.currentExplorePercent, this.imagesOfStarAttractions, this.mapController, this.appJson, this.animateExplore}) : super(key: key);
  final appJson;

  @override
  _ExploreContentWidgetState createState() => _ExploreContentWidgetState();
}

class _ExploreContentWidgetState extends State<ExploreContentWidget> {

  String category = 'event';
  String title = 'Venues';
  int selected = 0;
  List<dynamic> categoryItems = [];

  @override
  void initState() { 
    super.initState();
    setState(() {
      categoryItems = [];
    });
  }

  displayCategoryItems() {
    this.categoryItems = [];
    widget.appJson['venues'].forEach((key, value) {
      if(value['category'] == this.category) {
        this.categoryItems.add({'name': key, 'data': value});
      }
    });
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: categoryItems.length,
      itemBuilder: (context, index) {
      return Padding(
      padding: EdgeInsets.only(left: realW(22)),
      child: Column(
        children : <Widget>[
          _buildCategoryItem(
            index,
            categoryItems[index]['name'],
            "lib/maps/assets/m-" + categoryItems[index]['name'] + ".png",
            categoryItems[index]['data']['latitude'],
            categoryItems[index]['data']['longitude']
          ),
        ]));
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    
    if(widget.currentExplorePercent==0) {return Container();}
    if (widget.currentExplorePercent != 0) {
    return Positioned(
        top: realH(standardHeight + (230 - standardHeight) * widget.currentExplorePercent),
        width: screenWidth,
        child: Container(
          height: screenHeight,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Opacity(
                opacity: widget.currentExplorePercent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Transform.translate(
                      offset: Offset(0, realH(23 + 380 * (1 - widget.currentExplorePercent))),
                      child: Opacity(
                        opacity: widget.currentExplorePercent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: realW(22)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              //makeHeading('CATEGORY', Colors.white),
                              SizedBox(height: realH(10.0),),
                              makeHeading(this.title, Colors.yellowAccent),
                              SizedBox(height: realH(15.0),),
                            ],
                          ),
                        )
                        //   width: screenWidth,
                        //   height: realH(50),
                        //   child: Column(children: <Widget>[
                        //       makeHeading('CATEGORY: ', Colors.white),
                        //       makeTitle(this.title, Colors.yellowAccent)
                        //       //Text('${this.title.toUpperCase()}', style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 13.0),),
                        //     ],),
                        // )
                      )
                    ),
                    Transform.translate(
                      offset: Offset(0, realH(23 + 380 * (1 - widget.currentExplorePercent))),
                      child: Opacity(
                          opacity: widget.currentExplorePercent,
                          child: Container(
                            width: screenWidth,
                            height: realH(172 + (172 * 4 * (1 - widget.currentExplorePercent))),
                            child: displayCategoryItems()
                            ))),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        _buildExploreCategories("lib/maps/assets/venue.png", 'Venues', 'event', 0),
                        _buildExploreCategories("lib/maps/assets/drinks.png", 'Food & Drinks', 'food', 1),
                        _buildExploreCategories("lib/maps/assets/hall.png", 'Halls', 'halls', 2)
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        _buildExploreCategories("lib/maps/assets/todo.png", 'Things To Do', 'informals', 3),
                        _buildExploreCategories("lib/maps/assets/atm.png", 'Utilities', 'utilities', 4),
                        _buildExploreCategories("lib/maps/assets/help.png", 'Help Desk', 'help', 5)
                      ],
                    ),
                  ],
                ),
              ),
              // Transform.translate(
              //   offset: Offset(0, realH(58 + 570 * (1 - widget.currentExplorePercent))),
              //   child: Opacity(
              //     opacity: widget.currentExplorePercent,
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(horizontal: realW(22)),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         mainAxisSize: MainAxisSize.max,
              //         children: <Widget>[
              //           makeHeading('STAR ATTRACTIONS', Colors.white),
              //           Transform.translate(
              //             offset: Offset(0, realH(50 - 30 * (widget.currentExplorePercent - 0.75) * 4)), 
              //             child: StreamBuilder(
              //             stream: Firestore.instance.collection('starAttractions').snapshots(),
              //             builder: (BuildContext context, snapshot) {
              //               if(snapshot.data==null) {return Container();}
              //               if(snapshot.hasData){
              //               return ListView.builder(
              //                 shrinkWrap: true,
              //                 physics: BouncingScrollPhysics(),
              //                 scrollDirection: Axis.vertical,
              //                 itemCount: snapshot.data.documents.length,
              //                 itemBuilder: (context, index) { 
              //                   return Column(
              //                     children: <Widget>[
              //                       Stack(
              //                         children: <Widget>[
              //                           AspectRatio(
              //                             aspectRatio: 1.4,
              //                             child: Padding(
              //                             padding: EdgeInsets.all(8.0),
              //                               child: GestureDetector(
              //                                 onTap: () async {
              //                                   Firestore.instance.collection('locations').where('name',isEqualTo: snapshot.data.documents[index]['venue'])
              //                                   .limit(1).snapshots().listen((data) {
              //                                     data.documents.forEach((doc) {
              //                                       widget.mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              //                                       target: LatLng(double.parse(doc['latitude']), double.parse(doc['longitude'])),
              //                                       zoom:18.0)));
              //                                     });
              //                                   });
              //                                   widget.animateExplore(false);
              //                                 },
              //                                 child: ClipRRect(
              //                                   child: Image.network(snapshot.data.documents[index]['bgImage'], fit: BoxFit.cover),
              //                                   borderRadius: BorderRadius.all(Radius.circular(5.0)),
              //                                 ),
              //                               ),
              //                             ),
              //                           ),
              //                           Positioned(
              //                             bottom: realH(26),
              //                             left: realW(24),
              //                             child: Text(
              //                               snapshot.data.documents[index]['title'].toUpperCase(),
              //                               style: TextStyle(color: Colors.white, fontSize: realW(16)),
              //                             ))
              //                         ],
              //                       ),
              //                       SizedBox(
              //                         height: 14,
              //                       )
              //                   ],
              //                 );
              //                         }, 
              //           );
              //         }}
              //             ),),
                      
              //         ],
              //       ),
              //       ),
              //   )),
          Padding(
            padding: EdgeInsets.only(bottom: realH(262)),
          )
        ],
      ),
    ),
    );
  } else {
    return const Padding(
      padding: const EdgeInsets.all(0),
    );
  }
}
  makeTitle(String titleSubSection, Color titleSubColor) {
    return Padding(
      padding: EdgeInsets.only(left: realW(12)),
      child: Text(titleSubSection.toUpperCase(), style: TextStyle(color: titleSubColor, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  makeHeading(String titleSection, Color titleColor) {
    return Padding(
      padding: EdgeInsets.only(left: realW(12)),
      child: Text(titleSection.toUpperCase(), style: TextStyle(color: titleColor, fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }
  _buildExploreCategories(currImage, currTitle, currCategory, currIndex) {
    return Expanded(
      child: Transform.translate(
        offset: Offset(-screenWidth / 3 * (1 - widget.currentExplorePercent),
            screenWidth / 3 / 2 * (1 - widget.currentExplorePercent)),
        child:  Column(
          children: <Widget>[
            InkWell(
              child: FlatButton(
                onPressed: () {
                  this.category = currCategory;
                  this.title = currTitle;
                  this.categoryItems = [];
                  selected = currIndex;
                  setState(() {
                    displayCategoryItems(); 
                  });
                },
                child: Image.asset(
                  currImage,
                  width: realH(133),
                  height: realH(133),
                ),
              ),
            ),
            makeTitle(currTitle, (this.selected == currIndex) ? Colors.yellow:Colors.white38)
          ],
        ),
      ),
    );
  }
  
  _buildCategoryItem(int index, String name, String image, String latitude, String longitude) {
  
    return Transform.translate(
      offset: Offset(0, index * realH(127) * (1 - widget.currentExplorePercent)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
                onTap: () {
                  widget.mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                    target: LatLng(double.parse(latitude), double.parse(longitude)),
                    zoom:20.0, tilt: 89.0)));
                    // zoom:18.0, tilt: 89.0)));
                  widget.animateExplore(false);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Image.asset(
                  image,
                  // "lib/maps/assets/m-URBAN-CRAVE.png",
                  height: 90.0,
                  // height: realH(90),
                  // fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
