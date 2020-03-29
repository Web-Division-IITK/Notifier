import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/data/data.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/preferences.dart';
import 'package:notifier/services/databse.dart';

class MakeCoordi extends StatefulWidget {
  final List<String> ids;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  MakeCoordi(this.ids, this.auth, this.logoutCallback, this.userId);
  @override
  _MakeCoordiState createState() => _MakeCoordiState();
}

class _MakeCoordiState extends State<MakeCoordi> {
  String _selectedLocation;
  String _selectedId;
  final _formKey = GlobalKey<FormState>();
  String _id = "";
  List<String> selectedOptions = [];
  // TextFieldController
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  var _errorMessage;
  validateAndSubmit() async {
    setState(() { 
      _errorMessage = "";
      // _isLoading = true;
    });
    if (validateAndSave()) {
      // String userId = "";
      try {
         submit(_id, selectedOptions).then((var i) async{
                              if (i == 200) {
                                await readContent('users').then((var value)async{
                                  if(value!=null){
                                    List<dynamic>sub;
                                    value['admin'] = true;
                                    value['sub'] = selectedOptions;
                                    await writeContent('users',json.encode(value) ).then((bool status){
                                      if(status){
                                        setState(() {
                                          admin = true;
                                        });
                                        Fluttertoast.showToast(msg: 'Done!!');
                                        // Navigator.removeRouteBelow(context, anchorRoute)
                                        // Navigator.of(context).pop();
                                        
                                        // Navigator.removeRouteBelow(context, anchorRoute)
                                      }
                                    });
                                  }
                                });
                                
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        'Cannot process request at this time, please try again later !!');
                              }
         });
      } catch (e) {
        print('Error: $e');
        setState(() {
          // _isLoading = false;
          _errorMessage = e.message;
          Fluttertoast.showToast(
            backgroundColor: Colors.grey[300],
              timeInSecForIos: 3,
              msg: _errorMessage,
              textColor: Colors.red,
              fontSize: 13.0);
          _formKey.currentState.reset();
          // Fluttertoast(

          // );
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // return WillPopScope(
    //   onWillPop: ()async{
    //     return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context){
    //                                         return HomePage(userId: widget.userId,
    //           auth: widget.auth,
    //           logoutCallback: widget.logoutCallback,);
    //                                       }));
    //   },
    var locations = selectionData[0].name + ["Science and Technology Council", "Techkriti"];
     return Scaffold(
          appBar: new AppBar(
            title: new Text(
              'Make Coordinators',
            ),
            // actions:<Widget>[
            //  leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,), onPressed: (){
            //     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context){
            //                                 return HomePage(userId: widget.userId,
            //   auth: widget.auth,
            //   logoutCallback: widget.logoutCallback,);
            //                               }));
            //   })
            // ],
          ),
          // drawer: Drawer(
          //   child: ListView(
          //     children: <Widget>[
          //       Container(
          //         height: MediaQuery.of(context).size.width*0.5,
          //         color: Colors.black,
          //         child: Center(
          //           child: CircleAvatar(
          //             radius: 50.0,
          //             backgroundColor: Colors.blue,
          //             // child:
          //           ),
          //         )
          //       ),
          //       Container(
          //         height:35.0,
          //                       child: InkWell(
          //           onTap: (){
          //             Navigator.of(context).pop();
          //             Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
          //               return Preferences(widget.auth, widget.logoutCallback);
          //             }));
          //           },
          //           child: Container(
          //             padding: EdgeInsets.only(left: 15.0,top: 15.0),
          //             child: Text('Preferences',
          //               style: TextStyle(
          //                 fontSize:20.0,
          //               )
          //             ),)
          //         ),
          //       ),
          //   //     (id == 'adtgupta' || id == 'utkarshg') ?
          //       Container(
          //         height:35.0,
          //                       child: InkWell(
          //           onTap: (){
          //             Navigator.of(context).pop();
          //             Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context){
          //               return HomePage(auth: widget.auth,
          //               logoutCallback: widget.logoutCallback,
          //               userId: widget.userId);
          //             }));
          //           },
          //           child: Container(
          //             padding: EdgeInsets.only(left: 15.0,top:15.0),
          //             child: Text('Home',
          //               style: TextStyle(
          //     fontSize:20.0
          //   ),
          //             ),)
          //         ),
          //       )
          //   //     :Container(),
          //     ],
          //   )
          // ),
          body: SafeArea(
            child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    // direction: Axis.vertical,
                    // alignment: WrapAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40.0, 100.0, 40.0, 0.0),
                                    child: new TextFormField(
                                      maxLines: 1,
                                      // keyboardType: TextInputType.emailAddress,
                                      autofocus: false,
                                      decoration: new InputDecoration(
                                          hintText: 'CC Id',
                                          // icon: new Icon(
                                          //   Icons.mail,
                                          //   color: Colors.grey,
                                          // )
                                          ),
                                      validator: (value) => value.isEmpty
                                          ? 'CC ID can\'t be empty'
                                          : (value.contains('@')
                                              ? 'Invalid CC Id'
                                              : null),
                                      onSaved: (value) => _id = value.trim(),
                                    ),
                                  ),
                                  SizedBox(height:40.0),
                                  Text(selectionData[0].title),
                      // Container(
                      //   // padding: EdgeInsets.only(top: 80.0),
                      //   alignment: Alignment.bottomCenter,
                        // width: 300.0,
                        // height: MediaQuery.of(context).size.height * 0.5,
                        // child:
                                  // Text('Choose an ID'),
                                  // Center(
                                  //   child: DropdownButton(
                                  //     hint: Text('Please choose an ID'), // Not necessary for Option 1
                                  //     value: _selectedId,
                                  //     onChanged: (newValue) {
                                  //       setState(() {
                                  //         _selectedId = newValue;
                                  //       });
                                  //     },
                                  //     items: widget.ids.map((location) {
                                  //       return DropdownMenuItem(
                                  //         child: new Text(location),
                                  //         value: location,
                                  //       );
                                  //     }).toList(),
                                  //   ),
                                  // ),
                                  
                                  Center(
                                    child: DropdownButton(
                                      hint: Text(
                                          'Choose Entity'), // Not necessary for Option 1
                                      value: _selectedLocation,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedLocation = newValue;
                                        });
                                      },
                                      items: locations.map((location) {
                                        return DropdownMenuItem(
                                          child: new Text(location),
                                          value: location,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                               
                         
                      SizedBox(height: 30.0),
                      Container(
                        width:120.0,
                        // padding: const EdgeInsets.fromLTRB(60.0, 0.0, 60.0, 0.0),
                        child: RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      // color: Colors.blue,
                          child: Text('Save',
                            style: TextStyle(
                              // fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                              color:Colors.white
                            ),
                          ),
                          onPressed: () {
                            
                            selectedOptions.add(_selectedLocation);
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                // print(_selectedLocation);
                                Fluttertoast.showToast(msg: 'Making Coordinators');
                                validateAndSubmit();
                                

                                // if(response == )
                              });
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              // ),
            ),
          ),
    );
  }
}
