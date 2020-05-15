import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:notifier/screens/maps/components/map_button.dart';
// class RenderGoogleMap extends StatelessWidget {
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: GoogleMap(
//       initialCameraPosition: CameraPosition(
//       target: _center,
//       zoom: 11.0,
//     ),
//     ),

//   );
// class MapSample extends StatefulWidget {
//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
//   Completer<GoogleMapController> _controller = Completer();

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   static final CameraPosition _kLake = CameraPosition(
//       bearing: 192.8334901395799,
//       target: LatLng(37.43296265331129, -122.08832357078792),
//       tilt: 5,
//       zoom: 19.151926040649414);

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       body: SafeArea(
//         child: Stack(
//           fit: StackFit.expand,
//           children: <Widget>[
            
//             GoogleMap(
//               mapType: MapType.hybrid,
//               initialCameraPosition: _kGooglePlex,
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//             ),
//             TextFormField(
//               toolbarOptions: ToolbarOptions(
//                 copy: true,
//                 paste: true,
//                 selectAll: true,
//               ),
//               maxLines: 1,
//               keyboardType: TextInputType.text,
//               autofocus: false,
//               initialValue: 'Search',
//               decoration: new InputDecoration(
//                 fillColor: Colors.white,
//                 filled: true,
//                 labelText: 'Title',
//                 hintText: 'Title of the Post',
//                 // helperText: 'Title would be displayed in the notification'
//               ),
//               // validator: (value) =>
//               //     value.isEmpty ? 'Title can\'t be empty' : null,
//               // onSaved: (value) => '',
//               // onChanged: (value) => _title = value,
//               // ),
//             ),
//             Positioned(
//               bottom: 100.0,
//               right: 10.0,
//               child: FloatingActionButton(
//                 heroTag: 'jvhjhv',
//                 onPressed: () {}),
//             )
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _goToTheLake,
//         label: Text('To the lake!'),
//         icon: Icon(Icons.directions_boat),
//       ),
//     );
//   }

//   Future<void> _goToTheLake() async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   }
// }
// }
class MapingMap extends StatefulWidget {
  @override
  _MapingMapState createState() => _MapingMapState();
}

class _MapingMapState extends State<MapingMap> {
  // Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  Position position;
  String _mapStyle;
  GeolocationStatus geolocationStatus;
  static CameraPosition cameraPosition = CameraPosition(
      target: LatLng(26.510488, 80.231960),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414,
      // bearing: 192.8334901395799,
    );
  @override
  void initState() { 
    super.initState();
    initPosition();
    (Theme.of(context).brightness == Brightness.dark)?
    rootBundle.loadString('assets/map-styles/map_styling.txt').then((string) {
      _mapStyle = string;
  }): rootBundle.loadString('assets/map-styles/map_styling.txt').then((string) {
      _mapStyle = string;
  });
  }
  initPosition()async{
    position = await Geolocator().getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    // Geolocator()
    double longitude;
    double latitude;
    print(position.toString() + ' current position');
    if(position == null || position.latitude == null || position.longitude ==null){
      longitude = 80.231960;
      latitude = 26.510488;
    }else{
      longitude = position.longitude;
      latitude = position.latitude;
    }
    geolocationStatus = await Geolocator().checkGeolocationPermissionStatus(
      locationPermission: GeolocationPermission.location
    );
    print(geolocationStatus.value.toString() + ' geolocationStatus');
    // cameraPosition = CameraPosition(
    //   target: LatLng(26.510488, 80.231960),
    //   tilt: 89.440717697143555,
    //   zoom: 19.151926040649414,
    //   // bearing: 192.8334901395799,
    // );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample '),
          // backgroundColor: Colors.green[700],
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: (GoogleMapController controller){
                mapController = controller;
                mapController.setMapStyle(_mapStyle);
              },
              compassEnabled: true,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: cameraPosition,
              buildingsEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
            ),
            // MapButton(

            // )
          ],
        ),
      // ),
    );
  }

  // static const LatLng _center = const LatLng(45.521563, -122.677433);
  // final Set<Marker> _markers = {};

//   LatLng _lastMapPosition = _center;

//   MapType _currentMapType = MapType.normal;

//   void _onMapTypeButtonPressed() {
//     setState(() {
//       _currentMapType = _currentMapType == MapType.normal
//           ? MapType.satellite
//           : MapType.normal;
//     });
//   }

//   void _onAddMarkerButtonPressed() {
//     setState(() {
//       _markers.add(Marker(
//         // This marker id can be anything that uniquely identifies each marker.
//         markerId: MarkerId(_lastMapPosition.toString()),
//         position: _lastMapPosition,
//         infoWindow: InfoWindow(
//           title: 'Really cool place',
//           snippet: '5 Star Rating',
//         ),
//         icon: BitmapDescriptor.defaultMarker,
//       ));
//     });
//   }

//   void _onCameraMove(CameraPosition position) {
//     _lastMapPosition = position.target;
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _controller.complete(controller);
//   }
}
