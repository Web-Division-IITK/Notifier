import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:hive/hive.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/model/hive_allCouncilData.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/model/people_hive.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';

class MakeCoordi extends StatefulWidget {
  final List<dynamic> ids;
  final BaseAuth auth;
  final String id;
  final Councils allCouncilData;
  final VoidCallback logoutCallback;
  final String userId;
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
  final _formKey = GlobalKey<FormState>();
  String _id = "";
  bool loading = false;
  Repository repo = Repository(allCouncilData);
  List<String> _council = [];
  List<String> _entity = [];
  Box peopleBox ;
  Box usersBox ;
  
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()!=null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  initPeopleBox() async{
    peopleBox  = await HiveDatabaseUser(databaseName: 'people').hiveBox;
    usersBox  = await HiveDatabaseUser().hiveBox;
    setState(() {
    });
  }
  buildList() {
    if (widget.allCouncilData.level3.contains(widget.id)) {
      print(null);
      _council = List.from(_council)..addAll(repo.getCouncil());
      // _council = List.from(_council)..addAll(repo.getpresis());
    } else {
      widget.allCouncilData.subCouncil.forEach((council,f) {
        if (f.level2.contains(widget.id)) {
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
    });
    if (validateAndSave()) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    
      try {
        submit(_id,_selcouncil,_selectedEntity).then((var i) async {
          if (i == 200) {
            if(id == _id){
              if(peopleBox.isEmpty){
                peopleBox.add(PeopleModel(councils: {_selcouncil: [_selectedEntity]},id: _id,posts: {}));
              }else{
                Map<String,List<String>> data = peopleBox.toMap()[0].councils;
                data.update(_selcouncil, (v){
                  if(!v.contains(_selectedEntity)){
                    v.add(_selectedEntity);
                  }
                  return v;
                },ifAbsent: ()=> [_selectedEntity]);
                peopleBox.toMap()[0].councils = data;
                // peopleBox.putAt(0, peopleBox.toMap()[0]);
              }
              peopleBox.putAt(0, peopleBox.toMap()[0]);
              usersBox.toMap()[0].admin = true;
              usersBox.putAt(0,usersBox.toMap()[0] );
            }
            setState(() {
              admin = true;
              loading = false;
            });
            showSuccessToast('Done!!!');
          } else {
            setState(() {
              loading = false;
            });
            showErrorToast('Cannot process request at this time, please try again later !!');
          }
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          loading = false;
          _errorMessage = e.message;
          showErrorToast( _errorMessage);
          _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  void initState() {
    buildList();
    initPeopleBox();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: loading,
      child: Scaffold(
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
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      paste: true,
                      selectAll: true,
                    ),
                    maxLines: 1,
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
                    icon: Icon(Entypo.chevron_down),
                    isExpanded: false,
                    decoration: InputDecoration(
                      labelText: 'Council',
                      hintText: 'Choose Council...',
                      isDense: true
                    ),
                    isDense: true,
                    value: _selcouncil,
                    onChanged: (newValue) => _onSelectedCouncil(convertFromCouncilName(newValue)),
                    items: _council.map((location) {
                      print(_council.length);
                      return DropdownMenuItem(
                        child: new Text(convertToCouncilName(location)),
                        value: location,
                      );
                    }).toList(),
                    validator: (String val) =>
                      val == null ? 
                      'Council can\'t be null' : 
                      (
                        // val.toLowerCase().contains(widget.id.split('secy')[0]) ?
                        // 'You can\'t make coordinator for a entity outside your domain'
                        // : 
                        null),
                    onSaved: (val) => _selcouncil = convertFromCouncilName(val),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 0.0),
                  child: DropdownButtonFormField(
                    icon: Icon(Entypo.chevron_down),
                    value: _selectedEntity,
                    onChanged: (newValue) => _onSelectedEntity(newValue),
                    items: _entity.map((location) {
                      return DropdownMenuItem(
                        child: new Text(location),
                        value: location,
                      );
                    }).toList(),
                    isExpanded: false,
                    decoration: InputDecoration(
                      labelText: 'Entity',
                      hintText: 'Choose Entity...',
                      isDense: true
                    ),
                    isDense: true,
                    validator: (String val) =>
                      val == null ? 'Entity can\'t be null' : null,
                    onSaved: (val) => _selectedEntity = val,
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  width: 120.0,
                  child: RaisedButton(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                    child: Text(
                      'Save',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      if(id == _id &&!widget.allCouncilData.coordOfCouncil.contains(_selcouncil)){
                        widget.allCouncilData.coordOfCouncil.add(_selcouncil);
                      }
                      if(id == _id && allCouncilData.subCouncil.containsKey(_selcouncil)&& !allCouncilData.subCouncil[_selcouncil].coordiOfInCouncil.contains(_selectedEntity)){
                        allCouncilData.subCouncil[_selcouncil].coordiOfInCouncil.add(_selectedEntity);
                      }
                      else if(id == _id &&allCouncilData.presiAndChairPerson.containsKey(_selcouncil)&& !allCouncilData.presiAndChairPerson[_selcouncil].coordiOfInCouncil.contains(_selectedEntity)){
                        allCouncilData.presiAndChairPerson[_selcouncil].coordiOfInCouncil.add(_selectedEntity);
                      }
                      // if(!allCouncilData.subCouncil[widget.allCouncilData.globalCouncils.indexOf(_selcouncil)].coordiOfInCouncil.contains(_selectedEntity)){
                      //   allCouncilData.subCouncil[widget.allCouncilData.globalCouncils.indexOf(_selcouncil)].coordiOfInCouncil.add(_selectedEntity);
                      // }
                      // print( allCouncilData.subCouncil[widget.allCouncilData.globalCouncils.indexOf(_selcouncil)].coordiOfInCouncil);
                      // if(!selectedOptions[_selcouncil].contains(_selectedEntity)  ){
                      //   selectedOptions[_selcouncil] =[_selectedEntity];
                      // }
                      print(allCouncilData.coordOfCouncil);
                      // print(selectedOptions);
                      if (validateAndSave()) {
                        setState(() {
                          loading = true;
                          showInfoToast( 'Making Coordinator !!!');
                          validateAndSubmit();
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSelectedCouncil(String value) {
    if(_selcouncil!=value){
      setState(() {
      _selcouncil = value;
      _selectedEntity = null;
      if(_entity.length!=0){
        _entity.clear();
      }
      if (allCouncilData.level3.contains(widget.id)) {
        _entity = List.from(_entity)..addAll(repo.getEntityBCouncil(value));
        // _entity = List.from(_entity)..addAll(repo.getEntityofChairByCouncil(value));
      } else {
        _entity = List.from(_entity)..addAll(repo.getEntityBCouncil(value));
      }
    });
    }
  }

  void _onSelectedEntity(String value) {
    setState(() {
      _selectedEntity = value;
    });
  }
}
