
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/database/student_search.dart';
import 'package:notifier/model/hive_models/hive_model.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/map/map.dart';
import 'package:notifier/services/beautify_body.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/widget/showtoast.dart';
import 'package:qr_flutter/qr_flutter.dart';




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
  String rollno;
  Box userBox;
  Box _stuSearch;
  bool showMoreInfo = false;
  SearchModel searchModel = SearchModel();
  Future<bool> preferen() async {
    // _stuSearch = await HiveDatabaseUser(databaseName: 'ss').hiveBox;
    userBox = await HiveDatabaseUser().hiveBox;
    if(userBox.isNotEmpty){
      List<SearchModel> list= await StuSearchDatabase().getAllPostswithQuery(QueryDatabase(['username'], [id]));
      // userBox.toMap()[0];
      // List<SearchModel> list = _stuSearch.toMap().values.toList().cast<SearchModel>();
      print(list.length);
      List<SearchModel> val = list.where((test)=>test.username == id).toList();
      print(val);
      _jsonData = val[0].toMap();
        setState(() {
          searchModel = val[0];
          // val[0].name = name;
          name = val[0].name;
          print(val[0].toMap());
          // name = _jsonData['name'];
          // val[0].rollno = rollno;
          rollno = val[0].rollno;
          print(val[0].rollno);
          // rollno = _jsonData['rollno'];
          // print(_jsonData);
          // print(_jsonData['prefs']);
        });
        return true;
    }    return false;
  }

  Future<bool> writeposts() async {
    userBox.toMap()[0].name = _jsonData['name'];
    userBox.toMap()[0].rollno = _jsonData['rollno'];
    return await userBox.putAt(0, userBox.toMap()[0]).then((v){
      return true;
    }).catchError((onError){
      print(onError);
      return false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load = true;
    preferen().then((bool v) {
      if (v != null) {
        setState(() {
          _load = false;
        });
      } else{

      }
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
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.settings,
                color: Colors.white
              ),
            ),
            Container(
              height: 350.0,
              width: double.infinity,
              // decoration: BoxDecoration(
              //   border: Border.all()
              // ),
            ),
            Container(
              height: 200.0,
              width: double.infinity,
              color: 
              Theme.of(context).colorScheme.brightness == Brightness.dark?
              Colors.blueGrey[800]
              : Colors.blueGrey,
              child: Align(
              alignment: Alignment.topRight,
              child:IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white
                ),
                onPressed: (){
                  // DynamicTheme.of(context).setBrightness(
                  //               Theme.of(context).brightness == Brightness.light
                  //                 ? Brightness.dark
                  //                 : Brightness.light);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> MapingMap()
                    // MapSample()
                  ));
                },
              ),
            ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                iconSize: 30,
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
                  constraints: BoxConstraints(
                    minHeight: 200
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    // border: Border.all(color: Colors.white),
                    color:Theme.of(context).brightness == Brightness.light
                      ?Colors.white:
                      Colors.black),
                // ),
                child: Container(
                  margin: EdgeInsets.only(top: 70),
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          name == null || name == '' ? widget.id : _jsonData['name'],
                          style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0),
                        ),
                        // name == null || name == '' ?
                        // Container()
                        // :Container(
                        //   width: 140,
                        //   alignment: Alignment.center,
                        //   decoration: BoxDecoration(
                        //     border: Border.all()
                        //   ),
                        //   child:  RichText(
                        //       text: TextSpan(
                        //         text:'Request change in name/ rollno',
                        //       // minFontSize: 2,
                        //       style:TextStyle(
                        //         color: Colors.blue,
                        //         fontSize: 10,
                        //         decoration: TextDecoration.underline
                        //       ),
                        //       recognizer: TapGestureRecognizer()
                        //         ..onTap = (){
                        //            launchMail('webdivisioniitk@gmail.com');
                        //         },
                              
                        //       )
                        //     )),
                        // )
                      ],
                    ),
                  // ]
                  // )
                  // )
              // )
                    // ),
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
                        : Column(
                          children: <Widget>[
                            Text(
                                _jsonData['rollno'],
                                style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.0,
                                    ),
                              ),
                            Container(
                              margin: EdgeInsets.only(top:10),
                              width: 200,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: Icon(Icons.arrow_drop_down_circle), 
                                onPressed: (){
                                  setState(() {
                                    showMoreInfo = !showMoreInfo;
                                  });
                                }
                              ),
                            
                          // decoration: BoxDecoration(
                          //   border: Border.all()
                          // ),
                          // child:  RichText(
                          //     text: TextSpan(
                          //       text:'Request change in name/rollno',
                          //     // minFontSize: 2,
                          //     style:TextStyle(
                          //       color: Colors.blue,
                          //       fontSize: 10,
                          //       decoration: TextDecoration.underline
                          //     ),
                          //     recognizer: TapGestureRecognizer()
                          //       ..onTap = (){
                          //          launchMail('webdivisioniitk@gmail.com');
                          //       },
                              
                          //     )
                          //   )
                            ),
                            showMoreInfo? Container(
                              margin: EdgeInsets.only(top:10),
                              child: Column(
                                children: <Widget>[
                                 Text(
                                  '${searchModel.program}, ${searchModel.dept}',
                                  style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                  Text(
                                    '${searchModel.room}, ${hallName(searchModel.hall)}',
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                  Text(
                                    '${searchModel.hometown}',
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ],
                              ),
                            ):Container()
                          ],
                        ),
                  ]
                  ),
                )
                )
              ),
            ),
            Positioned(
                top: 75.0,
                left: (MediaQuery.of(context).size.width / 2 - 50.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).accentColor,
                  radius: 50.0,
                  child: Text(
                      name == null || name == ''
                          ? widget.id[0].toUpperCase()
                          : name[0].toUpperCase(),
                      style: TextStyle(fontSize: 40.0,
                        color: Colors.white
                      )),
                )),
            // Positioned(
            //   top: 190.0,
            //   left: (MediaQuery.of(context).size.width / 2) - 135.0,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       Column(
            //         children: <Widget>[
            //           Text(
            //             name == null || name == '' ? widget.id : _jsonData['name'],
            //             style: TextStyle(
            //                 fontFamily: 'Comfortaa',
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 17.0),
            //           ),
            //           // name == null || name == '' ?
            //           // Container()
            //           // :Container(
            //           //   width: 140,
            //           //   alignment: Alignment.center,
            //           //   decoration: BoxDecoration(
            //           //     border: Border.all()
            //           //   ),
            //           //   child:  RichText(
            //           //       text: TextSpan(
            //           //         text:'Request change in name/ rollno',
            //           //       // minFontSize: 2,
            //           //       style:TextStyle(
            //           //         color: Colors.blue,
            //           //         fontSize: 10,
            //           //         decoration: TextDecoration.underline
            //           //       ),
            //           //       recognizer: TapGestureRecognizer()
            //           //         ..onTap = (){
            //           //            launchMail('webdivisioniitk@gmail.com');
            //           //         },
                            
            //           //       )
            //           //     )),
            //           // )
            //         ],
                  
            //       ),
            //       SizedBox(height: 7.0),
            //       name == null || name == ''
            //           ? Text('')
            //           : Text(
            //               widget.id,
            //               style: TextStyle(
            //                   fontFamily: 'Comfortaa',
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 17.0,
            //                   color: Colors.grey),
            //             ),
            //      rollno == null || rollno == ''
            //           ?SizedBox():SizedBox(height: 10.0,),
            //             rollno == null || rollno == ''
            //           ? Text('')
            //           : Column(
            //             children: <Widget>[
            //               Text(
            //                   _jsonData['rollno'],
            //                   style: TextStyle(
            //                       fontFamily: 'Comfortaa',
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 17.0,
            //                       ),
            //                 ),
            //               Container(
            //                 margin: EdgeInsets.only(top:10),
            //                 width: 200,
            //                 alignment: Alignment.center,
            //                 child: IconButton(
            //                   icon: Icon(Icons.arrow_drop_down_circle), 
            //                   onPressed: (){
            //                     setState(() {
            //                       showMoreInfo = !showMoreInfo;
            //                     });
            //                   }
            //                 ),
                          
            //             // decoration: BoxDecoration(
            //             //   border: Border.all()
            //             // ),
            //             // child:  RichText(
            //             //     text: TextSpan(
            //             //       text:'Request change in name/rollno',
            //             //     // minFontSize: 2,
            //             //     style:TextStyle(
            //             //       color: Colors.blue,
            //             //       fontSize: 10,
            //             //       decoration: TextDecoration.underline
            //             //     ),
            //             //     recognizer: TapGestureRecognizer()
            //             //       ..onTap = (){
            //             //          launchMail('webdivisioniitk@gmail.com');
            //             //       },
                            
            //             //     )
            //             //   )
            //               ),
            //               Container(
            //                 margin: EdgeInsets.only(top:10),
            //                 child: Column(
            //                   children: <Widget>[
            //                    Text(
            //                     '${searchModel.program}, ${searchModel.dept}',
            //                     style: TextStyle(
            //                         fontFamily: 'Comfortaa',
            //                         fontWeight: FontWeight.bold,
            //                         fontSize: 17.0,
            //                       ),
            //                     ),
            //                     Text(
            //                       '${searchModel.room}, ${hallName(searchModel.hall)}',
            //                       style: TextStyle(
            //                         fontFamily: 'Comfortaa',
            //                         fontWeight: FontWeight.bold,
            //                         fontSize: 17.0,
            //                       ),
            //                     ),
            //                     Text(
            //                       '${searchModel.hometown}',
            //                       style: TextStyle(
            //                         fontFamily: 'Comfortaa',
            //                         fontWeight: FontWeight.bold,
            //                         fontSize: 17.0,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               )
            //             ],
            //           ),
            //       SizedBox(height: 10.0),
            //       Row(
            //         children: <Widget>[
            //           Container(
            //             width: 130.0,
            //             child: name == null || name == ''?FlatButton(
            //               shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(16.0),
            //               ),
            //               color: Color(0xFFFA624F),
            //               onPressed: () {
            //                 _updateDialog('name');
            //               },
            //               child: Text('Add Name',                                
            //                 style: TextStyle(
            //                     fontFamily: 'Comfortaa',
            //                     fontWeight: FontWeight.bold,
            //                     fontSize: 15.0,
            //                     color: Colors.white),
            //               ),
            //             ):
            //             ((rollno == null || rollno == '')?
            //             RaisedButton(
            //               shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(16.0),
            //               ),
            //               color: Color(0xFFFA624F),
            //               onPressed:  null,
            //               child: Text('Add Name',                                
            //                 style: TextStyle(
            //                     fontFamily: 'Comfortaa',
            //                     fontWeight: FontWeight.bold,
            //                     fontSize: 15.0,
            //                     color: Colors.white),
            //               ),
            //             ):
            //             Container())
            //             ,
            //           ),
            //           SizedBox(width: 5.0),
            //           Container(
            //             width: 130.0,
            //             child: rollno == null || rollno == '' 
            //                 ? FlatButton(
            //                     shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.circular(16.0),
            //                     ),
            //                     color: Colors.grey,
            //                     onPressed: () {
            //                       _updateDialog('rollno');
            //                     },
            //                     child: Text('Add Rollno',
            //                       style: TextStyle(
            //                           fontFamily: 'Comfortaa',
            //                           fontWeight: FontWeight.bold,
            //                           fontSize: 15.0,
            //                           color: Colors.white),
            //                     ),
            //                   )
            //                 : Container()
            //           )
            //         ],
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
        SizedBox(height: 5.0),
        Center(
          child: Text('POR\'s',
            style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10.0),
        // Wrap(
        //   alignment: WrapAlignment.center,
        //   spacing: 8,
        //   children: <Widget>[
            for (var council in allCouncilData.coordOfCouncil) 
              for(var i in allCouncilData.subCouncil[council].coordiOfInCouncil)
                Chip(label: Text(i)),
        //   ],
        // ),
        SizedBox(height: 15.0),
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
        SizedBox(height: 25.0),
        
      ],
    ));
  }

  _updateDialog(String type) {
    return showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) {
          final _formKey = GlobalKey<FormState>();
          String _name;
          // return Container(
          return AlertDialog(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
                title: Center(child: Text('Add ' + type[0].toUpperCase() + type.substring(1))),
            content: Form(
              key: _formKey,
              child: Container(
                // height: 300.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Text('Note: You will not be able to change your $type again',

                      textAlign: TextAlign.center,
                      style:TextStyle(
                        fontSize: 12.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                      )
                    )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      child: Material(
                        color: Colors.transparent,
                        child: TextFormField(
                          toolbarOptions: ToolbarOptions(
                                      copy: true,
                                      paste: true,
                                      selectAll: true,
                                    ),
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
                      padding: EdgeInsets.only( top: 25.0,left: 0.0),
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
                                  Navigator.of(context).pop();
                                },
                                child: Text('Dismiss')),
                            Padding(
                              padding: const EdgeInsets.only(right: 0.0),
                              child: RaisedButton(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  color: Colors.blue,
                                  onPressed: () async{
                                    // Fluttertoast.showToast(msg: 'Creating post');
                                    // Fluttertoast.cancel();
                                    // print(createTagsToList(tags[0]));
                                    // tags = _tag.split(';');
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      
                                      if (type == 'name') {
                                        setState(() {
                                          _jsonData['name'] = _name;
                                          name = _name;
                                         });
                                        updateUserDataInFirebase(widget.uid, type,name).then((var value){
                                          if(value){
                                            showSuccessToast('Updated Name Successfully!!');
                                            // Fluttertoast.showToast(msg: 'Updated Name!!');
                                          }else{
                                            showErrorToast('Failed!!!');
                                            // Fluttertoast.showToast(msg: 'Failed!!');
                                          }
                                        });
                                      } else {
                                        setState(() {
                                          _jsonData['rollno'] = _name;
                                          rollno = _name;
                                         });
                                        updateUserDataInFirebase(widget.uid,type, rollno).then((var value){
                                         if(value){
                                           showSuccessToast(
                                             'Updated Rolno Successfully'
                                            //  Container(
                                            //   child: Row(
                                            //     children: <Widget>[
                                            //       Icon()
                                            //     ],
                                            //   ),
                                            //  )
                                           );
                                          //  showToast(
                                          //    'Update Rollno Successfully!!!',
                                          //    borderRadius: BorderRadius.circular(16.0),
                                          //    shapeBorder: Border.all(
                                          //      color: Colors.green,
                                          //    ),
                                          //    backgroundColor: Colors.white,
                                          //    textStyle: TextStyle(
                                          //      color: Colors.green,
                                          //    )
                                          //  );
                                          //  BotToast.showWidget(toastBuilder: null)
                                            // showSuccessToast(context, 'Updated Rollno Successfully!!');//TODO
                                            // Fluttertoast.showToast(msg: 'Updated Name!!');
                                          }else{
                                            showErrorToast( 'Failed!!!');
                                            // Fluttertoast.showToast(msg: 'Failed!!');
                                          }
                                        });
                                      }
                                        await writeposts();
                                     
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
  hallName(String hall){
    hall = hall.replaceAll(' ', '');
    switch(hall.toLowerCase()){
      case 'hallx':  return 'Hall 10';
      break;
      case 'hallxi': return 'Hall 11';
      break;
      default: return hall[0].toUpperCase() + hall.substring(1,4).toLowerCase()+ ' ' + hall.substring(4);
    }
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
