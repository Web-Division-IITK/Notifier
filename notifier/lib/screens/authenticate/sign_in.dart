import 'package:flutter/material.dart';
import 'package:notifier/color/decoration.dart';
import 'package:notifier/screens/authenticate/break.dart';
import 'package:notifier/screens/authenticate/reset_password.dart';
import 'package:notifier/services/auth.dart';


class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String error = "";
  String userName ="";
  bool loading = false;
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        backgroundColor: Colors.white,
        title: new Text('Are you really want to exit?',
          style: TextStyle(
          color: Colors.black,
        ),),
        // content: new Text('Do you really want to exit'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes',
              style: TextStyle(
                color: Colors.lightGreenAccent[400]
              ),
            ),
          ),
          new FlatButton(
            color: Colors.amber[900],
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
  @override
  Widget build(BuildContext context) {
    return loading ? CircularProgressIndicator(backgroundColor: Colors.white) : 
    WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   elevation: 0.0,
        //   // title: Text('Sign In'),
        // ),
        body: Container(
          color: Colors.white ,
          padding: EdgeInsets.symmetric(vertical: 20.0,),
          child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  doneReset ?  Container(
                    color: Colors.yellow,
                    width: double.infinity,
                    height: 70.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                      // Padding(
                        // padding: EdgeInsets.only(left: 18.0),
                        Row(
                          // cro = CrossAxisAlignment.start,
                          children: <Widget>[
                          
                          Icon(Icons.info_outline),
                          
                        Container(
                          height:45.0,
                          width: 265.0,
                          padding: EdgeInsets.only(left: 8.0,top: 5.0),
                          child: Text("Reset password link has been sent to your email account",
                                maxLines: 2,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  // fontSize: 16.0
                                ),),
                          // ),
                        ),
                          
                        ],),
                      // ),
                      IconButton(
                        alignment: Alignment.centerRight,
                        icon: Icon(Icons.close),
                        onPressed: (){
                          setState(() {
                            doneReset = false;
                          });
                        },
                      )
                    ],)
                  ): SizedBox(height:70.0),
                  SizedBox(height: 40.0,),
                  //navigating button between signin and register page
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        elevation: 8.0,
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, bottom: 15.0, right: 9.0, left: 6.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.account_circle,
                                color: Colors.white,
                                size: 28.0,
                              ),
                              SizedBox(
                                width: 6.0,
                              ),
                              Text(
                                'Sign In',
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
                      SizedBox(
                        width: 20.0,
                      ),
                      RaisedButton(
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        elevation: 8.0,
                        color: Colors.indigo,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, bottom: 10.0, right: 4.0, left: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.person_add,
                                color: Colors.white54,
                                size:25.0,
                              ),
                              SizedBox(
                                width: 6.0,
                              ),
                              Text(
                                'Sign Up',
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
                    ],
                  ),
                  SizedBox(height: 25.0),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:50.0),
                    child: TextFormField(
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        cursorColor: Colors.teal,
                        validator: (val) => val.isEmpty ? 'Enter Username' : (val.contains('@')? 'Invalid UserName' :  null) ,
                        
                        decoration: decoration(" Username"),
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        }),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:50.0),
                    child: TextFormField(
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      validator: (val) {
                          return val.length < 6 ? 'Enter a password 6+ chars long' : null;},
                      obscureText: true,
                      onChanged: (val) {
                        password = val;
                      },
                      decoration: decoration(" Password"),
                    ),
                  ),
                  
                 
                  SizedBox(height: 18.0),
                  
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 50.0),
                     child: ButtonForAuthentication(loading,() async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                loading = true;
                              });
                              dynamic result = await _auth
                                  .signInWithEmailAndPassword(email + '@iitk.ac.in', password);
                                  print(result);
                              if(result == 'false'){
                                setState(() {
                                  loading = false;
                                   Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                           return Break();
                                          }));
                                });
                              }
                              if (result == null) {
                                setState(() {
                                  error =
                                      'UserName / Password is incorrect';
                                  loading = false;
                                });
                              }
                            }
                              
                          },"Sign In",Icons.account_circle,
                     ),
                   ),
                   SizedBox(height: 18.0),
                  FlatButton(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.lock_outline),
                        Text("Forgot Password"),
                      ],
                    ),
                  onPressed: (){
                    
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext context) => new ResetPassword()));
                  }),
                  loading  ? Center(child: CircularProgressIndicator(backgroundColor: Colors.white)):
                  //error displaying
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 15.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

