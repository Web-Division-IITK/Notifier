import 'package:flutter/material.dart';
import 'package:notifier/database/reminder.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          CalendarDatePicker(
            initialDate: DateTime.now(), 
            firstDate: DateTime.now(), 
            lastDate: DateTime(DateTime.now().year + 30), 
            onDateChanged: print
          ),
        ],
      )
    );
  }
  void student() async{
    await DatabaseProvider().getAllPosts().then((value){
      value.forEach((element) {
        // element.startTime
      });
    });
  }
}