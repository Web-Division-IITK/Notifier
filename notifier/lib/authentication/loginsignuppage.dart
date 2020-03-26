import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/authentication/reset_password.dart';

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({@required this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;
  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading;
  var _email;
  bool _isLoginForm;
  var _password;
  var _conPassword;
  String _errorMessage;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        if (_isLoginForm) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password).whenComplete((){
             _fcm.subscribeToTopic('Science_and_Technology_Council');
          });
          //widget.auth.sendEmailVerification();
          //_showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });
        if(userId == null && _isLoginForm){
          _showVerifyEmailDialog();
        }
        if (userId != null && userId.length > 0 ) {
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          Fluttertoast.showToast(
            backgroundColor: Colors.grey[300],
              timeInSecForIos: 3,
              msg: _errorMessage,
              textColor: Colors.red,
              fontSize: 13.0);
          _formKey.currentState.reset();
          // Fluttertoast(

          // );
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _resentVerifyEmail(){
   widget.auth.sendEmailVerification();
   _showVerifyEmailSentDialog();
 }
  void _showVerifyEmailDialog() {
   showDialog(
     context: context,
     builder: (BuildContext context) {
       // return object of type Dialog
       return AlertDialog(
         title: new Text("Verify your account"),
         content: new Text("You need to verify your account in the link sent to email to begin"),
         actions: <Widget>[
           new FlatButton(
             child: new Text("Resent link"),
             onPressed: () {
               Navigator.of(context).pop();
               _resentVerifyEmail();
             },
           ),
           new FlatButton(
             child: new Text("Dismiss"),
             onPressed: () {
               Navigator.of(context).pop();
             },
           ),
         ],
       );
     },
   );
 }

 void _showVerifyEmailSentDialog() {
   showDialog(
     context: context,
     builder: (BuildContext context) {
       // return object of type Dialog
       return AlertDialog(
         title: new Text("Verify your account"),
         content: new Text("Link to verify account has been sent to your email"),
         actions: <Widget>[
           new FlatButton(
             child: new Text("Dismiss"),
             onPressed: () {
               Navigator.of(context).pop();
             },
           ),
         ],
       );
     },
   );
 }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // appBar: new AppBar(
        //   title: new Text(_isLoginForm ? 'Login' : 'SignUp'),
        // ),
        body: Stack(
          children: <Widget>[
            _showForm(),
            showCircularProgress(),
          ],
        ));
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              doneReset
                  ? Container(
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
                                height: 45.0,
                                width: 265.0,
                                padding: EdgeInsets.only(left: 8.0, top: 5.0),
                                child: Text(
                                  "Reset password link has been sent to your email account",
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    // fontSize: 16.0
                                  ),
                                ),
                                // ),
                              ),
                            ],
                          ),
                          // ),
                          IconButton(
                            alignment: Alignment.centerRight,
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                doneReset = false;
                              });
                            },
                          )
                        ],
                      ))
                  : SizedBox(),
              showLogo(),
              showEmailInput(),
              showPasswordInput(),
              _isLoginForm ? SizedBox() : showConfirmPasswordInput(),
              showPrimaryButton(),
              showSecondaryButton(),
              _isLoginForm ? showForgotPassButton() : SizedBox(),
              // showErrorMessage(),
            ],
          ),
        ));
  }

  Widget showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Container(
        margin: EdgeInsets.only(top:100.0),
        height: 100.0,
        // padding: EdgeInsets.fromLTRB(0.0, 70.0, 70.0, 0.0),
        // child: CircleAvatar(
        //   backgroundColor: Colors.blue,
        //   radius: 48.0,
          // child:Icon(Icons.)
          child: Center(child: Image.asset('assets/launch.png')),
        // ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'CC UserId',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty
            ? 'UserID can\'t be empty'
            : (value.contains('@') ? 'Invalid UserName' : null),
        onSaved: (value) => _email = value.trim() + '@iitk.ac.in',
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showConfirmPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Confirm Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => (value != _password || value.isEmpty)
                                ? 'Passwords does not match':null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.black38,
            splashColor: Colors.black,
            child: new Text(_isLoginForm ? 'Login' : 'Create account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }

  Widget showSecondaryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: SizedBox(
        height: 22.0,
        child: new FlatButton(
            padding: EdgeInsets.all(0.0),
            child: new Text(
                _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
                style:
                    new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
            onPressed: toggleFormMode),
      ),
    );
  }

  Widget showForgotPassButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 4.0),
      child: SizedBox(
        height: 18.0,
        child: new FlatButton(
            padding: EdgeInsets.all(0.0),
            child: new Text('Forgot Password',
                style:
                    new TextStyle(fontSize: 15.0, fontWeight: FontWeight.w300)),
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new ResetPassword(auth: widget.auth)));
            }),
      ),
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      // return Container(
      //   width: double.infinity,
      //   child: Center(
      //     child: new Text(
      //       _errorMessage,
      //       style: TextStyle(
      //         fontSize: 13.0,
      //         color: Colors.red,
      //         height: 1.0,
      //       ),
      //     ),
      //   ),
      // );
       Fluttertoast.showToast(
          timeInSecForIos: 3,
          msg: _errorMessage,
          textColor: Colors.red,
          fontSize: 13.0);
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }
}
