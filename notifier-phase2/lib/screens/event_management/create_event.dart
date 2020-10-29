import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notifier/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:notifier/database/reminder.dart';
import 'package:notifier/model/options.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/event_management/event_description.dart';
import 'package:notifier/screens/event_management/schedule_reminder.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/chips.dart';
import 'package:notifier/widget/showtoast.dart';

class CreateEditEvent extends StatefulWidget {
  final String type;
  /// index of post in globalPOstsArray;
  final int index;
  final PostsSort post;
  final String title;
  CreateEditEvent(this.type,this.index,this.post,{this.title = 'edit'});
  @override
  _CreateEditEventState createState() => _CreateEditEventState();
}

class _CreateEditEventState extends State<CreateEditEvent> {
  final _formKey = GlobalKey<FormState>();
  PostsSort post= PostsSort();
  Repository repo = Repository(allCouncilData);
  final _tagController = TextEditingController();  // String _subtitile;
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final validation = TextEditingController();
  Duration duration = Duration();
  bool _loadingWidget = false;
  String title;
  var time = false;
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
  }
    return false;
  }
  @override
  void initState() {
    post = copyPost(widget.post);
    _loadingWidget = false;
    if(widget.type.toLowerCase() == 'create'){
      if((post.owner!=null && post.owner != id)){
        title = 'Edit';
      }else{
        title = 'Create';
      }
    }
    else{
      title = 'Edit';
    }    
    super.initState();
    _tagController.text = post.tags;
    if(post.tags == 'null' ||post.tags==null|| post.tags =='' || post.tags.trim() == '') _tagController.clear();
    
    _startTimeController.text = (post.startTime == 0 || post.startTime == null) ?''
     :intl.DateFormat("hh:mm a, dd MMMM, yyyy").format(DateTime.fromMillisecondsSinceEpoch(post.startTime));
    _endTimeController.text = (post.startTime == 0 || post.startTime == null) ?''
    :intl.DateFormat("hh:mm a, dd MMMM, yyyy").format(DateTime.fromMillisecondsSinceEpoch(post.endTime));
  }
  @override
  void dispose() {
    super.dispose();
    _tagController?.dispose();
    _endTimeController?.dispose();
    _startTimeController?.dispose();
  }


  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return !(_loadingWidget && widget.type.toLowerCase() == 'update');
      },
      child: AbsorbPointer(
        absorbing: false,
        child: Scaffold(
          appBar: AppBar(
            title:Text(title + ' Event'),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                                child: new TextFormField(
                                  toolbarOptions: ToolbarOptions(
                                    copy: true,
                                    paste: true,
                                    cut: true,
                                    selectAll: true,
                                  ),
                                  maxLines: 1,
                                  keyboardType: TextInputType.text,
                                  autofocus: false,
                                  initialValue: post.title,
                                  decoration: new InputDecoration(
                                    labelText: 'Title',
                                    hintText: 'Title of the Event',
                                  ),
                                  validator: (value) =>
                                    value.isEmpty ? 'Title can\'t be empty' : null,
                                  onSaved: (value) => post.title = value,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                                child: new TextFormField(
                                  toolbarOptions: ToolbarOptions(
                                    copy: true,
                                    paste: true,
                                    cut: true,
                                    selectAll: true,
                                  ),
                                  textDirection: TextDirection.ltr,
                                  textInputAction: TextInputAction.next,
                                  maxLines: 1,
                                  keyboardType: TextInputType.text,
                                  autofocus: false,
                                  buildCounter: (context,{currentLength:0,isFocused:false,maxLength:200}){
                                    if(isFocused && currentLength!=0 && currentLength <200){
                                      return Container(
                                        child: Text('Char length: $currentLength',
                                          textAlign: TextAlign.left,
                                          textDirection: TextDirection.ltr,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).brightness == Brightness.dark? Colors.white70:Colors.grey[900]
                                          ),
                                        ),
                                      );
                                    }
                                    else if(isFocused&& currentLength >200){
                                      return Container(
                                        width: MediaQuery.of(context).size.width -40,
                                        child: Text('This Field\'s length should be less than 200 chars',
                                          textAlign: TextAlign.left,
                                          textDirection: TextDirection.ltr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red
                                          ),
                                        ),
                                      );
                                    }else if(isFocused){
                                      return Container(
                                        width: MediaQuery.of(context).size.width -40,
                                        child: Text('Your message\'s character length should be less than 200',
                                          textAlign: TextAlign.left,
                                          textDirection: TextDirection.ltr,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).brightness == Brightness.dark? Colors.white38:Colors.grey[800]
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  initialValue: post.message,
                                  decoration: new InputDecoration(
                                    labelText: 'Message',
                                    hintText: 'Subtitile to be displayed in the notifications panel ',
                                  ),
                                  validator: (value) =>
                                    value.isEmpty ? 'Message can\'t be empty' : (
                                      value.length >200 ? 'This Field\'s length should be less than 200 chars'
                                      :null
                                    ),
                                  onSaved: (value) => post.message = value,
                                ),
                              ),
                              ClipRRect(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                                  child: new TextFormField(
                                    toolbarOptions: ToolbarOptions(
                                      copy: true,
                                      paste: true,
                                      selectAll: true,
                                    ),
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    autofocus: false,
                                    initialValue: post.body,
                                    decoration: new InputDecoration(
                                      labelText: 'Body',
                                      hintText: 'Body of the event',
                                    ),
                                    validator: (value) =>
                                      value.isEmpty ? 'Body of message can\'t be empty' : null,
                                    onSaved: (value) => post.body = value,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex:7,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width - 150.0,
                                        child: new TextFormField(
                                          toolbarOptions: ToolbarOptions(
                                            copy: true,
                                            paste: true,
                                            selectAll: true,
                                          ),
                                          maxLines: null,
                                          // enabled: false,
                                          controller: _tagController,
                                          keyboardType: TextInputType.multiline,
                                          autofocus: false,
                                          readOnly: true,
                                          onTap: (){
                                            addingTag();
                                          },
                                          decoration: new InputDecoration(
                                            labelText: 'Tags',
                                          ),
                                          onSaved: (value) {  
                                            if(value == null || value == '' || value.trim() == '' || value.trim() == null){
                                              return post.tags= '';
                                            }
                                            return post.tags = value;
                                          },
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex:3,
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 20.0),
                                        child: IconButton(
                                          tooltip: 'Add tags',
                                          icon: Icon(
                                            MaterialIcons.add,
                                            color: Theme.of(context).accentColor,                                          
                                            size: 30.0,
                                          ),
                                          onPressed: () {
                                            addingTag();
                                          }
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding:  _startTimeController.text != null &&_startTimeController.text != '' ?
                                  EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0)
                                  : EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 20.0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width - 150.0,
                                      child: new TextFormField(
                                        toolbarOptions: ToolbarOptions(
                                          copy: true,
                                          paste: true,
                                          selectAll: true,
                                        ),
                                        maxLines: 1,
                                        // maxLength: ,
                                        controller: _startTimeController,
                                        readOnly: true,
                                        // enabled: false,
                                        keyboardType: TextInputType.text,
                                        autofocus: false,
                                        onTap: ()async{
                                          DateTime date= await showDatePicker(
                                            context: context, 
                                            initialDate: DateTime.now(), 
                                            firstDate: DateTime(DateTime.now().day), 
                                            lastDate: DateTime(DateTime.now().year  + 30),
                                            builder: (context,child){
                                              return Theme(
                                                data: Theme.of(context), 
                                                child: child
                                              );
                                            }
                                          ).then((date) async{
                                            if(date!=null){
                                              var time = await showTimePicker(
                                                context: context, 
                                                initialTime: TimeOfDay.now(),
                                                builder: (context,child){
                                                  return Directionality(
                                                    textDirection: TextDirection.ltr, 
                                                    child: child
                                                  );
                                                }
                                              );
                                              if(time!=null){
                                                return DateTime(date.year,date.month,date.day,time.hour,time.minute,);
                                              }
                                              else{
                                                return null;
                                              }
                                            }
                                            else{
                                              return null;
                                            }
                                          });
                                          if(date!=null){
                                            _startTimeController.text = 'vh';
                                              setState(() {
                                                _startTimeController.text = intl.DateFormat("hh:mm a, dd MMMM, yyyy").format(date);
                                              });
                                          }
                                        },
                                        decoration: new InputDecoration(
                                          labelText: 'Event Start Date Time',
                                          hintStyle: TextStyle(
                                            fontSize: 10.0
                                          ),
                                        ),
                                        validator: (value) =>
                                          value == null || value.isEmpty ? 'You need to provide a start time' : null,
                                        onSaved: (value) {
                                          if(value == null || value == '' || value.trim() == '' || value.trim() == null){
                                            return post.startTime = 0;
                                          }
                                          return post.startTime = convertDateFromStringToDateTime(value).millisecondsSinceEpoch;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      child: IconButton(
                                        tooltip: 'Select Start Date and Time',
                                        icon: Icon(Octicons.calendar,
                                          color: Theme.of(context).accentColor,
                                          size: 26.0,
                                        ), 
                                        onPressed: ()async{
                                          DateTime date= await showDatePicker(
                                      context: context, 
                                      initialDate: DateTime.now(), 
                                      firstDate: DateTime(DateTime.now().day), 
                                      lastDate: DateTime(DateTime.now().year  + 30),
                                      builder: (context,child){
                                        return Theme(
                                          data: Theme.of(context), 
                                          child: child
                                        );
                                      }
                                        ).then((date) async{
                                          if(date!=null){
                                            var time = await showTimePicker(
                                              context: context, 
                                              initialTime: TimeOfDay.now(),
                                              builder: (context,child){
                                                return Directionality(
                                                  textDirection: TextDirection.ltr, 
                                                  child: child
                                                );
                                              }
                                            );
                                            if(time!=null){
                                              return DateTime(date.year,date.month,date.day,time.hour,time.minute,);
                                            }
                                            else{
                                              return null;
                                            }
                                          }
                                          else{
                                            return null;
                                          }
                                        });
                                        if(date!=null){
                                          _startTimeController.text = 'vh';
                                              setState(() {
                                                 _startTimeController.text = intl.DateFormat("hh:mm a, dd MMMM, yyyy").format(date);
                                              });
                                        }
                                      }),
                                      
                                    ),
                                    _startTimeController.text != null &&_startTimeController.text != '' ?
                                         IconButton(
                                          icon: Icon(MaterialIcons.clear,
                                            color: Theme.of(context).accentColor,
                                            size:26
                                          ),
                                          tooltip: 'Clear',
                                          onPressed: (){
                                            setState(() {
                                              _startTimeController.clear();
                                            });
                                          }):Container(),
                              ]
                            )
                          ),
                              _startTimeController.text != null &&_startTimeController.text != '' ?
                              Container(
                                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
                                child: Row(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width - 150.0,
                                    child: new TextFormField(
                                      onTap: ()async{
                                        DateTime date= await showDatePicker(
                                          context: context, 
                                          initialDate: DateTime.now(), 
                                          firstDate: DateTime(DateTime.now().day), 
                                          lastDate: DateTime(DateTime.now().year  + 30),
                                          builder: (context,child){
                                            return Theme(
                                              data: Theme.of(context), 
                                              child: child
                                            );
                                          }
                                        ).then((date) async{
                                          if(date!=null){
                                            var time = await showTimePicker(
                                              context: context, 
                                              initialTime: TimeOfDay.now(),
                                              builder: (context,child){
                                                return Directionality(
                                                  textDirection: TextDirection.ltr, 
                                                  child: child
                                                );
                                              }
                                            );
                                            if(time!=null){
                                              return DateTime(date.year,date.month,date.day,time.hour,time.minute,);
                                            }
                                            else{
                                              return null;
                                            }
                                          }
                                          else{
                                            return null;
                                          }
                                        });
                                        if(date!=null){
                                          _endTimeController.text = 'vh';
                                          setState(() {
                                            _endTimeController.text = intl.DateFormat("hh:mm a, dd MMMM, yyyy").format(date);
                                          });
                                        }
                                      },
                                      toolbarOptions: ToolbarOptions(
                                          copy: true,
                                          paste: true,
                                          selectAll: true,
                                        ),
                                      maxLines: 1,
                                      // maxLength: ,
                                      controller: _endTimeController,
                                      readOnly: true,
                                      // enabled: false,
                                      keyboardType: TextInputType.text,
                                      autofocus: false,
                                      autovalidate: true,
                                      validator: (value){
                                        print(convertDateFromStringToDateTime(_startTimeController.text));
                                        // print(convertDateFromStringToDateTime(_endTimeController.text).millisecondsSinceEpoch < (convertDateFromStringToDateTime(_startTimeController.text)).millisecondsSinceEpoch);
                                        if(value != null && value.isNotEmpty && convertDateFromStringToDateTime(_endTimeController.text).millisecondsSinceEpoch < (convertDateFromStringToDateTime(_startTimeController.text)).millisecondsSinceEpoch){
                                          // setState(() {
                                          //   if(mounted){
                                            validation.text = 'End Time should be grater than start time';
                                              return 'End Time should be grater than start time';
                                        }else if(value == null || value.isEmpty){
                                          validation.text = 'You need to provide end time for the event';
                                          return 'You need to provide end time for the event';
                                        }else{
                                          // setState(() {
                                            validation.text = '';
                                            return null;
                                          // });
                                        }
                                        
                                      },
                                      decoration: new InputDecoration(
                                        errorStyle: TextStyle(
                                          fontSize: 10.0,
                                          color: Colors.red
                                        ),
                                        // errorText: 'End Time should be grater than start time',
                                        // enabled: false,
                                        labelText: 'Event End DateTime',
                                        // hintText: 'You can add Date Time or tap on calender icon',
                                        hintStyle: TextStyle(
                                          fontSize: 10.0
                                        ),
                                      ),
                                      onSaved: (value) {
                                        if(value == null || value == '' || value.trim() == '' || value.trim() == null){
                                          return post.endTime = 0;
                                        }
                                      return post.endTime = convertDateFromStringToDateTime(value).millisecondsSinceEpoch;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: IconButton(
                                      tooltip: 'Select End Date and Time',
                                      icon: Icon(MaterialIcons.timelapse,
                                        color: Theme.of(context).accentColor,
                                        size: 26.0,
                                      ), 
                                      onPressed: ()async{
                                        DateTime date= await showDatePicker(
                                          context: context, 
                                          initialDate: DateTime.now(), 
                                          firstDate: DateTime(DateTime.now().day), 
                                          lastDate: DateTime(DateTime.now().year  + 30),
                                          builder: (context,child){
                                            return Theme(
                                              data: Theme.of(context), 
                                              child: child
                                            );
                                          }
                                        ).then((date) async{
                                          if(date!=null){
                                            var time = await showTimePicker(
                                              context: context, 
                                              initialTime: TimeOfDay.now(),
                                              builder: (context,child){
                                                return Directionality(
                                                  textDirection: TextDirection.ltr, 
                                                  child: child
                                                );
                                              }
                                            );
                                            if(time!=null){
                                              return DateTime(date.year,date.month,date.day,time.hour,time.minute,);
                                            }
                                            else{
                                              return null;
                                            }
                                          }
                                          else{
                                            return null;
                                          }
                                        });
                                        if(date!=null){
                                          _endTimeController.text = 'vh';
                                          setState(() {
                                            _endTimeController.text = intl.DateFormat("hh:mm a, dd MMMM, yyyy").format(date);
                                          });
                                        }
                                      },
                                    )
                                      
                                    ),
                                    _endTimeController.text != null &&_endTimeController.text != '' ?
                                         IconButton(
                                          icon: Icon(MaterialIcons.clear,
                                            color: Theme.of(context).accentColor,
                                            size:26
                                          ),
                                          tooltip: 'Clear',
                                          onPressed: (){
                                            setState(() {
                                              _endTimeController.clear();
                                              validation.clear();
                                            });
                                          }):Container(),
                                  ]
                                )
                              ):Container(),
                              _startTimeController.text != null &&_startTimeController.text != '' ?
                              Container(
                                padding: const EdgeInsets.fromLTRB(20.0,2.0,40.0, 20.0),
                                child: StreamBuilder(
                                  stream: Stream.value(validation.text),
                                  builder: (context, snapshot) {
                                    return Text(
                                      validation.text == null || validation.text==''?
                                      'This field is optional but is necessary for post to show under ongoing events or upcoming events '
                                      : '',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: validation.text == null || validation.text==''? null:Colors.red
                                      )
                                    );
                                  }
                                ),
                              ):Container()
                            ],
                            
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                          height:45.0,
                          // width: 150.0,
                          constraints: BoxConstraints(
                            minWidth: 150
                          ),
                          // alignment: Alignment.bottomCenter,
                          child: RaisedButton.icon(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                                    // color: Colors.blue,
                            onPressed: () async {
                              if (validateAndSave()) {
                                widget.type.toLowerCase() != 'update'? 
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (BuildContext context) {
                                      return FeatureDiscovery(child: EventDescription(listOfPosts: [post],type:widget.type,index: 0,));}))
                                
                                :validateAndSubmit();
                              }
                          },
                          icon: Icon(
                            widget.type.toLowerCase() == 'update'? MaterialCommunityIcons.file_upload_outline :MaterialCommunityIcons.open_in_new,
                            color: Colors.white,
                          ),
                          label: Text(
                            widget.type.toLowerCase() == 'update'? ('Update'):'Preview',
                            style: TextStyle(color: Colors.white,
                              fontSize: 15.0
                            ),
                          )),
                      )
                    ],
                  ),
            ),
            (_loadingWidget && widget.type.toLowerCase() == 'update')?
            Container(
              height:MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.8),
              child: Center(child:Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Text(
                                !time ?
                                ('Creating Event...')
                                : 'Your connectivity seems to be slow',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            ),
                            SizedBox(height:20),
                  SpinKitDualRing(color:Theme.of(context).accentColor),
                ],
              ),))
            : Container() 
                ],
              ),
          ),
        ),
      ),
    );
  }
  addingTag() {
    List<dynamic> newTag = [];
    // setState(() {
      print(_tagController.text);
       if(!(_tagController.text=='null' ||_tagController.text==null||_tagController.text.trim() == ''||_tagController.text.trim()==null)){

          newTag = _tagController.text.split(";");
          newTag = newTag.sublist(0,newTag.length-1);
       }
    // });
    return showModalBottomSheet(
        context: (context),
        builder: (context) {
          // print(_tag.toString()+ ' \'\' tags value');
          // return AddingTags(this._tag, this.tags, _tagController,addingvalue);
          final _formKey = GlobalKey<FormState>();
          String addTag;
          
          return CupertinoActionSheet(
            actions: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 100.0),
                child: RaisedButton.icon(
                  color: Colors.lightBlue,
                  textColor: Colors.white,
                   icon:Icon(MaterialIcons.playlist_add),
                    label: Text('Add Tags',),
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
                                            toolbarOptions: ToolbarOptions(
                                      copy: true,
                                      paste: true,
                                      selectAll: true,
                                    ),
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
                                              // _tag = value.toString() + ' ;';
                                              // tags.add(value);
                                            }
                                          ),
                                      ),
                                    ),
                                    Container(
                                    padding: EdgeInsets.only(bottom: 0.0, top: 25.0,left:0.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        FlatButton(
                                          textColor: Colors.white,
                                                // color: Colors.blue,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Dismiss')),
                                        Padding(
                                              padding: const EdgeInsets.only(left: 5.0),
                                              child: RaisedButton.icon(
                                                  color: Colors.lightBlue,
                                                  textColor: Colors.white,
                                                  icon: Icon(EvilIcons.tag),
                                                  onPressed: () {
                                                    // Fluttertoast.showToast(msg: 'Creating post');
                                                    // Fluttertoast.cancel();
                                                    // print(createTagsToList(tags[0]));
                                                    // tags = _tag.split(';');
                                                    if (_formKey.currentState.validate()) {
                                                      _formKey.currentState.save();
                                                      setState(() {
                                                        // tagForChip!=null?tagForChip += addTag + ' ;' : tagForChip = addTag + ' ;';
                                                        newTag.add(addTag);
                                                        // newTag = tagsForChips;
                                                      });
                                                      Navigator.of(context).pop();
                                                      // confirmPage();
                                                    }
                                                  },
                                                  label: Text(
                                                    'Add Tag',
                                                  )
                                              ),
                                            ),
                                      ]
                                    ),
                                  ),
                                ],
                              ),
                            ), 
                          ),
                        );
                      });
                    }),
              ),
            ],
            message: Container(
              child: CreateChips(_tagController.text,newTag)
              ),
            cancelButton: Column(
              children: <Widget>[
                RaisedButton.icon(
                  textColor: Colors.white,
                  
                  icon: Icon(EvilIcons.check),
                  onPressed: () {
                    setState(() {
                      // tagsForChips = newTag;
                      // print(tagsForChips);
                      _tagController.text = '';
                      for (var i in newTag) {
                        _tagController.text += i + '; ';
                      }
                      // _tag = tagForChip;
                      // tags = tagsForChips;
                      _tagController.text = _tagController.text;
                      print(_tagController.text + ':tags line807');
                    });
                    Navigator.of(context).pop();
                  },
                  label: Text('Done',),
                ),
              ],
            ),
          );
        });
  }
  validateAndSubmit() async {

    if(validateAndSave()){
      // requestPerm?
      showInfoToast('Updating Event !!!');
      // showInfoToast('Updating Posts!!!');
      setState(() {
        _loadingWidget = true;
      });
      Future.delayed(Duration(seconds: 10),(){
                                        if(mounted){setState(()=>time = true);}
                                      });
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    
      try{
        post.council = EVENT_COUNCIL;
        post.sub = EVENT_SUB;
        post.type = EVENT_TYPE;
        // var response = await createEditPosts(post,true,isCreate: false);
        // if(response.statusCode == 200){
          await DatabaseProvider().updatePosts(post);
          await EventReminderNotification(
            'Event has started',reminder: post,id: post.timeStamp,
            time: DateTime.fromMillisecondsSinceEpoch(post.startTime)).initiate;
          showSuccessToast('Event updated Successfully!!!');
          Navigator.of(context).pop();
          if(mounted){
            setState(() {
              _loadingWidget = false;
            });
          }
        // }
        // else{
        //   showErrorToast('Can\'t process your request at this time' );
        //   setState(() {
        //     _loadingWidget = false;
        //   });
        // }
      }catch(e){
        print(e);
        showErrorToast(e.message??'Can\'t process your request at this time');
        setState(() {
            _loadingWidget = false;
          });
      }
    }
  }
}