import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';

class CheckNetworkConnectivity{
  CheckNetworkConnectivity._internal();

  static final CheckNetworkConnectivity _instance = CheckNetworkConnectivity._internal();

  static CheckNetworkConnectivity get instance => _instance;

  Connectivity connectivity = Connectivity();

  StreamController controller = StreamController.broadcast();

  Stream get myStream => controller.stream;
  void initialise() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    getConnectivityState(result);
    connectivity.onConnectivityChanged.listen((result) {
      getConnectivityState(result);
    });
  }
  
  void getConnectivityState(ConnectivityResult result) async{
    bool status = false;
    try {
      var result = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 5)).catchError((e){
        print(e);
        return null;
      });
      if(result != null && result.isNotEmpty && result[0].rawAddress.isNotEmpty){
        print('connected');
        status = true;
        // if(status!= true){
        //   return streamController.add(true);
        // }
      }else{
        print('notConnected');
        status = false;
        // if(status!= false){
        //   return streamController.add(false);
        // }
      }
    }on SocketException catch (e) {
      print(e);
      status = false;
      // if(status!= false){
      //   return streamController.add(false);
      // }
    }
    controller.add(status);
  }
  void disposeStream() => controller.close();
}