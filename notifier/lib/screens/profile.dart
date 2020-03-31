import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/services/databse.dart';
import 'package:qr_flutter/qr_flutter.dart';

String name;
String rollno;

class ProfilePage extends StatefulWidget {
  final String id;
  final String uid;
  ProfilePage(this.uid,
    this.id,
  );
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _jsonData;
  bool _load;
  // List<Widget> preferences = List();
  Future<bool> preferen() async {
    return await readContent('users').then((var value) {
      if (value != null) {
        _jsonData = value;
        setState(() {
          name = _jsonData['name'];
          rollno = _jsonData['rollno'];
          print(_jsonData);
          print(_jsonData['prefs']);
          // if (_jsonData != null && _jsonData['prefs'] != null &&_jsonData['prefs'].length!=0) {
          //   for (var i in _jsonData['prefs']) {
          //     preferences.add(menuCard(i.toString()));
          //   }
          // }
        });
        print(_jsonData);
        return true;
      }
      return false;
    });
  }

  void writeposts() async {
    await writeContent('users', json.encode(_jsonData)).then((bool status) {
      if (status) {
        name = _jsonData['name'] ?? null;
        rollno = _jsonData['rollno'] ?? null;
        print(_jsonData);
        Fluttertoast.showToast(msg: 'Done!!');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _load = true;
    preferen().then((bool v) {
      if (v == null) {
      } else if (v) {
        // if(_jsonData['prefs'] == null){
        //   setState(() {

        //   });
        // }
        // else{
        setState(() {
          _load = false;
        });
        // }

      } else {}
    });
    // writeposts();
  }

  @override
  Widget build(BuildContext context) {
    // _name = widget.name;
    return Scaffold(
        body: _load ?Center(child: CircularProgressIndicator())
    :ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              height: 350.0,
              width: double.infinity,
            ),
            Container(
              height: 200.0,
              width: double.infinity,
              color: Color(0xFFFA624F),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.white,
              ),
            ),
            Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.only(top:10.0),
                      child: Text('E-iCard',style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.white,
                          fontFamily: 'Nunito',
                        ),),
                    ),
                  ),
            Positioned(
              top: 125.0,
              left: 15.0,
              right: 15.0,
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  height: 200.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color:Theme.of(context).brightness == Brightness.light
                      ?Colors.white:
                      Colors.black),
                ),
              ),
            ),
            Positioned(
                top: 75.0,
                left: (MediaQuery.of(context).size.width / 2 - 50.0),
                // child: Container(
                //   height: 100.0,
                //   width: 100.0,
                //   decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(50.0),
                //       color: Colors.blue

                //       // image: DecorationImage(
                //       //     image: AssetImage('assets/chris.jpg'),
                //       //     fit: BoxFit.cover)
                //           ),
                // ),
                child: CircleAvatar(
                  radius: 50.0,
                  child: Text(
                      name == null || name == ''
                          ? widget.id[0].toUpperCase()
                          : name[0].toUpperCase(),
                      style: TextStyle(fontSize: 40.0)),
                )),
            Positioned(
              top: 190.0,
              left: (MediaQuery.of(context).size.width / 2) - 135.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    name == null || name == '' ? widget.id : _jsonData['name'],
                    style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                  ),
                  SizedBox(height: 7.0),
                  name == null || name == ''
                      ? Text('')
                      : Text(
                          widget.id,
                          style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey),
                        ),
                 rollno == null || rollno == ''
                      ?SizedBox():SizedBox(height: 10.0,),
                        rollno == null || rollno == ''
                      ? Text('')
                      : Text(
                          _jsonData['rollno'],
                          style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              ),
                        ),
                  SizedBox(height: 10.0),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130.0,
                        child: name == null || name == ''?FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          color: Color(0xFFFA624F),
                          onPressed: () {
                            _updateDialog('name');
                          },
                          child: Text('Add Name',                                
                            style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: Colors.white),
                          ),
                        ):
                        ((rollno == null || rollno == '')?
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          color: Color(0xFFFA624F),
                          onPressed:  null,
                          child: Text('Add Name',                                
                            style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: Colors.white),
                          ),
                        ):
                        Container())
                        ,
                      ),
                      SizedBox(width: 5.0),
                      Container(
                        width: 130.0,
                        child: rollno == null || rollno == ''
                            ? FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                color: Colors.grey,
                                onPressed: () {
                                  _updateDialog('rollno');
                                },
                                child: Text('Add Rollno',
                                  style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                      color: Colors.white),
                                ),
                              )
                            : Container()
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Qr Code',
                style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              // (
              //   child: Text(
              //     'see all',
              //     style: TextStyle(
              //         fontFamily: 'Comfortaa',
              //         fontSize: 15.0,
              //         color: Colors.grey,
              //         fontWeight: FontWeight.w300),
              //   ),
              // )
            ],
          ),
        ),
        SizedBox(height: 10.0),
        Center(
          child: QrImage(data:widget.id + '@iitk.ac.in',
          foregroundColor:Theme.of(context).brightness == Brightness.light ?
          Colors.black:Colors.white,
            size: 200.0,
          ),
        ),
        // _load
        //     ? Center(child: CircularProgressIndicator())
        //     : (_jsonData['prefs'] != null && _jsonData['prefs'].length != 0
        //         ? Column(
        //             children: preferences,
        //           )
        //         : Center(
        //             child: Text(
        //             'You currently have no subscriptions',
        //             style: TextStyle(color: Colors.black),
        //           ))),
        // ListView.builder(
        //   shrinkWrap: true,
        //   itemCount: widget.prefs.length,
        //   itemBuilder: (BuildContext context ,int index){
        //     print(widget.prefs.toString());
        //     return
        // }),
        // Column(
        //   children: <Widget>[
        //     menuCard('Berry banana milkshake', 'assets/bananabreak.jpg',
        //         'Breakfast', 4, 2.8, 1.2),
        //     SizedBox(height: 12.0),
        //     menuCard('Fruit pancake', 'assets/fruitbreak.jpeg', 'Breakfast', 4,
        //         4.2, 2.8),
        //   ],
        // ),
        SizedBox(height: 25.0),
        // Padding(
        //   padding: EdgeInsets.only(left: 15.0, right: 15.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       Text(
        //         'Works',
        //         style: TextStyle(
        //             fontFamily: 'Comfortaa',
        //             fontSize: 17.0,
        //             fontWeight: FontWeight.bold),
        //       ),
        //       Text(
        //         'see all',
        //         style: TextStyle(
        //             fontFamily: 'Comfortaa',
        //             fontSize: 15.0,
        //             color: Colors.grey,
        //             fontWeight: FontWeight.w300),
        //       )
        //     ],
        //   ),
        // ),
        // SizedBox(height: 10.0),
        // Padding(
        //   padding: EdgeInsets.only(left: 15.0, right: 5.0),
        //   child: Container(
        //     height: 125.0,
        //     child: ListView(
        //       scrollDirection: Axis.horizontal,
        //       children: <Widget>[
        //         getWorks('assets/fruitpancake.jpeg'),
        //         getWorks('assets/dumplings.jpeg'),
        //         getWorks('assets/noodles.jpeg'),
        //       ],
        //     ),
        //   ),
        // ),
        // SizedBox(height: 15.0),
        // Padding(
        //   padding: const EdgeInsets.only(left: 15.0, right: 15.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       Text(
        //         'Bought',
        //         style: TextStyle(
        //             fontFamily: 'Comfortaa',
        //             fontSize: 17.0,
        //             fontWeight: FontWeight.bold),
        //       ),
        //       Text(
        //         'see all',
        //         style: TextStyle(
        //             fontFamily: 'Comfortaa',
        //             fontSize: 15.0,
        //             color: Colors.grey,
        //             fontWeight: FontWeight.w300),
        //       )
        //     ],
        //   ),
        // ),
        // SizedBox(height: 15.0),
      ],
    ));
  }

  _updateDialog(type) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          final _formKey = GlobalKey<FormState>();
          String _name;
          // return Container(
          return Dialog(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            child: Form(
              key: _formKey,
              child: Container(
                // height: 300.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                      child: Material(
                        child: TextFormField(
                          maxLines: 1,
                          keyboardType: type == 'name'
                              ? TextInputType.emailAddress
                              : TextInputType.number,
                          autofocus: false,
                          initialValue: type == 'name' ? name : rollno,
                          decoration: new InputDecoration(
                            labelText: type == 'name' ? 'Name' : 'Rollno',
                            // hintText: 'Your NAme',
                            // icon: new Icon(
                            //   Icons.mail,
                            //   color: Colors.grey,
                            // )
                          ),
                          validator: (value) => value.isEmpty
                              ? (type == 'name'
                                  ? 'Name can\'t be empty'
                                  : 'Roll no can\'t be empty')
                              : null,
                          onSaved: (value) => _name = value,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 5.0, top: 25.0),
                      // height: 100.0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                                // color: Colors.blue,
                                onPressed: () {
                                  // Fluttertoast.showToast(msg: 'Creating post');
                                  // Fluttertoast.cancel();
                                  // print(createTagsToList(tags[0]));
                                  // tags = _tag.split(';');
                                  Navigator.of(context).pop();
                                  // if(validateAndSave()){
                                  //   confirmPage();
                                  // }
                                },
                                child: Text('Dismiss')),
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: RaisedButton(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  color: Colors.blue,
                                  onPressed: () {
                                    // Fluttertoast.showToast(msg: 'Creating post');
                                    // Fluttertoast.cancel();
                                    // print(createTagsToList(tags[0]));
                                    // tags = _tag.split(';');
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      setState(() {
                                        if (type == 'name') {
                                          _jsonData['name'] = _name;
                                          name = _name;
                                          updateNameinFirebase(widget.uid, name);
                                        } else {
                                          _jsonData['rollno'] = _name;
                                          rollno = _name;
                                          updateRollNoinFirebase(widget.uid, rollno);
                                        };
                                        writeposts();
                                      });
                                      Navigator.of(context).pop();
                                      // confirmPage();
                                    }
                                  },
                                  child: Text(
                                    type == 'name'
                                        ? (name == null || name == ''
                                            ? 'Add Name'
                                            : 'Update Name')
                                        : (rollno == null || rollno == ''
                                            ? 'Add Rollno'
                                            : 'Update Rollno'),
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ]),
                    )
                    // )
                  ],
                  // )
                ),
              ),
            ),
          );
        });
  }

  Widget getWorks(String imgPath) {
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: Container(
        height: 100.0,
        width: 125.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          // image: DecorationImage(
          //   image: AssetImage(imgPath),
          // fit: BoxFit.cover
          // )
        ),
      ),
    );
  }

  Widget menuCard(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        elevation: 4.0,
        child: Container(
          height: 50.0,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0), color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // SizedBox(width: 10.0),
              // Container(
              //   height: 1.0,
              //   width: 100.0,
              //   decoration: BoxDecoration(
              //       // image: DecorationImage(
              //       //     image: AssetImage(imgPath), fit: BoxFit.cover),
              //       borderRadius: BorderRadius.circular(7.0)),
              // ),
              // SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 15.0),
                  Text(
                    title,
                    style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                  // SizedBox(height: 7.0),
                  // Text(
                  //   type,
                  //   style: TextStyle(
                  //       fontFamily: 'Comfortaa',
                  //       color: Colors.grey,
                  //       fontSize: 14.0,
                  //       fontWeight: FontWeight.w400),
                  // ),
                  // SizedBox(height: 7.0),
                  // Row(
                  //   children: <Widget>[
                  //     getStar(rating, 1),
                  //     getStar(rating, 2),
                  //     getStar(rating, 3),
                  //     getStar(rating, 4),
                  //     getStar(rating, 5)
                  //   ],
                  // ),
                  // SizedBox(height: 4.0),
                  // Row(
                  //   children: <Widget>[
                  //     Icon(Icons.remove_red_eye,
                  //         color: Colors.grey.withOpacity(0.4)),
                  //     SizedBox(width: 3.0),
                  //     Text(views.toString()),
                  //     SizedBox(width: 10.0),
                  //     Icon(
                  //       Icons.favorite,
                  //       color: Colors.red,
                  //     ),
                  //     SizedBox(width: 3.0),
                  //     Text(likes.toString())
                  //   ],
                  // )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getStar(rating, index) {
    if (rating >= index) {
      return Icon(Icons.star, color: Colors.yellow);
    } else {
      return Icon(Icons.star, color: Colors.grey.withOpacity(0.5));
    }
  }
}
