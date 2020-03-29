import 'package:flutter/material.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/authentication/loginsignuppage.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/databse.dart';
import 'package:notifier/services/function.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
  ERROR,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth,this.darkMode});
  bool darkMode;
  final BaseAuth auth;
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  bool loading = true;
  @override
  void initState() {
    super.initState();
    // loading = true;
    // buildWaitingScreen();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    var uid;
    loading = true;
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        uid = user.uid;
      });
    }).whenComplete(() async{
      print('populating users');
      
      await populateUsers(uid, loading).then((bool status) {
        
      //   readContent('users').then((var v){
      // if(v == null){
      //   setState(() {
      //     loading = true;
      //     authStatus = AuthStatus.NOT_DETERMINED;5
      //   });
      // // }
      // else if(v!=null){
        print(status);
        setState(() {
          if(status == true ){
          loading = false;
          authStatus =  AuthStatus.LOGGED_IN;
          // authStatus =  AuthStatus.ERROR;

          }
        });
      // }
    // });
        // setState(() {
        //   loading = false;
        //   // authStatus = AuthStatus.LOGGED_IN;
        // });
      });
    }).catchError((var e){
      print(e);
      setState(() {
        authStatus = AuthStatus.ERROR;
      });
    });
    
    setState(() {
      authStatus = loading ? AuthStatus.NOT_DETERMINED : AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      widget.darkMode = false;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      // appBar: AppBar(
      //   // title: Text('Home'),

      // ),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
  Widget buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),

      ),
      
      body: Container(
        alignment: Alignment.center,
        child: RefreshIndicator(
          onRefresh: ()async{
            loginCallback();
          },
          child: Container(
            child:Center(
                 child: Text('Error while doing your operation, pleasetry again later!! \nCheck your internet connection',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 25.0,
                  ),
                 ),
               ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignupPage(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.ERROR:
        return buildErrorScreen();
        break;
      // case AuthStatus.NOT_LOGGED_IN:
      //     return new LoginSignupPage(
      //       auth: widget.auth,
      //       loginCallback: loginCallback,
      //     );
      // break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return new HomePage(
            darkMode :widget.darkMode,
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
