import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/map_button.dart';
import 'helper/ui_helper.dart';

import 'package:flutter/widgets.dart';

class MapPage extends StatefulWidget {
  final String typeText;

  MapPage({
    this.typeText,
  });

  @override
  State<StatefulWidget> createState() {
    return _GoogleMapState(typeText);
  }
}

class _GoogleMapState extends State<MapPage> with TickerProviderStateMixin {
  AnimationController animationControllerExplore;
  AnimationController animationControllerSearch;
  AnimationController animationControllerMenu;
  CurvedAnimation curve;
  Animation<double> animation;
  Animation<double> animationW;
  Animation<double> animationR;
  String _mapStyle;
  // FirestoreServices firestoreServices;
  GoogleMapController mapController;
  Set<Marker> markers = Set<Marker>.from([]);
  // Set<VenueModel> venues = Set<VenueModel>.from([]);
  BitmapDescriptor mapIcon;
  String _query = "";
  List<String> _venueList = [];
  List<String> _filteredVenueList = [];
  _GoogleMapState(String typeText);
  var appJson = {};

  /// get currentOffset percent
  get currentExplorePercent =>
      max(0.0, min(1.0, offsetExplore / (760.0 - 122.0)));
  get currentSearchPercent => max(0.0, min(1.0, offsetSearch / (347 - 68.0)));
  get currentMenuPercent => max(0.0, min(1.0, offsetMenu / 358));

  var offsetExplore = 0.0;
  var offsetSearch = 0.0;
  var offsetMenu = 0.0;

  bool isExploreOpen = false;
  bool isSearchOpen = false;
  bool isMenuOpen = false;

  bool _subscribedValue;
  bool _draw = false;

  var title = "";

  // final FirebaseMessaging fcm = FirebaseMessaging();
  // FirestoreServices firestoreServices;
  // final FirebaseAuth _user = FirebaseAuth.instance;

  // // void @override
  // void initState() { 
  //   super.initState();
  //   getValue();
  // }

  //set query from search back widget
  void setQuery(String query) {
    setState(() {
      _query = query;
    });
    filterSearchResults(query);
  }

