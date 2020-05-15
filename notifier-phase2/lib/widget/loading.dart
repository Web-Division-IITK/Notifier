import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notifier/widget/showtoast.dart';

class Loading extends StatefulWidget {
  final String display;
  Loading({Key key,@ required this.display}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  // Timer timer;
  @override
  void initState() { 
    super.initState();
    // timer = Timer(Duration(seconds: 10),(){
    //   return showErrorToast('Error while ' + widget.display??'loading');
    //   // return Navigator.pop(context,'error');
    // } );
  }
  @override
  void dispose() { 
    // timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.transparent,
      // height: MediaQuery.of(context).size.height,
      // width: MediaQuery.of(context).size.width,
      child: Center(
        child: SpinKitDualRing(color: Theme.of(context).accentColor,lineWidth: 5,)
        // child: CircularProgressIndicator(),
      ),
    );
  }
}