import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CalendarDatePicker(
        initialDate: DateTime.now(), 
        firstDate: DateTime.now(), 
        lastDate: DateTime(DateTime.now().year + 30), 
        onDateChanged: print));
  }
}