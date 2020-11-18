import 'package:flutter/material.dart';
import 'package:notifier/colors.dart';
import 'package:photo_view/photo_view.dart';

class CustomMap extends StatefulWidget {
  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Campus Map")
      ),
      body: Container(
        child: Center(
          child: PhotoView(
            imageProvider: AssetImage("assets/campus.png"),
            loadingBuilder: (context, imageChunk){
              return CircularProgressIndicator();
            },
            enableRotation: true,
            minScale: 0.04,
            initialScale: 0.04,
            backgroundDecoration: BoxDecoration(
              color: CustomColors(context).bgColor,
            ),
          )
        ),
      ),
    );
  }
}