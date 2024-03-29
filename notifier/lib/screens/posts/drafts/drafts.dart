import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/screens/posts/drafts/edit_drafts.dart';
// import 'package:notifier/screens/posts/updateposts.dart';
import 'package:notifier/services/databse.dart';
import 'package:notifier/shared/preview.dart';

class Drafts extends StatefulWidget {
  final String _id;
  final List<String> _subs;
  Drafts(this._id, this._subs);
  @override
  _DraftsState createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {
  bool _load;
  // Map< dynamic> _post;
  List<dynamic> update = List();
  // String _title;
  // String _body;
  bool _loadingDelete = false;

  // }
  // print(docById);

  Future<int> deleteDraft(index) async {
    update.removeAt(index);
    // _post.remove(delete.uid);
    return await writeContentDrafts(json.encode(update)).then((var status) {
      return status ? 200 : 500;
    });
  }

  updateposts() async {
    setState(() {
      _load = true;
    });
    return await fileExists('drafts').then((var _exists) async {
      print(_exists.toString() + 'exists in drafts.dart line 87');
      if (_exists) {
        return await readContentDrafts('drafts').then((var value) {
          print(value);

          if (value != null && value.length != 0) {
            setState(() {
              update = value;
              _load = false;
            });
          } else {
            setState(() {
              update = null;
              _load = false;
            });
          }
        });
      } else {
        setState(() {
          update = null;
          _load = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _load = true;
    });
    updateposts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Drafts'),
        ),
        body: _load
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : update == null
                ? Container(
                    child: Center(
                      child: Text('You have not any saved posts'),
                    ),
                  )
                : Stack(
                    children: <Widget>[
                      Container(
                          child: ListView.builder(
                        itemCount: update.length,
                        itemBuilder: (BuildContext context, int index) {
                          // _post.
                          // print(_exists);
                          // print(_load);
                          return Column(
                            children: <Widget>[
                              ListTile(
                                // dense: ,
                                title: Text(update[index]['title'].toString()),
                                subtitle:
                                    Text(update[index]['message'].toString()),
                                trailing: Wrap(
                                  direction: Axis.vertical,
                                  children: <Widget>[
                                    IconButton(
                                        tooltip: 'Publish',
                                        icon: Icon(Icons.publish),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return Preview(
                                                index, update[index], 'drafts');
                                          }));
                                        }),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      tooltip: 'Edit Post',
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return EditDraft(
                                              UpdatePostsFormat(
                                                  uid: 'kjbkjbdv',
                                                  value: update[index]),
                                              widget._id,
                                              widget._subs,
                                              index);
                                        }));
                                      },
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.delete),
                                        tooltip: 'Delete Post',
                                        onPressed: () async {
                                          showCupertinoDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Row(
                                                    children: <Widget>[
                                                      Icon(Icons.warning,
                                                        color: Colors.red,
                                                      ),
                                                      Text(' Delete this Post ?',
                                                        style: TextStyle(
                                                          color: Colors.red
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Column(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                          'Doing this will permanently delete this file',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold
                                                            ) ,
                                                          ),
                                                          SizedBox(height: 5.0),
                                                      Text(
                                                          'Note: You will not be able to recover this file later',
                                                        style:TextStyle(
                                                              fontSize: 10.0,
                                                              color: Colors.red,
                                                              fontWeight: FontWeight.bold
                                                            )    
                                                      ),
                                                  //   ],
                                                  // ),
                                                  SizedBox(height: 10.0),
                                                  Row(mainAxisAlignment: MainAxisAlignment.end,
                                                  children:  <Widget>[
                                                    FlatButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text('Dismiss'),
                                                    ),
                                                    SizedBox(width:10.0),
                                                    RaisedButton(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8.0)
                                                        ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          _loadingDelete = true;
                                                        });
                                                        Navigator.pop(context);
                                                        await deleteDraft(index).then((var statusCode) {
                                                          if (statusCode ==200) {
                                                            if (update.length ==0) {
                                                              setState(() {
                                                                update = null;
                                                                
                                                              });
                                                            }
                                                            setState(() {
                                                              _loadingDelete =false;
                                                            });
                                                              Fluttertoast.showToast(msg:'Delete Successful');
                                                              // Navigator.pop(context);
                                                            
                                                          } else {
                                                            setState(() {
                                                              _loadingDelete =false;
                                                             
                                                            });
                                                            Fluttertoast.showToast(msg:'Deletion Failed!!');
                                                            // Navigator.pop(context);
                                                          }

                                                        });
                                                      },
                                                      child: Text('Confirm',
                                                        style: TextStyle(color:Colors.white),
                                                      ),
                                                    ),
                                                    // CupertinoDialogAction(child: Text('Confirm')),
                                                    // CupertinoDialogAction(child: Text('Dismiss'))
                                                  ],
                                                  ),
                                                    ])
                                                );
                                                ;
                                              });
                                        })
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.grey,
                              )
                            ],
                          );
                        },
                      )),
                      _loadingDelete
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container()
                    ],
                  ));
  }
}
