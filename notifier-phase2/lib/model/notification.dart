import 'package:flutter/material.dart';


/// cpntains id, title, body ,payload
/// 
/// body is here message of notification
class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}
