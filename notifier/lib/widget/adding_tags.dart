import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notifier/widget/chips.dart';

class AddingTags extends StatefulWidget {
   String tag;
   final TextEditingController tagController;
   List<dynamic> tags;
  AddingTags(this.tag,this.tags,this.tagController);
  @override
  _AddingTagsState createState() => _AddingTagsState();
}

class _AddingTagsState extends State<AddingTags> {
  @override
  Widget build(BuildContext context) {
   final _formKey = GlobalKey<FormState>();
          String addTag;
          
          return CupertinoActionSheet(
            actions: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 100.0),
                child: RaisedButton(
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                    child: Text('Add Tags',
                    style: TextStyle(
                      color: Colors.white
                    )
                    ),
                    onPressed: () {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: Text('Add tag'),
                          content: Form(
                            key: _formKey,
                              child:  Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: Material(
                        color: Colors.transparent,
                          child: TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            decoration: new InputDecoration(
                              labelText: 'Tag',
                            ),
                            validator: (value) => value.isEmpty
                              ?'Tags can\'t be empty'
                                : null,
                            onSaved: (value) {
                              addTag = value;
                              // widget.tag = value.toString() + ' ;';
                              // tags.add(value);
                            }
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
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Dismiss')),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: RaisedButton(
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0)),
                                    // color: Colors.blue,
                                    onPressed: () {
                                      // Fluttertoast.showToast(msg: 'Creating post');
                                      // Fluttertoast.cancel();
                                      // print(createwidget.tagsToList(widget.tags[0]));
                                      // widget.tags = widget.tag.split(';');
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();
                                        setState(() {
                                          // tagForChip!=null?tagForChip += addTag + ' ;' : tagForChip = addTag + ' ;';
                                          widget.tags.add(addTag);
                                        });
                                        Navigator.of(context).pop();
                                        // confirmPage();
                                      }
                                    },
                                    child: Text(
                                      'Add Tag',
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
                    }),
              ),
            ],
            message: CreateChips(this.widget.tag,this.widget.tags),
            cancelButton: Column(
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    setState(() {
                      
                      // print(widget.tagsForChips);
                      widget.tag??='';
                      widget.tag!=null || widget.tag != ''? widget.tag =widget.tag:widget.tag = '';
                      for (var i in widget.tags) {
                        widget.tag += i + '; ';
                      }
                      // widget.tag = tagForChip;
                      // widget.tags = widget.tagsForChips;
                      widget.tagController.text = widget.tag;
                      print(widget.tag + ':widget.tags line807');
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Done',
                  style: TextStyle(
                      color: Colors.white
                    ),),
                ),
              ],
            ),
          );
  }
}