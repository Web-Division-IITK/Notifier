import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/authentication/loginsignuppage.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'database/hive_database.dart';
import 'database/student_search.dart';
enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
  ERROR,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  bool loading = true;
  static int i = 0;
  @override
  void initState() {
    super.initState();
    // if (i == 0) {
    //   getStudentDataFromServer();
    //   i++;
    // }
    widget.auth.getCurrentUser().then((user) {
      print(user);
      setState(() {
        if (user != null && user != 'notverified') {
          _userId = user;
        }
        
      });
      setState(() {
        authStatus =
            (user == null || user == 'notverified')? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    var uid;
    loading = true;
    widget.auth.getCurrentUser().then((user) async{
      setState(() {
        _userId = user.toString();
        uid = user;
      });
      if(uid!=null){
        if(uid != 'notverified'){
          print('populating users');
          return await populateAppData(uid).then((var status) {
            print(status);
            
            if(status == false){
              setState(() {
                loading = false;
                authStatus =  AuthStatus.ERROR;
              });
            }else{
              setState(() {
                loading = false;
                authStatus = AuthStatus.LOGGED_IN;
              });
            }
            
          });
        }else{
          setState(() {
            loading = false;
            authStatus =  AuthStatus.NOT_LOGGED_IN;
          });
        }
      }else{
        setState(() {
          authStatus = AuthStatus.ERROR;
        });
      }
    }).catchError((var e){
      print(e);
      setState(() {
        authStatus = AuthStatus.ERROR;
      });
    });
    
    // setState(() {
    //   authStatus = loading ? AuthStatus.NOT_DETERMINED : AuthStatus.LOGGED_IN;
    // });
  }

  void logoutCallback() async{
    setState(() {
      // widget.darkMode = false;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      
      _userId = "";
    });
    id = "";
    ids = [];
    await HiveDatabaseUser().deleteAllBoxes();
    //  var vhjnb = await DBProvider().deleteData();
    //  vhjnb != null ? print('deletion success'): print('deletefailed');
     var vhjnbd = await DatabaseProvider().deleteData();
     vhjnbd != null ? print('deletion success'): print('deletefailed');
     var vhjnbdt = await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deleteData();
     vhjnbdt != null ? print('deletion success'): print('deletefailed');
    var h = await removeValues();
    h != null ?print('deletion success'): print('deletefailed');
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Loading App data'),
              SizedBox(height: 10.0),
              SpinKitThreeBounce(color: Theme.of(context).accentColor,size: 30,)
              // CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(AntDesign.logout),
            onPressed: ()async{
              try {
                // subscribeUnsubsTopic([], (userData.toMap()[0]?.prefs == null)? []:userData.toMap()[0]?.prefs);
                await widget.auth.signOut();
                logoutCallback();
              } catch (e) {
                print(e);
              }
            },
          )
        ],
      ),
      
      body: Container(
        alignment: Alignment.center,
        child: Container(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text('Error while fetching your data , please try again later \nor try checking your connectivity',
                textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    // fontSize: 25.0,
                  ),
                ),
              ),
              RaisedButton.icon(
                onPressed: (){
                  loginCallback();
                },
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // print(_userId);
    // FutureBuilder(
    //   future: Firebase.initializeApp(),
    //   builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {\
        // StreamBuilder(
        //   stream: FirebaseAuth.instance.authStateChanges() ,
        //   initialData: null ,
        //   builder: (BuildContext context, AsyncSnapshot<User> snapshot){
        //     if(snapshot == null || snapshot.data == null){
        //       return Container();
        //     }else if(!snapshot.data.emailVerified){
        //       return Container();
        //     }else{
        //       return Container();
        //     }
        //   },
        // );
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
      case AuthStatus.NOT_LOGGED_IN:
          return new LoginSignupPage(
            auth: widget.auth,
            loginCallback: loginCallback,
          );
      break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null && _userId != 'notverified') {
          return SafeArea(child: HomePage(
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          ));
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
    //   },
    // );
  }
}
