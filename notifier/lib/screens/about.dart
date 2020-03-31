import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top:50.0),
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
                    margin:EdgeInsets.all(16.0),
                    // child:SingleChildScrollView(
                      child: Container(
                        padding:EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: <Widget>[
                            
                            Container(
                              height: MediaQuery.of(context).size.height*0.4,
                              child: Image.asset('assets/Aditya.png')),
                            Container(
                              height: MediaQuery.of(context).size.height*0.4,
                              child: Center(child: Text('Image of UtkarshGupta'))
                              // child: Image.asset('assets/Aditya.png')
                              ),
                            // Text('This is my very first pro')
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