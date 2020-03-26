import 'package:flutter/material.dart';
import 'package:notifier/services/auth.dart';

class Break extends StatefulWidget {
  @override
  _BreakState createState() => _BreakState();
}

class _BreakState extends State<Break> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions:<Widget>[
          FlatButton.icon(
                          icon: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          label: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () async {
                            await _auth.signOut();
                          },
                        )
        ]
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: Text('GetYourEmail Verified To begin')),
          Center(child: RaisedButton(onPressed: ()async{
            await _auth.sendEmailVerification();
          },
          child: Text('Resend Again')))
        ],
      )
    );
  }
}