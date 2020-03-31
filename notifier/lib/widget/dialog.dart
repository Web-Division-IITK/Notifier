import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogWidget extends StatefulWidget {
  final Function function;
  CustomDialogWidget(this.function);
  @override
  _CustomDialogWidgetState createState() => _CustomDialogWidgetState();
}

class _CustomDialogWidgetState extends State<CustomDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Delete Confirmation'),
      content: Column(
        children: <Widget>[
          Text('Do you really want to delete this file'),
          Text('Note: You will not be able to recover this file'),
        ],
      ),
      actions: <Widget>[
        FlatButton(onPressed: ()=>Navigator.pop(context),
          child: Text('Dismiss'),
        ),
        RaisedButton(onPressed: ()=> widget.function,
        
          child: Text('Confirm'),
        ),
        // CupertinoDialogAction(child: Text('Confirm')),
        // CupertinoDialogAction(child: Text('Dismiss'))
      ],
    );
  }
}