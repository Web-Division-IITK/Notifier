import 'package:flutter/material.dart';
import 'package:notifier/model/hive_models/ss_model.dart';

class StudentDetails extends StatelessWidget {
  final SearchModel userData;
  final Future<ImageProvider> url;
  StudentDetails(this.userData,this.url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
            )
          ],
        ),
      ),
    );
  }
}