  void filterSearchResults(String query) {
    query = query.toUpperCase();
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(_venueList);
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if (item.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _filteredVenueList.clear();
        _filteredVenueList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _filteredVenueList.clear();
        _filteredVenueList.addAll(_venueList);
      });
    }
  }

  /// search drag callback
  void onSearchHorizontalDragUpdate(details) {
    offsetSearch -= details.delta.dx;
    if (offsetSearch < 0) {
      offsetSearch = 0;
    } else if (offsetSearch > (347 - 68.0)) {
      offsetSearch = 347 - 68.0;
    }
    setState(() {});
  }

  /// explore drag callback
  void onExploreVerticalUpdate(details) {
    offsetExplore -= details.delta.dy;
    if (offsetExplore > 644) {
      offsetExplore = 644;
    } else if (offsetExplore < 0) {
      offsetExplore = 0;
    }
    setState(() {});
  }

  /// animate Explore
  ///
  /// if [open] is true , make Explore open
  /// else make Explore close
  void animateExplore(bool open) {
    animationControllerExplore = AnimationController(
      duration: Duration(
        milliseconds: 1 + 
          (800 * 
            ( isExploreOpen 
              ? currentExplorePercent 
              : (1 - currentExplorePercent)
            )).toInt()),
      vsync: this
    );
    curve = CurvedAnimation(parent: animationControllerExplore, curve: Curves.ease);
    animation = Tween(
      begin: offsetExplore,
      end: open 
        ? 760.0 - 122 
        : 0.0
    )
      .animate(curve)
        ..addListener(() {
          setState(() {
            offsetExplore = animation.value;
          });
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            isExploreOpen = open;
          }
        });
    animationControllerExplore.forward();
  }

  void animateSearch(bool open) {
    animationControllerSearch = AnimationController(
      duration: Duration(
        milliseconds: 1 +
          (800 *
            (isSearchOpen
              ? currentSearchPercent
              : (1 - currentSearchPercent)
            )
          ).toInt()),
      vsync: this
    );
    curve =
        CurvedAnimation(parent: animationControllerSearch, curve: Curves.ease);
    animation = Tween(begin: offsetSearch, end: open ? 347.0 - 68.0 : 0.0)
      .animate(curve)
        ..addListener(() {
          setState(() {
            offsetSearch = animation.value;
          });
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            isSearchOpen = open;
          }
        });
    animationControllerSearch.forward();
  }

  void animateMenu(bool open) {
    animationControllerMenu =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    curve =
        CurvedAnimation(parent: animationControllerMenu, curve: Curves.ease);
    animation =
      Tween(begin: open ? 0.0 : 358.0, end: open ? 358.0 : 0.0).animate(curve)
        ..addListener(() {
          setState(() {
            offsetMenu = animation.value;
          });
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            isMenuOpen = open;
          }
        });
    animationControllerMenu.forward();
  }

  // getVenue(AsyncSnapshot<QuerySnapshot> snapshot) {
  //   return snapshot.data.documents
  //     .map((doc) => new Marker(
  //           markerId: MarkerId(doc['name']),
  //           position: LatLng(double.parse(doc['latitude']),
  //               double.parse(doc['longitude'])),
  //           icon: iconList[doc['name']],
  //         ))
  //     .toSet();
  // }

  getCurrentLocation() async {
    Position currentLocation;
    try {
      currentLocation = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 20.0,
      // zoom: 18.0,
      tilt: 89.0,
    )));
    return currentLocation;
  }

  Future<String> _loadJsonAsset() async {
    return await rootBundle.loadString('assets/data/app_data.json');
  }

  getVenueList() async {
    String jsonString = await _loadJsonAsset();
    final jsonResponse = json.decode(jsonString);
    setState(() {
      appJson = jsonResponse;
    });
    appJson['venues'].forEach((key, value) {
      setState(() {
        _venueList.add(key);
        _filteredVenueList.add(key);
      });
    });
  }

  getMarkers() async {
      _venueList.forEach((venue) {
        // print("db #113: latitude of $venue: ${appJson['venues'][venue].toString()}");
        setState(() {
          markers.add(Marker(
            markerId: MarkerId(venue),
            //icon: mapIcon,
            icon: iconList[venue],
            // position: (appJson['venues'][venue]['latitude'] == " ") ? LatLng(double.parse("26.5048661"),double.parse("80.2271854")) : 
            position: LatLng(double.parse(appJson['venues'][venue]['latitude']), double.parse(appJson['venues'][venue]['longitude'])),
            infoWindow: InfoWindow(title: venue),
            onTap: () async {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.2),
                          BlendMode.dstATop),
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/map_background.jpg")
                      )
                    ),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            '${venue}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.directions_walk),
                            color: Colors.blue,
                            iconSize: 30,
                            onPressed: () {
                              // (appJson['venues'][venue]['latitude'] == " ") ?
                              // launch('google.navigation:q=${"26.5048661"},${"80.2271854"}')
                              // :
                              launch('google.navigation:q=${appJson['venues'][venue]['latitude']},${appJson['venues'][venue]['longitude']}');
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Events at this venue",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        // Expanded(
                        //   child: upcomingEvents(venue, appJson['venues'][venue]['latitude'], appJson['venues'][venue]['longitude']),
                        // ),
                        // (appJson['venues'][venue]['latitude'] == " ") ? upcomingEvents(venue, "26.5048661", "80.2271854") :
                        // upcomingEvents(venue, appJson['venues'][venue]['latitude'], appJson['venues'][venue]['longitude']),
                      ],
                    )
                  );
                }
              );
            }
          ));
        });
      });
    // });
  }

  // getValue() async {
  //   final FirebaseUser currentUser = await _user.currentUser();
  //   String event = this.title;
  //   ReCase rc = new ReCase(event);
  //   DocumentReference docRef =
  //       Firestore.instance.collection('users').document(currentUser.uid);
  //   DocumentSnapshot doc = await docRef.get();

  //   List tags = doc.data['tags'];

  //   if (tags.contains(rc.headerCase) == true) {
  //     _subscribedValue = true;

  //     // fcm.unsubscribeFromTopic(event);
  //   } else {
  //     _subscribedValue = false;
  //   }
  //   setState(() {
  //     _draw = true;
  //   });
  // }

  // void _changeValue(bool value) {
  //   setState(() {
  //     // if (_subscribedValue == true) {
  //     //   _subscribedValue = false;
  //     // } else {
  //     //   _subscribedValue = true;
  //     // }
  //     _subscribedValue = value;
  //     // getValue();
  //   });

  //   setState(() async {
  //     String event = this.title;
  //     ReCase rc = new ReCase(event);
  //     final FirebaseUser currentUser = await _user.currentUser();

  //     DocumentReference docRef =
  //         Firestore.instance.collection('users').document(currentUser.uid);
  //     DocumentSnapshot doc = await docRef.get();

  //     List tags = doc.data['tags'];

  //     print(tags);

  //     if (tags.contains(rc.headerCase) == true) {
  //       docRef.updateData({
  //         'tags': FieldValue.arrayRemove([rc.headerCase])
  //       }).then((d) {
  //         fcm.unsubscribeFromTopic(rc.headerCase);
  //         print("db #52: tag deleted  ");
  //       }).catchError((e) {
  //         // standardSnackbar("", 0, "Database Error Occured" + event, context);
  //         showErrorToast("Database Error Occured" + event);
  //       });
  //       // StandardSnackbar(
  //       //   title: "",
  //       //   subtitle: "Unsubscribed to " + event,
  //       //   type: 1,
  //       // );
  //       // standardSnackbar("Unsubscribed from " + event, 1, "", context);
  //       // fcm.unsubscribeFromTopic(event);
  //     } else {
  //       docRef.updateData({
  //         'tags': FieldValue.arrayUnion([rc.headerCase])
  //       }).then((d) {
  //         // fcm.subscribeToTopic(rc.headerCase);
  //         // print("db #53:tag added  ");
  //       });
  //       // standardSnackbar("Subscribed to " + event, 1, "", context);
  //     }
  //     // _subscriptionColor = Colors.redAccent;
  //     // _subscriptionIcon = Icons.favorite;
  //   });
  // }

  // upcomingEvents(String venue, String latitude, String longitude) {
  //   List<dynamic> schedule = appJson['schedule'];
  //   List<dynamic> venueEvents = [];
  //   schedule.forEach((item) {
  //     if(appJson['venueList'][item['venue']] == venue) {
  //       venueEvents.add(item);
  //     }
  //   });
  //   return SingleChildScrollView(
  //     physics: BouncingScrollPhysics(),
  //       child: ListView.builder(
  //         shrinkWrap: true,
  //         physics: const BouncingScrollPhysics(),
  //         scrollDirection: Axis.vertical,
  //         itemCount: venueEvents.length,
  //         itemBuilder: (context, index) {
  //           getValue();
  //           this.title = venueEvents[index]['title'];
  //           // var dateTime= snapshot.data.documents[index]['date'].toDate().toString();
  //           // var time = UtilFunctions().parseTime(dateTime, 'h:mm a');
  //           var day = venueEvents[index]['day'];
  //           var time = venueEvents[index]['time'];
  //           var category = venueEvents[index]['category'];
  //           var redirect = venueEvents[index]['redirect'];
  //           // var date = UtilFunctions().parseTime(dateTime, 'EEE d MMM');
  //           return ListTile(
  //             title: venueEvents[index]['title'],
  //             // subtitle: '${UtilFunctions().parseDate(snapshot.data.documents[index]['date'].toDate().toString(), 'MMMM dd')}: ${UtilFunctions().parseTime(snapshot.data.documents[index]['date'].toDate().toString(), 'h:mm a')}',
  //             // subtitle: UtilFunctions().parseDayFromSchedule(day) + ", " + UtilFunctions().parseTimeFromSchedule(time),
  //             // content: category.toUpperCase().toString(),
  //             // trailing:  _draw ? XlivSwitch(
  //             //   value: _subscribedValue,
  //             //   onChanged: _changeValue,
  //             // ): Container(width: 0,),
  //             trailing: Container(width: 0,),
  //             leading: Icon(Icons.arrow_right),
  //             onTap: () {
  //               Map<dynamic, dynamic> eventInfo = {};
  //               appJson[category]['data'].forEach((item) {
  //                 if(item['name'] == redirect) {
  //                   eventInfo = item;
  //                 }
  //               });
  //               // Navigator.push(
  //               //   context,
  //               //   MaterialPageRoute(
  //               //     builder: (context) => new PokemonInfo(
  //               //     category: CategoryModel(
  //               //       name: category,
  //               //       data: appJson[category]['data'],
  //               //       contacts: appJson[category]['contacts']
  //               //     ),
  //               //     eventInfo: EventInfoModel(
  //               //       color: Colors.yellow,
  //               //       category: category,
  //               //       prize1: eventInfo['prize1'],
  //               //       prize2: eventInfo['prize2'],
  //               //       prize3: eventInfo['prize3'],
  //               //       rules: eventInfo['rules'],
  //               //       title: eventInfo['name'],
  //               //       details: eventInfo['details'],
  //               //   )
  //               // )));
  //             },
  //           );
  //         },
  //       ),
  //   );
  // }

  // getInitialLocation() async {
  //   if (widget.typeText != null && appJson['venueList'][widget.typeText] != null) {
  //     var venueKey = appJson['venueList'][widget.typeText];
  //     var latitude = double.parse(appJson['venues'][venueKey]['latitude']);
  //     var longitude = double.parse(appJson['venues'][venueKey]['longitude']);
  //     print("db #143: typeText data: $venueKey, $latitude, $longitude");
  //     mapController
  //         .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //       target: LatLng(latitude, longitude),
  //       zoom: 18.0,
  //       tilt: 89.0,
  //     )));
  //   } else {
  //     // print('Hello');
  //     Position curr = await getCurrentLocation();
  //     Marker current = (Marker(
  //         markerId: MarkerId('Current Location'),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //         position: LatLng(curr.latitude, curr.longitude),
  //         infoWindow: InfoWindow(title: 'Current Location')));
  //     setState(() {
  //       markers.add(current);
  //     });
  //     mapController
  //         .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //       target: LatLng(double.tryParse(appJson['venues']['OAT']['latitude']), double.tryParse(appJson['venues']['OAT']['longitude'])),
  //       zoom: 18.0,
  //       tilt: 89.0,
  //     )));
  //   }
  // }

  _mapPageAppBar() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, right: 15, top: 45),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 25.0,
                  left: 10.0,
                ),
                //padding: EdgeInsets.all(10.0),
                child: InkWell(
                  child: (currentSearchPercent > 0.4 || currentExplorePercent > 0.4)
                    ? Icon(
                        Icons.close,
                        color: Colors.white,
                      )
                    : Icon(Icons.arrow_back, color: Colors.white),
                  onTap: () {
                    (currentSearchPercent > 0.4)
                    ? animateSearch(false)
                    : (currentExplorePercent > 0.4)
                    ? animateExplore(false)
                    : Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: <Widget>[
              Center(
                child: Container(
                  color: Colors.blueGrey,
                  //color: Color.fromRGBO(26, 30, 80, 100),
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(7.0),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: screenWidth,
                          height: screenHeight,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: GoogleMap(
                                  compassEnabled: true,
                                  onMapCreated: (controller) => setState(() {
                                    mapController = controller;
                                    mapController.setMapStyle(_mapStyle);
                                    getMarkers();
                                    // getInitialLocation();
                                  }),
                                  markers: markers,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(26.5191848, 80.2209766),
                                    zoom: 19.0,
                                    // zoom: 17.0,
                                    tilt: 89.0,
                                  ),
                                ),
                              ),
                              // ExploreWidget(
                              //   currentExplorePercent: currentExplorePercent,
                              //   currentSearchPercent: currentSearchPercent,
                              //   animateExplore: animateExplore,
                              //   isExploreOpen: isExploreOpen,
                              //   onVerticalDragUpdate: onExploreVerticalUpdate,
                              //   onPanDown: () =>
                              //       animationControllerExplore?.stop(),
                              // ),
                              //blur
                              offsetSearch != 0
                                ? BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10 * currentSearchPercent,
                                      sigmaY: 10 * currentSearchPercent),
                                    child: Container(
                                      color: Colors.white.withOpacity(
                                          0.1 * currentSearchPercent),
                                      width: screenWidth,
                                      height: screenHeight,
                                    ),
                                  )
                                : const Padding(
                                  padding: const EdgeInsets.all(0),
                                ),
                              //explore content
                            //  ExploreContentWidget (
                            //     currentExplorePercent: currentExplorePercent,
                            //     mapController: mapController,
                            //     animateExplore: animateExplore,
                            //     appJson: this.appJson,
                            //   ),
                              //recent search
                              // RecentSearchWidget(
                              //   currentSearchPercent: currentSearchPercent,
                              //   query: _query,
                              //   venueList: _filteredVenueList,
                              //   mapController: mapController,
                              //   animateSearch: animateSearch,
                              //   appJson: this.appJson,
                              // ),
                              // SearchWidget(
                              //   currentSearchPercent: currentSearchPercent,
                              //   currentExplorePercent: currentExplorePercent,
                              //   isSearchOpen: isSearchOpen,
                              //   animateSearch: animateSearch,
                              //   onHorizontalDragUpdate:
                              //       onSearchHorizontalDragUpdate,
                              //   onPanDown: () =>
                              //       animationControllerSearch?.stop(),
                              // ),
                              //search back
                              // SearchBackWidget(
                              //   currentSearchPercent: currentSearchPercent,
                              //   animateSearch: animateSearch,
                              //   updateAction: setQuery),
                              MapButton(
                                // isRight: false,
                                tap: () async {
                                  Position curr = await getCurrentLocation();
                                  Marker current = Marker(
                                      markerId: MarkerId("Current Location"),
                                      position:
                                          LatLng(curr.latitude, curr.longitude),
                                      icon: mapIcon,
                                      infoWindow: InfoWindow(
                                        title: "Current Location",
                                      ));
                                  setState(() {
                                    markers.add(current);
                                  });
                                },
                                currentSearchPercent: currentSearchPercent,
                                currentExplorePercent: currentExplorePercent,
                                bottom: 190,
                                offsetX: -68,
                                width: 68,
                                height: 71,
                                icon: Icons.my_location,
                                iconColor: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _mapPageAppBar(),
            ],
          ),
        ),
      );
  
  }

  // Positioned(
  //   top: 20.0,
  //   child: StandardListItem(
  //     leading: Icon(Icons.info),
  //     tileColor: Colors.black12,
  //     title: "Tap on Icons to view the Upcoming Events",
  //     subtitle: "",
  //   ),
  // ),

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    rootBundle
        .loadString('assets/map-styles/aubergine_google_map.txt')
        .then((string) {
      _mapStyle = string;
    });
    // firestoreServices = new FirestoreServices();
    // });
    // getValue();
    getVenueList()
      .then((_) {_loadBitmapImages();})
      .catchError((e) {print("e #116: $e");});
    super.initState();
  }
  
  Map <String, BitmapDescriptor> iconList = Map();

  _loadBitmapImages() async {
    Map <dynamic, dynamic> imgList = Map();
    print("db #116: venuelist: ${_venueList.toString()}");

    _venueList.forEach((venue) {
      // imgList[venue] = "m-PRONITE-GROUND.png";
      imgList[venue] = "m-" + venue + ".png";
      // print("db #115: imgList[$venue]: ${imgList[venue]}");
    });

    await imgList.forEach((key, value) {
      // print("db #117: value of asset address: $value");
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(50, 50)), "lib/maps/assets/" + value)
        .then((onValue) {
          iconList[key] = onValue;
        });
    });
  }
  // "lib/maps/assets/" + imgList[i]

  @override
  void dispose() {
    super.dispose();
    animationControllerExplore?.dispose();
    animationControllerSearch?.dispose();
    animationControllerMenu?.dispose();
  }
}