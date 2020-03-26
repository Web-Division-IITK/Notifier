import 'package:flutter/material.dart';
import 'package:notifier/models/user.dart';
import 'package:notifier/screens/home/display/preferences.dart';
import 'package:notifier/screens/home/home.dart';
import 'package:notifier/services/auth.dart';
import 'package:provider/provider.dart';


class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Drawer(
      child: ListView(
        children: <Widget>[
          HeaderDrawer(),
          DrawerItem('Home', (){
            Navigator.of(context).pop();
            Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context){
              return new Home(user);
            }));
          }),
          DrawerItem('Preferences', (){
            Navigator.of(context).pop();
            Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context){
              return new Preferences();
            }));
          }),
          // SizedBox(height: 20.0,),
          
          DrawerItem('Logout', () async{
              await _auth.signOut();
          }),
        ],
      )
    );
  }
}
class HeaderDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.3,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            maxRadius: 50.0,
          )
        ],
      )
    );
  }
}
class DrawerItem extends StatelessWidget {
  final String name;
  final Function onTap;
  DrawerItem(this.name,this.onTap);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical:10.0),
      child: InkWell(
        onTap: onTap,
        child: Center(child: Text(name,
        style: TextStyle(
          fontSize: 30.0
        ),)),
      ),
    );
  }
}