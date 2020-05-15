
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:notifier/services/beautify_body.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us')
      ),
      body: Container(
        child:Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                // padding: EdgeInsets.only(top:50.0),
                children: <Widget>[
                  Card(
                    margin:EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          // CachedNetworkImage(imageUrl: ),
                          CircleAvatar(
                            backgroundImage:AssetImage('assets/wdLogo.png'),
                            radius: 60,
                          ),
                          
                          // Text('The wait is over presenting an App that is made entirely for the IITK janta so as to limit their spamming of mailbox'),
                          SizedBox(height:10),
                          Chip(label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Icon(Icons.copyright),
                              // SizedBox(width: 10.0),
                              Text('Made by Web Division IITK'),
                              
                            ],
                          ),),
                          Container(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(icon: Icon(AntDesign.mail),
                                    iconSize: 30.0,
                                    splashColor: Colors.blueGrey,
                                   onPressed: (){
                                     launchMail('webdivisioniitk@gmail.com');
                                   }),
                                  IconButton(icon: Icon(FontAwesome.slack),
                                    iconSize: 30.0,
                                     splashColor: Colors.blueGrey,
                                   onPressed: (){
                                     launchUrl('https://webdivisionworkspace.slack.com');
                                   }),
                                  IconButton(icon: Icon(FontAwesome.facebook_square),
                                   splashColor: Colors.blueGrey,
                                    iconSize: 30.0,
                                   onPressed: (){
                                     launchUrl('https://www.facebook.com/webdivisioniitk');
                                   }),
                                  IconButton(icon: Icon(FontAwesome.linkedin_square),
                                    // tooltip:,
                                   splashColor: Colors.blueGrey,
                                    iconSize: 30.0,
                                   onPressed: (){
                                     launchUrl('https://www.linkedin.com/company/42830702');
                                   }),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // margin
                  ),
                  Chip(label: Text('Developers'),
                    // avatar: Icon(Entypo.code),
                    // labelPadding: EdgeInsets.all(8),
                    // labelStyle: TextStyle(
                    //   fontSize: 20,
                    //   fontFamily: 'Raleway'
                    // ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
                    ),
                    elevation: 50.0,
                    margin:EdgeInsets.all(16.0),
                    // child:SingleChildScrollView(
                      child: Container(
                        padding:EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: <Widget>[
                            
                            Container(
                              width: 230.0,
                              // decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
                              // height: MediaQuery.of(context).size.height*0.4,
                              height: 300.0,
                              child: Material(
                                elevation: 6.0,
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.circular(16.0),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Image.asset('assets/Aditya.png',
                                      fit: BoxFit.fill,
                                    ),
                                    Positioned(
                                      bottom: 0.0,
                                      // left: 20.0,
                              // padding: const EdgeInsets.symmetric(vertical:10.0),
                                      child: Container(
                                        width: 230.0,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.fromLTRB(00.0,10.0,0.0,10.0,),
                                        color: Colors.black.withOpacity(0.4),
                                        child: Text('Aditya Gupta',
                                        textAlign: TextAlign.center, style:TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.white,
                                          // fontFamily: 'Comfortaa',
                                        )),
                                      ),
                                    ),
                                  ],
                                ))),

                            Container(
                              padding: EdgeInsets.only(top: 8.0,bottom: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(icon: Icon(AntDesign.github),
                                    iconSize: 30.0,
                                   onPressed: (){launchUrl('https://github.com/im-aditya30');}),
                                  IconButton(icon: Icon(FontAwesome.linkedin_square),
                                    iconSize: 30.0,
                                   onPressed: (){
                                     launchUrl('https://www.linkedin.com/in/aditya-gupta-7689391a8/');
                                   }),
                                  IconButton(icon: Icon(FontAwesome.facebook_square),
                                    iconSize: 30.0,
                                   onPressed: (){
                                     launchUrl('https://www.facebook.com/solisaditya');
                                   }),
                                  // IconButton(icon: Icon(MaterialCommunityIcons.web),
                                  //   iconSize: 30.0,
                                  //  onPressed: (){}),
                                ],
                              ),
                            ),
                             Container(
                              // decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
                              // height: MediaQuery.of(context).size.height*0.4,
                              height: 300.0,
                              width: 230.0,
                              child: Material(
                                elevation: 6.0,
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.circular(16.0),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Container(
                                      height: 300.0,
                              width: 230.0,
                                      child: Image.asset('assets/Utkarsh1.jpg',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0.0,
                                      // width: double.maxFinite,
                                      // left: 20.0,
                              // padding: const EdgeInsets.symmetric(vertical:10.0),
                                      child: Container(
                                        width: 230.0,
                                        alignment: Alignment.center,
                                        // width: double.maxFinite,
                                        padding: EdgeInsets.fromLTRB(0.0,10.0,0.0,10.0,),
                                        color: Colors.black.withOpacity(0.4),
                                        child: Text('Utkarsh Gupta',
                                        textAlign: TextAlign.center, style:TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.white,
                                          // fontFamily: 'Comfortaa',
                                        )),
                                      ),
                                    ),
                                  ],
                                ))),
                            // Text('Utkarsh Gupta'),
                            Container(
                              padding: EdgeInsets.only(top: 8.0,bottom: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(icon: Icon(AntDesign.github),
                                    iconSize: 30.0,
                                   onPressed: (){launchUrl('https://github.com/utkarshg99');}),
                                  IconButton(icon: Icon(FontAwesome.linkedin_square),
                                    iconSize: 30.0,
                                   onPressed: (){
                                     launchUrl('https://www.linkedin.com/in/utkarshg99/');
                                   }),
                                  IconButton(icon: Icon(FontAwesome.facebook_square),
                                    iconSize: 30.0,
                                   onPressed: (){
                                     launchUrl('https://www.facebook.com/utkarshg99');
                                   }),
                                  // IconButton(icon: Icon(MaterialCommunityIcons.web),
                                  //   iconSize: 30.0,
                                  //  onPressed: (){

                                  //  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  // ),
                ],
              )
            )
          ],
        )
      )
      
    );
  }
}