import 'package:flutter/material.dart';

decoration(String text) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.blue[100] ,
    focusColor: Colors.white70,
    labelText: text,
    labelStyle: TextStyle(
      color: Colors.blueGrey[700],
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.horizontal(
          left: Radius.circular(20.0), right: Radius.circular(20.0)),
      borderSide: new BorderSide(
        color: Colors.red,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.horizontal(
          left: Radius.circular(20.0), right: Radius.circular(20.0)),
      borderSide: new BorderSide(
        color: Colors.red,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.horizontal(
          left: Radius.circular(20.0), right: Radius.circular(20.0)),
      borderSide: new BorderSide(
        color: Colors.blue[100],
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.horizontal(
          left: Radius.circular(20.0), right: Radius.circular(20.0)),
      borderSide: new BorderSide(
        color: Colors.blue[100],
        // width: 10.0,
      ),
    ),
  );
}

class ButtonForAuthentication extends StatelessWidget {
  final bool loading;
  final Function onTap;
  final String text;
  final IconData icon;

  ButtonForAuthentication(this.loading,this.onTap,this.text,this.icon);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          elevation: 8.0,
                          splashColor: Colors.deepPurple[900],
                          color: Colors.deepPurpleAccent[400],
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 15.0, bottom: 15.0, right: 5.0, left: 0.0),
                            child: loading ? CircularProgressIndicator(backgroundColor: Colors.white) : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  text,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                           onPressed: onTap,
                        );
  }
}
