import 'package:flutter/material.dart';
import 'package:notifier/services/auth.dart';

class Loading extends StatelessWidget {
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
      body: Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        )
      ),
    );
  }
}