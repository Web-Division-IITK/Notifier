import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/authentication/authentication.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:notifier/color/decoration.dart';
// import 'package:notifier/services/auth.dart';
// import 'package:notifier/shared/loading.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword({@required this.auth});

  final BaseAuth auth;
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

bool doneReset = false;

class _ResetPasswordState extends State<ResetPassword> {
  // final AuthService _auth = AuthService();
  final _formKey = new GlobalKey<FormState>();
  String _email;
  String _errorMessage;

  bool _isLoading;

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
      // String userId = "";
      try {
        // if (_isLoginForm) {
        // userId = await widget.auth.signIn(_email);
        dynamic result = await widget.auth.sendPasswordResetEmail(_email);
        // print('Signed in: $userId');
        // } else {
        //   userId = await widget.auth.signUp(_email, _password);
        //   //widget.auth.sendEmailVerification();
        //   //_showVerifyEmailSentDialog();
        //   print('Signed up user: $userId');
        // }
        if (result != true) {
          setState(() {
            doneReset = false;
            _errorMessage = result;
            // error =
            //     'Couldn\'t process request at this time';
            _isLoading = false;
          });
        } else {
          setState(() {
            doneReset = true;
            _isLoading = false;
          });
        }
        if (doneReset) {
          Fluttertoast.showToast(msg:'Reset password email has been sent to your mail id');
          Navigator.of(context).pop();
        }
        // setState(() {
        //   _isLoading = false;
        // });

        // if (userId.length > 0 && userId != null ) {
        //   widget.loginCallback();
        // }
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
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
    // }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    // _isLoginForm = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  @override
  Widget build(BuildContext context) {
    return /*loading
        ? Loading(Colors.white)
        :*/
        Scaffold(
            appBar: AppBar(
              // actionsIconTheme: IconThemeData(),
              // automaticallyImplyLeading: false,
              // backgroundColor: Colors.white,
              elevation: 0.0,
              leading: IconButton(
                alignment: Alignment.center,
                tooltip: "Back",
                padding: EdgeInsets.all(0.0),
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text('Reset Password')
              // title: Text('Reset Password'),
            ),
            body:  Stack(
              fit: StackFit.expand,
                  children: <Widget>[
                    _showForm(),
                    showCircularProgress(),
                  ],
                ));

    //     Form(
    //         key: _formKey,
    //         child: ListView(
    //           children: <Widget>[

    //             SizedBox(height: 50.0),
    //             Padding(
    //               padding: EdgeInsets.symmetric(horizontal: 50.0),
    //               child: TextFormField(
    //                   style: TextStyle(
    //                     color: Colors.black,
    //                   ),
    //                   cursorColor: Colors.teal,
    //                   validator: (val) => val.isEmpty
    //                       ? 'Enter an email'
    //                       : (!val.contains('@') ? 'Invalid Email' : null),
    //                   decoration: decoration(" Email"),
    //                   onChanged: (val) {
    //                     setState(() {
    //                       email = val;
    //                     });
    //                   }),
    //             ),
    //             SizedBox(height: 18.0),
    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 50.0),
    //               // child: ButtonForAuthentication(false, () async {
    //               //   if (_formKey.currentState.validate()) {
    //               //     setState(() {
    //               //       loading = true;
    //               //     });
    //               //     dynamic result =
    //               //         await _auth.sendPasswordResetEmail(email);

    //               //     if (result == null) {
    //               //       setState(() {
    //               //         error =
    //               //             'Couldn\'t process request at this time';
    //               //         loading = false;
    //               //       });
    //               //     }
    //               //     else {
    //               //      doneReset = true;
    //               //      loading = false;
    //               //     //  Navigator.of(context).pop();
    //               //     }
    //               //   }
    //               // }, "Reset Password", Icons.refresh,
    //               // ),
    //               child: RaisedButton(
    //                 shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
    //                 elevation: 8.0,
    //                 splashColor: Colors.deepPurple[900],
    //                 color: Colors.deepPurpleAccent[400],
    //                 child: Padding(
    //                   padding: const EdgeInsets.only(
    //                       top: 15.0, bottom: 15.0, right: 5.0, left: 0.0),
    //                   child:  Row(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: <Widget>[
    //                       Icon(
    //                         Icons.refresh,
    //                         color: Colors.white,
    //                         size: 25.0,
    //                       ),
    //                       SizedBox(
    //                         width: 6.0,
    //                       ),
    //                       Text(
    //                         "Reset Password",
    //                         style: TextStyle(
    //                           color: Colors.white,
    //                           fontSize: 20.0,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                  onPressed: () async {
    //                 if (_formKey.currentState.validate()) {
    //                   setState(() {
    //                     loading = true;
    //                   });
    //                   dynamic result =
    //                       await _auth.sendPasswordResetEmail(email);

    //                   if (result != true) {
    //                     setState(() {
    //                       doneReset = false;
    //                       error = result;
    //                       // error =
    //                       //     'Couldn\'t process request at this time';
    //                       loading = false;
    //                     });
    //                   }
    //                   else {
    //                    setState(() {
    //                      doneReset = true;
    //                      loading = false;

    //                    });

    //                  }
    //                  if(doneReset){
    //                    Navigator.of(context).pop();
    //                  }
    //                 }
    //                  }
    //               ),
    //             ),

    //             SizedBox(height: 18.0),
    //             // loading
    //             //     ? SpinKitThreeBounce(
    //             //         itemBuilder: (BuildContext context, int index) {
    //             //           return DecoratedBox(
    //             //             decoration: BoxDecoration(
    //             //               shape: BoxShape.circle,
    //             //               color: (index % 2 == 0)
    //             //                   ? (Colors.blueAccent)
    //             //                   : Colors.orange,
    //             //             ),
    //             //           );
    //             //         }, // this is when the default loading does not work
    //             //       )
    //             //     :
    //                 //error displaying
    //                 Text(
    //                     error,
    //                     style:
    //                         TextStyle(color: Colors.red, fontSize: 15.0),
    //                     textAlign: TextAlign.center,
    //                   ),
    //           ],
    //         )),
    //   ),
    // );
  }

  Widget _showForm() {
    return  new Form(
          key: _formKey,
          child: new ListView(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              showEmailInput(),
              // showPasswordInput(),
              // _isLoginForm? null : showConfirmPasswordInput(),
              showPrimaryButton(),
              // showSecondaryButton(),
              // showErrorMessage(),
            ],
          ),
        );
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

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            // color: Colors.blue,
            child: new Text('Reset Password',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }

  Widget showLogo() {
    return new Hero(
      tag: 'imagevb',
      child:  Container(
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
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim() + '@iitk.ac.in',
      ),
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }
}
