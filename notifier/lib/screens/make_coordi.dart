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
         submit(_id, selectedOptions).then((var i) {
                              if (i == 200) {
                                Fluttertoast.showToast(msg: 'Done!!');
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
    return Scaffold(
        appBar: new AppBar(
          title: new Text(
            'Make Coordinators',
          ),
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
        body: Center(
          child: Container(
            height: 500.0,
            width: 300.0,
            child: Form(
              key: _formKey,
              child: Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    // padding: EdgeInsets.only(top: 80.0),
                    alignment: Alignment.bottomCenter,
                    width: 300.0,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      itemCount: selectionData.length,
                      itemBuilder: (BuildContext context, int index) {
                        // List<String> options;
                        // for( var i =0 ;i< selectionData[index].name.length;i++){
                        //   options.add(selectionData[index].name[i]);
                        // }
                        var locations = selectionData[index].name;
                        // var ids = ids;
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
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
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    43.0, 100.0, 40.0, 0.0),
                                child: new TextFormField(
                                  maxLines: 1,
                                  // keyboardType: TextInputType.emailAddress,
                                  autofocus: false,
                                  decoration: new InputDecoration(
                                      hintText: 'UserId',
                                      // icon: new Icon(
                                      //   Icons.mail,
                                      //   color: Colors.grey,
                                      // )
                                      ),
                                  validator: (value) => value.isEmpty
                                      ? 'UserID can\'t be empty'
                                      : (value.contains('@')
                                          ? 'Invalid UserName'
                                          : null),
                                  onSaved: (value) => _id = value.trim(),
                                ),
                              ),
                              SizedBox(height:40.0),
                              Text(selectionData[index].title),
                              Center(
                                child: DropdownButton(
                                  hint: Text(
                                      'Choose..'), // Not necessary for Option 1
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
                              // SizedBox(height: 40.0)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(100.0, 0.0, 100.0, 0.0),
                    child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.blue,
                      child: Text('Save',
                        style: TextStyle(
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
          ),
        ));
  }
}
