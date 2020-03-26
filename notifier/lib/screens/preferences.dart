import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/authentication/authentication.dart';
import 'package:notifier/data/data.dart';
import 'package:notifier/services/databse.dart';

class Preferences extends StatefulWidget {
  Preferences(this.auth,this.logoutCallback(),);
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  // final List<bool> select;

  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
   List<String> prefSel = List();
  List<bool> select = List();
  bool _loading = true;
  // List<TableRow> tableRow = [];
  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
  @override
  void initState() {
    super.initState();
    // for (var i in (selectionData[0].name)) {
    //   select.add(false);
    // }
    print('reading');
    // readContent('users').then((var value){
    //   print('reading users');
     
    // });
    // print(select);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Preferences'),
        // actions: <Widget>[
        //   new FlatButton(
        //       child: new Text('Logout',
        //           style: new TextStyle(fontSize: 17.0, color: Colors.white)),
        //       onPressed: signOut)
        // ],
      ),
      body: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.8,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectionData[0].name.length,

                  itemBuilder: (BuildContext context, int index) {
                  //  for (var i in (selectionData[0].name)){
                  //    select.add(false);
                  //  }
                  // select.insert(index, false);
                   return  Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.7,
                            // decoration: Decoration(),
                            padding: EdgeInsets.only(left:30.0),
                            child: 
                              Text(selectionData[0].name[index]),
                            
                          ),
                          Container(
                             width: MediaQuery.of(context).size.width*0.3,
                            child: 
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Switch(
                            value: selectionData[0].isSelected[index],
                            onChanged: (value) {
                                setState(() {
                                  selectionData[0].isSelected[index] = value;
                                  print(value.toString() + ':'  + selectionData[0].name[index]);

                                  // print(select[index]);
                                  // print(select[index]);
                                  // if(select[index]){
                                  //   prefSel.add(selectionData[0].name[index]);
                                  // }
                                  // else{
                                  //   prefSel.remove(selectionData[0].name[index]);
                                  // }
                                  // isSwitched = value;
                                  // print(prefSel);
                                });
                            },
                            activeTrackColor: Colors.lightGreenAccent,
                            activeColor: Colors.green,
                          ),
                              ),
                            
                          )
                        ],
                      ),
                    );
                  }),),
                  RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.blue,
                      onPressed: (){
                    setState(() {
                      prefSel.clear();
                      for(var i = 0; i < selectionData[0].isSelected.length ;i++){
                        
                        if(selectionData[0].isSelected[i] == true){
                          // if(!prefSel.contains(selectionData[0].name[i])){
                            prefSel.add(selectionData[0].name[i]);
                          // }
                        }
                        // else{
                        //   if(prefSel. prefSel.contains(selectionData[0].name[i])){
                        //     prefSel.remove(selectionData[0].name[i]);
                        //   }
                        // }
                      }
                      onUpdate(prefSel);
                    });
                  } , 
                  child: Text('Update',style: TextStyle(
                          color:Colors.white
                        ),),)
          ],
          
        )
    );
  }
}

var unsubscribe = [];
var subscribe = [];
void onUpdate(List<String> prefsel){
  var val;
  var uid;
  var same = false;
  Fluttertoast.showToast(msg: 'Saving Preferences');
  readContent('users').then((var value){
    var prefs = value['prefs'];
    uid = value['uid'];
    print(uid);
    // print(prefs.length);
    
    // print(same);
    // for(var i in prefsel){
      
    //   if(!prefs.contains(i) ){
    //     same = false;
    //     break;
    //   }
    //   same = true;
    // }
    // if( prefs.length == 0 && prefsel.length == 0){
    //     same = true;
    //     // break;
    //   }
    // print(same);
    // if(same){
    //   print('\'same\'');
    //   val = null;
    //   return;
    // }
    val = value;
    subscribe.clear();
    unsubscribe.clear();

    print(prefs.toString() + ' prefs');
    for(var i in prefsel){
      if(!prefs.contains(i)){
        subscribe.add(i);
        // unsubscribe.remove(i);
      }
    }
    print(prefsel.toString() + ' prefsel');
    for(var i in prefs){
      if(!prefsel.contains(i)){
        print(i);
        unsubscribe.add(i);
        // subscribe.remove(i);
      }
    }
  
    // value['prefs'] = prefsel;
    // print(value['prefs'].toString() + 'after change');
    
    
    
    // addpreferences(prefsel);
  }).whenComplete(()async{
    print(subscribe.toString() + 'subscribe');
    

    
    print(unsubscribe.toString() + 'unsubscribe');
    if(subscribe.length == 0 && unsubscribe.length == 0){
      same = true;
      Fluttertoast.showToast(msg: 'Done!!!');
      return;
    }
    val['prefs'] = prefsel;
    print(val);
      print(same);
    subscribeUnsubsTopic(subscribe,unsubscribe);
    // deleteContent('users').whenComplete((){
      if(val != null){
        var v = await writeContent('users',json.encode(val));
      updateInFireBase(uid,prefsel).whenComplete((){
        Fluttertoast.showToast(msg: 'Done!!!');
      });
      
      if(v){
        action();
      }
      }
    });
    // });
  
  
}
checkSpace(String name){
  return name.replaceAll(' ', '_');
}
final FirebaseMessaging _fcm = FirebaseMessaging();
void subscribeUnsubsTopic(var subscribe,var unsubscribe){
    for(var i in unsubscribe){
      _fcm.unsubscribeFromTopic(checkSpace(i).toString());
    }
    for(var i in subscribe){
      _fcm.subscribeToTopic(checkSpace(i).toString());
    }
  }

dynamic action(){
  readContent('users').then((var value){
    return print(value['prefs'].toString() + 'pref');
  });
  return print('nothing');
}