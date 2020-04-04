import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/databse.dart';
import 'package:notifier/services/function.dart';

class MakeCoordi extends StatefulWidget {
  final List<dynamic> ids;
  final BaseAuth auth;
  final String id;
  final Councils allCouncilData;
  final VoidCallback logoutCallback;
  final String userId;
  // final List<dynamic> allCouncilsData;
  MakeCoordi(
    this.ids,
    this.allCouncilData,
    this.id,
    this.auth,
    this.logoutCallback,
    this.userId,
  );
  @override
  _MakeCoordiState createState() => _MakeCoordiState();
}

class _MakeCoordiState extends State<MakeCoordi> {
  String _selectedEntity;
  String _selcouncil;
  // bool _isLevel3 = false;
  // String _selectedId;
  final _formKey = GlobalKey<FormState>();
  String _id = "";
  Map<String, dynamic> selectedOptions = {
    "snt": [],
    "anc": [],
    "gnc": [],
    "ss": [],
    "mnc": [],
  };
  Repository repo = Repository(allCouncilData);
  List<String> _council = [];
  List<String> _entity = [];
  // TextFieldController
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()!=null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  buildList() {
    if (widget.allCouncilData.level3.contains(widget.id)) {
      // _isLevel3 =true;
      print(null);
      // locations += widget.allCouncilData.subCouncil.iterator.current.entity + widget.allCouncilData.subCouncil
      // for(var i in widget.allCouncilData.subCouncil){
      //   locations += i.entity + i.misc;
      // }
      _council = List.from(_council)..addAll(repo.getCouncil());
    } else {
      widget.allCouncilData.subCouncil.forEach((f) {
        if ((f.council + 'secy') == widget.id) {
          print('something' + f.council);
          _council.add(f.council);
        }
      });
    }
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
        submit(
          _id,
          _selcouncil,
          selectedOptions,
        ).then((var i) async {
          if (i == 200) {
            await readContent('users').then((var value) async {
              if (value != null) {
                List<dynamic> sub;
                value['admin'] = true;
                selectedOptions.keys.forEach((key) {
                  value.update(key, (v) {
                    return selectedOptions[key];
                  }, ifAbsent: () => selectedOptions[key]);
                });
                // selectedOptions.forEach((f){
                //
                // });
                await writeContent('users', json.encode(value))
                    .then((bool status) {
                  if (status) {
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
  void initState() {
    buildList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Make Coordinators',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
                child: new TextFormField(
                  maxLines: 1,
                  // keyboardType: TextInputType.emailAddress,
                  autofocus: false,
                  decoration: new InputDecoration(
                    hintText: 'CC Id',
                  ),
                  validator: (value) => value.isEmpty
                      ? 'CC ID can\'t be empty'
                      : (value.contains('@') ? 'Invalid CC Id' : null),
                  onSaved: (value) => _id = value.trim(),
                ),
              ),
              // SizedBox(height:40.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 0.0),
                child: DropdownButtonFormField(
                  isExpanded: true,
                  // style: ,
                  hint: Text('Choose Council'), // Not necessary for Option 1
                  value: _selcouncil,
                  onChanged: (newValue) => _onSelectedCouncil(convertFromCouncilName(newValue)),
                  items: _council.map((location) {
                    return DropdownMenuItem(
                      child: new Text(convertToCouncilName(location)),
                      value: location,
                    );
                  }).toList(),
                  validator: (String val) =>
                      val == null ? 'Council can\'t be null' : null,
                  onSaved: (val) => _selcouncil = convertFromCouncilName(val),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 0.0),
                child: DropdownButtonFormField(
                  hint: Text('Choose Entity'), // Not necessary for Option 1
                  value: _selectedEntity,
                  onChanged: (newValue) => _onSelectedEntity(newValue),
                  items: _entity.map((location) {
                    return DropdownMenuItem(
                      child: new Text(location),
                      value: location,
                    );
                  }).toList(),
                  validator: (String val) =>
                      val == null ? 'Entity can\'t be null' : null,
                  onSaved: (val) => _selectedEntity = val,
                ),
              ),

              SizedBox(height: 30.0),
              Container(
                width: 120.0,
                // padding: const EdgeInsets.fromLTRB(60.0, 0.0, 60.0, 0.0),
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  // color: Colors.blue,
                  child: Text(
                    'Save',
                    style: TextStyle(
                        // fontFamily: 'Comfortaa',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white),
                  ),
                  onPressed: () {
                    // if (validateAndSave()) {
                    //   // print(_selectedEntity);

                    // }
                    // var index = widget
                    if(!widget.allCouncilData.coordOfCouncil.contains(_selcouncil)){
                      widget.allCouncilData.coordOfCouncil.add(_selcouncil);
                    }
                    // widget.allCouncilData.subCouncil[index].coordiOfInCouncil.add(_selectedLocation);
                    // allCouncilData.subCouncil[widget.allCouncilData.globalCouncils.indexOf(_selcouncil)].coordiOfInCouncil.clear();
                    if(!allCouncilData.subCouncil[widget.allCouncilData.globalCouncils.indexOf(_selcouncil)].coordiOfInCouncil.contains(_selectedEntity)){
                      allCouncilData.subCouncil[widget.allCouncilData.globalCouncils.indexOf(_selcouncil)].coordiOfInCouncil.add(_selectedEntity);
                    }
                    var ret = true;
                    print( allCouncilData.subCouncil[widget.allCouncilData.globalCouncils.indexOf(_selcouncil)].coordiOfInCouncil);
                    // widget.allCouncilData.subCouncil[]
                    // selectedOptions[widget.allCouncilData.subCouncil[index].council] += [_selectedLocation];
                    if(!selectedOptions[_selcouncil].contains(_selectedEntity)  ){
                      selectedOptions[_selcouncil] +=[_selectedEntity];
                      ret = false;
                    }
                    print(allCouncilData.coordOfCouncil);
                    print(selectedOptions);
                    // selectedOptions.add(_selectedLocation);
                    // print(validateAndSave());
                    if (validateAndSave()) {
                      setState(() {
                        // print(_selectedLocation);
                        Fluttertoast.showToast(msg: 'Making Coordinators');
                        if(ret){
                          print('returns');
                           Fluttertoast.showToast(msg: 'Done!!');
                           return;
                        }
                        validateAndSubmit();

                        // if(response == )
                      });
                    }
                  },
                ),
              )
            ],
          ),

          // ),
        ),
      ),
    );
  }

  void _onSelectedCouncil(String value) {
    if(_selcouncil!=value){
      setState(() {
      // _selectedEntity = "Choose ..";
      // _entity = ["Choose .."];
      _selcouncil = value;
      _selectedEntity = null;
      if(_entity.length!=0){
        _entity.clear();
      }
      _entity = List.from(_entity)..addAll(repo.getEntityBCouncil(value));
    });
    }
  }

  void _onSelectedEntity(String value) {
    setState(() {
      _selectedEntity = value;
    });
  }
}
