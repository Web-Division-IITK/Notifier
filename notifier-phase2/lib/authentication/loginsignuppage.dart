
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:notifier/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/authentication/reset_password.dart';
import 'package:notifier/database/student_search.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/widget/showtoast.dart';

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
  bool obsecureText = true;
  bool obsecureText1 = true;
  // var _conPassword;
  String userId = "";
  String _errorMessage;
  // final FirebaseMessaging _fcm = FirebaseMessaging();

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
      userId = "";
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    
      try {
        if (_isLoginForm) {
          setState(() {
            id = _email.toString().replaceAll('@iitk.ac.in', '');
          });
          userId = await widget.auth.signIn(_email, _password);
          
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password).whenComplete((){
          });
          //widget.auth.sendEmailVerification();
          //_showVerifyEmailSentDialog();
          print('Signed up user: $userId');
          setState(() {
            _isLoading = false;
          });
        }
        
        if(userId == 'notverified' && _isLoginForm){
          setState(() {
            _isLoading = false;
          });
          _showVerifyEmailDialog();
        }
        if (userId != null && userId.length > 0 ) {
          // auth().intialiseAuthValues(id, userId);
          auth.updateAll((key, value) {
            if(key == 'id'){
              return value = id??"";
            }
            else return value = userId??"";
          });
          print(auth);
          await getStudentDataFromServer();
          print('MOVING FORWARD TO COUNCIL DATA.....');
          widget.loginCallback();
        }else{
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          showErrorToast(
            _errorMessage,
          );
          _formKey.currentState.reset();
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
         content: Column(
           mainAxisAlignment: MainAxisAlignment.end,
           mainAxisSize: MainAxisSize.min,
           children: <Widget>[
             new Text("You need to verify your account in the link sent to email to begin"),
           ],
         ),
         actions: <Widget>[
           new RaisedButton(
             padding: EdgeInsets.all(8.0),
             child: new Text("Resend link"),
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
      obsecureText = false;
      obsecureText1 = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // appBar: new AppBar(
        //   title: new Text(_isLoginForm ? 'Login' : 'SignUp'),
        // ),
        body: AbsorbPointer(
          absorbing: _isLoading,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.bottomCenter,
            children: <Widget>[
               _showForm(),
              showCircularProgress(),
            ],
          ),
        ));
  }

  Widget _showForm() {
    return new Form(
      // autovalidate: true,
          key: _formKey,
          child: new ListView(
            padding: EdgeInsets.symmetric(horizontal :16.0),
            children: <Widget>[
              SizedBox(height:MediaQuery.of(context).size.height*0.2),
              showLogo(),
              showEmailInput(),
              showPasswordInput(),
              _isLoginForm ? SizedBox() : showConfirmPasswordInput(),
              showPrimaryButton(),
              SizedBox(height:5.0),
              showSecondaryButton(),
              SizedBox(height:2.0),
              _isLoginForm ? showForgotPassButton() : SizedBox(),
              SizedBox(height: 20.0),
            ],
          ),
        );
  }

  Widget showCircularProgress() {
    if (_isLoading) {
      return Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            userId == 'notverified' || userId == null || userId == "" || userId.trim() == '' || userId.trim() == null ?
            
            (_isLoginForm ?
            Text('Signing in',style: TextStyle(color: Colors.white))
            : Text('Signing up',style: TextStyle(color: Colors.white)))
            
            : Text('Fetching up your data from server!!!',style: TextStyle(color: Colors.white)),
            // CircularProgressIndicator(),
            SizedBox(height: 10,),
            SpinKitThreeBounce(color: Theme.of(context).accentColor,size: 30)
            
          ],
        )),
      );
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
        height: MediaQuery.of(context).size.height*0.2,
          child: Center(child: Image.asset('assets/launch.png')),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: new TextFormField(
        toolbarOptions: ToolbarOptions(
          copy: true,
          paste: true,
          selectAll: true,
        ),
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
        toolbarOptions: ToolbarOptions(
          copy: true,
          paste: true,
          selectAll: true,
        ),
        maxLines: 1,
        obscureText: obsecureText,
        textInputAction: _isLoginForm? TextInputAction.send : TextInputAction.done,
        autofocus: false,
        onFieldSubmitted: (text){
          return _isLoginForm?
          validateAndSubmit()
          : null;
        },
        decoration: new InputDecoration(
          isDense: true,
          helperText: !_isLoginForm?'Length of password should be greater than 6':null,
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            ),
            // suffixIcon: Icon(MaterialIcons.visibility)
            // suffix: IconButton(icon: Icon(
            //   obsecureText?
            //     MaterialIcons.visibility
            //     : MaterialIcons.visibility_off
            //   ), onPressed: (){
            //     setState(() {
            //       obsecureText = !obsecureText;
            //     });

            //   })
            suffix: Tooltip(
              message: obsecureText ? "Show Password" : "Hide Password",
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                child: Icon(
                  obsecureText?
                  MaterialIcons.visibility
                  : MaterialIcons.visibility_off
                ),
                onTap: (){
                  setState(() {
                    obsecureText = !obsecureText;
                  });
                },
              )
            ),
          ),
            onChanged: (value){
              _password = value;
            },
        // autovalidate: true,
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : (value.length<6 ? 'Password should be greater than 6 charhters' :null),
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
        onFieldSubmitted: (value)=>validateAndSubmit(),
        decoration: new InputDecoration(
          // suffix:  IconButton(icon: Icon(
          //     obsecureText1?
          //       MaterialIcons.visibility
          //       : MaterialIcons.visibility_off
          //     ), onPressed: (){
          //       setState(() {
          //         obsecureText1 = !obsecureText1;
          //       });
              // }),
            // suffix: Tooltip(
            //   message: obsecureText1 ? "Show Password" : "Hide Password",
            //   child: InkWell(
            //     borderRadius: BorderRadius.circular(40),
            //     child: Icon(
            //       obsecureText1?
            //       MaterialIcons.visibility
            //       : MaterialIcons.visibility_off
            //     ),
            //     onTap: (){
            //       setState(() {
            //         obsecureText1 = !obsecureText1;
            //       });
            //     },
            //   )
            // ),
            // helperText: '',
            hintText: 'Confirm Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        // onChanged: ,
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
            // color: Colors.black38,
            // splashColor: Colors.black,
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
}
