import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notifier/color/decoration.dart';
import 'package:notifier/services/auth.dart';
// import 'package:notifier/shared/loading.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}
bool doneReset = false;

class _ResetPasswordState extends State<ResetPassword> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String error = "";

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return /*loading
        ? Loading(Colors.white)
        :*/ Scaffold(
            appBar: AppBar(
              // actionsIconTheme: IconThemeData(),
              // automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0.0,
              leading: IconButton(
                  alignment: Alignment.center,
                  tooltip: "Back",
                  
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                
              // title: Text('Reset Password'),
            ),
            body: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      
                      Text(
                        "Reset   Password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 55.0
                        ),
                      ),
                      SizedBox(height: 50.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        child: TextFormField(
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            cursorColor: Colors.teal,
                            validator: (val) => val.isEmpty
                                ? 'Enter an email'
                                : (!val.contains('@') ? 'Invalid Email' : null),
                            decoration: decoration(" Email"),
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            }),
                      ),
                      SizedBox(height: 18.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        // child: ButtonForAuthentication(false, () async {
                        //   if (_formKey.currentState.validate()) {
                        //     setState(() {
                        //       loading = true;
                        //     });
                        //     dynamic result =
                        //         await _auth.sendPasswordResetEmail(email);

                        //     if (result == null) {
                        //       setState(() {
                        //         error =
                        //             'Couldn\'t process request at this time';
                        //         loading = false;
                        //       });
                        //     }
                        //     else {
                        //      doneReset = true;
                        //      loading = false;
                        //     //  Navigator.of(context).pop();
                        //     }
                        //   }
                        // }, "Reset Password", Icons.refresh,
                        // ),
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          elevation: 8.0,
                          splashColor: Colors.deepPurple[900],
                          color: Colors.deepPurpleAccent[400],
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 15.0, bottom: 15.0, right: 5.0, left: 0.0),
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  "Reset Password",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                           onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              loading = true;
                            });
                            dynamic result =
                                await _auth.sendPasswordResetEmail(email);

                            if (result != true) {
                              setState(() {
                                doneReset = false;
                                error = result;
                                // error =
                                //     'Couldn\'t process request at this time';
                                loading = false;
                              });
                            }
                            else {
                             setState(() {
                               doneReset = true;
                               loading = false;
                               
                             });
                             
                           }
                           if(doneReset){
                             Navigator.of(context).pop();
                           }
                          }
                           }
                        ),
                      ),

                      SizedBox(height: 18.0),
                      // loading
                      //     ? SpinKitThreeBounce(
                      //         itemBuilder: (BuildContext context, int index) {
                      //           return DecoratedBox(
                      //             decoration: BoxDecoration(
                      //               shape: BoxShape.circle,
                      //               color: (index % 2 == 0)
                      //                   ? (Colors.blueAccent)
                      //                   : Colors.orange,
                      //             ),
                      //           );
                      //         }, // this is when the default loading does not work
                      //       )
                      //     :
                          //error displaying
                          Text(
                              error,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 15.0),
                              textAlign: TextAlign.center,
                            ),
                    ],
                  )),
            ),
          );
  }
}
