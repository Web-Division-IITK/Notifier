import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About US')
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
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Text('The wait is over presenting an App that is made entirely for the IITK janta so as to limit their spamming of mailbox'),
                          SizedBox(height:10),
                          Chip(label: Row(
                            children: <Widget>[
                              Icon(Icons.copyright),
                              SizedBox(width: 10.0),
                              Text('Copyright by Web Division IITK'),
                            ],
                          ),),
                          
                        ],
                      ),
                    ),
                    // margin
                  ),
                  Chip(label: Text('Developers'),),
                  Card(
                    elevation: 50.0,
                    margin:EdgeInsets.all(16.0),
                    // child:SingleChildScrollView(
                      child: Container(
                        padding:EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: <Widget>[
                            
                            Container(
                              // decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
                              // height: MediaQuery.of(context).size.height*0.4,
                              height: 300.0,
                              child: Material(
                                elevation: 6.0,
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.circular(16.0),
                                child: Stack(
                                  children: <Widget>[
                                    Image.asset('assets/Aditya.png'),
                                    Positioned(
                                      bottom: 0.0,
                                      // left: 20.0,
                              // padding: const EdgeInsets.symmetric(vertical:10.0),
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(50.0,10.0,10.0,10.0,),
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
                              height: MediaQuery.of(context).size.height*0.4,
                              child: Center(child: Text('Image of UtkarshGupta'))
                              // child: Image.asset('assets/Aditya.png')
                              ),
                            Text('Utkarsh Gupta')
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