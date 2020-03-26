import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:notifier/data/data.dart';
import 'package:notifier/main.dart';
import 'package:notifier/shared/customDrawer.dart';
import 'package:notifier/shared/function.dart';
import 'package:notifier/services/database.dart';

class Preferences extends StatefulWidget {
  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  List<String> prefSel = [];
  List<bool> select = [];
  List<TableRow> tableRow = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var i in (selectionData[0].name)) {
      select.add(false);
    }
    readContent('users').then((var value){
      var r = value['prefs'];
      for(var i in r){
        var index = selectionData[0].name.indexOf(i);
        select.insert(index, true);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
  
    
    // };
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: darkThemeEnabled ? Colors.white : Colors.black,
          ),
          title: Text(
            'Preferences',
            style: TextStyle(
                color: darkThemeEnabled ? Colors.white : Colors.black),
          ),
          backgroundColor: darkThemeEnabled ? Colors.black : Colors.white,
          elevation: 0.0,
          // actions: <Widget>[
          //   // FlatButton.icon(
          //   //   icon: Icon(
          //   //     Icons.person,
          //   //     color: Colors.black,
          //   //   ),
          //   //   label: Text(
          //   //     'Logout',
          //   //     style: TextStyle(
          //   //       color: Colors.black,
          //   //     ),
          //   //   ),
          //   //   onPressed: () async {
          //   //     await _auth.signOut();
          //   //   },
          //   // )
          // ],
        ),
        // drawer: CustomDrawer(),
        body: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.8,
                child:  ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectionData[0].name.length,

                  itemBuilder: (BuildContext context, int index) {
                   for (var i in (selectionData[0].name)){
                     select.add(false);
                   }
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
                            value: select[index],
                            onChanged: (value) {
                                setState(() {
                                  select[index] = value;
                                  // print(select[index]);
                                  // print(select[index]);
                                  if(select[index]){
                                    prefSel.add(selectionData[0].name[index]);
                                  }
                                  else{
                                    prefSel.remove(selectionData[0].name[index]);
                                  }
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
                  RaisedButton(onPressed: (){
                    setState(() {
                      onUpdate(prefSel);
                    });
                  } , 
                  child: Text('Update'),)
          ],
          
        ));
  }
}
var unsubscribe = [];
var subscribe = [];
void onUpdate(List<String> prefsel){
  var val;
  var uid;
  readContent('users').then((var value){
    var prefs = value['prefs'];
    uid = value['uid'];
    // print(uid);
    if(prefs == prefsel){
      return;
    }
    // subscribe.clear();
    // unsubscribe.clear();

    print(prefs.toString() + ' prefs');
    for(var i in prefsel){
      if(!prefs.contains(i)){
        subscribe.add(i);
        unsubscribe.remove(i);
      }
    }
    for(var i in prefs){
      if(!prefsel.contains(i)){
        unsubscribe.add(i);
        subscribe.remove(i);
      }
    }
    value['prefs'] = prefsel;
    val = value;
    print(subscribe);
    print(unsubscribe);
    
    // addpreferences(prefsel);
  }).whenComplete((){
    deleteContent('users').whenComplete((){
      writeContent('users',val);
      updateInFireBase(uid,prefsel);
    });});
  action();
  
}
dynamic action(){
  readContent('users').then((var value){
    return print(value['prefs'].toString() + 'pref');
  });
  return print('nothing');
}
// ListView.builder(
//               itemCount: selectionData[0].name.length,

//               itemBuilder: (BuildContext context, int index) {
//                for (var i in (selectionData[0].name)){
//                  select.add(false);
//                }
//               // select.insert(index, false);
//                return  Container(
//                   child: Table(
//                     children: <TableRow>[
//                       TableRow(
//                         // decoration: Decoration(),
//                         children: [
//                           Text(selectionData[0].name[index]),
//                         ]
//                       ),
//                       TableRow(
//                         children: [
//                           Switch(
//                         value: select[index],
//                         onChanged: (value) {
//                           setState(() {
//                             select[index] = value;
//                             print(select[index]);
//                             if(select[index]){
//                               prefSel.add(selectionData[0].name[index]);
//                             }
//                             else{
//                               prefSel.remove(selectionData[0].name[index]);
//                             }
//                             // isSwitched = value;
//                             print(prefSel);
//                           });
//                         },
//                         activeTrackColor: Colors.lightGreenAccent,
//                         activeColor: Colors.green,
//                       ),
//                         ]
//                       )
//                     ],
//                   ),
//                 );
//               }),
// class PreferenceTile extends StatelessWidget {
//   final bool isSwitched;
//   final String data;
//   PreferenceTile(this.data, this.isSwitched);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Row(
//         children: <Widget>[
//           Text(data),
//           Switch(
//             value: isSwitched,
//             onChanged: (value) {
//               setState(() {
//                 isSwitched = value;
//                 print(isSwitched);
//               });
//             },
//             activeTrackColor: Colors.lightGreenAccent,
//             activeColor: Colors.green,
//           ),
//         ],
//       ),
//     );
//   }
// }
