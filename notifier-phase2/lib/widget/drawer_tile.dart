import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final Widget routeWidget;
  final Function onTap;
  final String title;
  final IconData icon;
  DrawerTile(
      {this.routeWidget, @required this.title, @required this.icon, this.onTap})
      : assert(routeWidget != null || onTap != null);
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if(onTap == null ){  
            Navigator.of(context).pop();
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              // return CreatePosts(id, _subs,name);
              return SafeArea(child: routeWidget);
            }));}
          else onTap();
        },
        child: Container(
          height: 55.0,
          padding: EdgeInsets.only(left: 15.0),
          child: Row(
            children: <Widget>[
              Icon(icon),
              Container(
                padding: EdgeInsets.only(left: 32.0, top: 15.0, bottom: 15.0),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Nunito'),
                ),
              ),
            ],
          ),
        ));
  }
}
