import 'package:notifier/screens/maps/helper/ui_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecentSearchWidget extends StatelessWidget {
  final double currentSearchPercent;
  final String query;
  final List venueList;
  final GoogleMapController mapController;
  final Function animateSearch;
  final appJson;
  const RecentSearchWidget(
      {Key key, this.currentSearchPercent, this.query, this.venueList, this.mapController, this.animateSearch, this.appJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return currentSearchPercent != 0
        ? Positioned(
            top: realH(
                -(75.0 + 494.0) + (75 + 75.0 + 494.0) * currentSearchPercent),
            left: realW((standardWidth - 320) / 2),
            width: realW(320),
            height: realH(494),
            child: Opacity(
                opacity: currentSearchPercent,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.only(top: 10),
                      height: realH(350),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: venueList.length,
                          itemBuilder: (context, index) {
                            return makeTile(venueList[index]);
                          })),
                )))
        : const Padding(
            padding: const EdgeInsets.all(0),
          );
  }

  makeTile(String title) {
    return GestureDetector(
        onTap: () async{
          mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                double.parse(appJson['venues'][title]['latitude']),
                double.parse(appJson['venues'][title]['longitude'])
              ),
              zoom: 20.0,
              // zoom: 18.0,
              tilt: 89.0,
              )
            )
          );
          animateSearch(false);
        },
          child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(50)),
          child: Icon(Icons.location_on, color: Colors.black),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        // subtitle: Text("Some Subtitle"),
      ),
    );
  }
}
