import 'package:flutter/material.dart';
import 'package:notifier/color/decoration.dart';
import 'package:notifier/screens/authenticate/break.dart';
import 'package:notifier/screens/wrapper.dart';
import 'package:notifier/services/auth.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  //text field state
  String email = "";
  String password = "";
  String error = "";
  String userName = "";
  String conPassword = "";
  bool loading = false;

  Widget showError(String error) {
    if (error != "") {
      return Container(
        height: 30.0,
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 15.0),
        ),
      );
    }
    return SizedBox(
      height: 0.0,
    );
  }
  @override
   void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }
  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularProgressIndicator(backgroundColor: Colors.white)
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                'Sign Up',
                textAlign: TextAlign.center,
              ),
            ),
            body: Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 10.0),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(height: 40.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            elevation: 8.0,
                            color: Colors.indigo,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 12.0,
                                  right: 0.0,
                                  left: 0.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.person_pin,
                                    color: Colors.white54,
                                    size: 25.0,
                                  ),
                                  SizedBox(
                                    width: 6.0,
                                  ),
                                  Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              widget.toggleView();
                            },
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),

                            splashColor: Colors.black,
                            elevation: 8.0,
                            color: Colors./*indigoAccent[700]*/blue,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0,
                                  bottom: 15.0,
                                  right: 4.0,
                                  left: 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.person_add,
                                    color: Colors.white,
                                    size: 28.0,
                                  ),
                                  SizedBox(
                                    width: 6.0,
                                  ),
                                  Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 25.0),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 50.0),
                      //   child: TextFormField(
                      //     style: TextStyle(
                      //     color: Colors.black,
                      //   ),
                      //       validator: (val) => val.isEmpty ? 'Name' : null,
                      //       onChanged: (val) {
                      //         setState(() {
                      //           userName = val;
                      //         });
                      //       },
                      //       decoration: decoration(" Name")),
                      // ),
                      // SizedBox(height: 18.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: TextFormField(
                          style: TextStyle(
                          color: Colors.black,
                        ),
                            validator: (val) => val.isEmpty
                                ? 'Enter Username'
                                : (val.contains('@') || val.contains(" ") || val.contains('iitk.ac.in')
                                    ? 'Invalid UserName or You have not entered CC User ID'
                                    : null),
                            onChanged: (val) {
                              setState(
                                () {
                                  email = val;
                                },
                              );
                            },
                            decoration: decoration("CC UserID")),
                      ),
                      SizedBox(height: 18.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: TextFormField(
                          style: TextStyle(
                          color: Colors.black,
                        ),
                          validator: (val) => val.length < 6
                              ? 'Enter a password 6+ chars long'
                              : null,
                          obscureText: true,
                          onChanged: (val) {
                            password = val;
                          },
                          decoration: decoration(" Password"),
                        ),
                      ),
                      SizedBox(height: 18.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: TextFormField(
                          style: TextStyle(
                          color: Colors.black,
                        ),
                            validator: (val) => (val != password || val.isEmpty)
                                ? 'Passwords does not match'
                                : null,
                            obscureText: true,
                            onChanged: (val) {
                              conPassword = val;
                            },
                            decoration: decoration(" Confirm Password")),
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: ButtonForAuthentication(
                          loading,() async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                loading = true;
                              });
                              dynamic result =
                                  await _auth.registerWithEmailAndPassword(
                                      userName, email + '@iitk.ac.in', password);
                                      print(result);
                                //       val = result;
                                      if(result == 'false'){
                                setState(() {
                                  loading = false;
                                  
                                   Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                                           return Break();
                                          }));
                                });
                              }
                              if (result == null) {
                                setState(() {
                                  error = 'Please supply a valid email';
                                  loading = false;
                                });
                              }
                            }
                          },"Sign Up",Icons.person_add
                        ),
                      ),
                      SizedBox(height: 18.0),
                      showError(error),
                    ],
                  )),
            ),
          );
  }
}
