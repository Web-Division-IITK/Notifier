import 'package:flutter/material.dart';
import 'package:notifier/screens/authenticate/authenticate.dart';
import 'package:notifier/screens/authenticate/break.dart';
import 'package:notifier/screens/home/home.dart';
import 'package:notifier/screens/home/stream.dart';
import 'package:notifier/services/auth.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/shared/function.dart';
import 'package:notifier/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:notifier/models/user.dart';

import '../main.dart';

// class Wrapper extends StatefulWidget {
//   // final Function toggleTheme;

//   Wrapper();
//   @override
//   _WrapperState createState() => _WrapperState();
// }
var count =0;
bool load = false;
bool val;
class Wrapper extends StatelessWidget {
  @override
//   Widget build(BuildContext context) {
//     return Container(
      
//     );
//   }
// }
// class _WrapperState extends State<Wrapper> {
  
//   @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final user = Provider.of<User>(context);
    
    // print(user);
    if (user == null) {
      return Authenticate();
    } else {
      //  _auth.isEmailVerified().then((var result){
      //    val = result;
      //  });
      // // print(val);
      // if(val == null){
      //   return Loading();
      // }
      // if(val) {
          return ChoiceWidget(user);
      //   }
        //  return Break();
    }
  }
}

class ChoiceWidget extends StatefulWidget {
  final User user;
  ChoiceWidget(this.user);
  @override
  _ChoiceWidgetState createState() => _ChoiceWidgetState();
}

class _ChoiceWidgetState extends State<ChoiceWidget> {
  @override
  Widget build(BuildContext context) {
    // readContent('users').then((Map<String,dynamic> value){
    //     setState(() {
    //       if(value['id'] == null){
    //         load = true;
    //       }
    //       print(value);
    //     });
    //   });
    // if (load) {
        // print('kg');
        return AddContentData();
      // }
      // else{
      //   // print('hv');
      // return Home(widget.user);
      // }
}
}
