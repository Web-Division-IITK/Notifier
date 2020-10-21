import 'package:flutter/material.dart';
import 'package:notifier/model/hive_models/ss_model.dart';


class MessView extends StatefulWidget {
  final SearchModel userData;
  MessView(this.userData);
  @override
  _MessViewState createState() => _MessViewState();
}

class _MessViewState extends State<MessView> {
  final List<String> hall = List.generate(13, (index)=>'HALL ${index+1}',growable: true);
  String selectedHall;
  @override
  void initState() { 
    super.initState();
    hall.insert(0, 'GH');
    selectedHall = widget.userData.hall;
  }
  //TODO: add configuartion while publishing https://pub.dev/packages/flutter_full_pdf_viewer
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mess'),
      ),
      body: Container(
        child: DropdownButton(
          items: hall.map((location){
            return DropdownMenuItem(
              child: Text(location),
              value: location, 
            );
          }).toList(), 
          onChanged: (val) => setState(()=>selectedHall = val),
          value: selectedHall,
        ),
      )
    );
  }
}