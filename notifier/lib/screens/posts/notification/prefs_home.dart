import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notifier/model/notification.dart';
import 'package:notifier/screens/posts/notification/notification.dart';
import 'package:notifier/screens/posts/notification/not_info.dart';
import 'package:notifier/services/databse.dart';

class PrefsHome extends StatefulWidget {
  @override
  _PrefsHomeState createState() => _PrefsHomeState();
}

class _PrefsHomeState extends State<PrefsHome> {

  List<dynamic> _prefs = [];
  List<SortDateTime> arrayWithclub=[];
  bool prefsHome;
  bool load;
  @override
  void initState() { 
    //  setState(() {
      load = true;
    // });
    readContent('users').then((var value){
      if(value!=null){
        var councilData = value["council"];
        councilData.keys.forEach((key){
          _prefs += (councilData[key]["entity"].cast<String>() + councilData[key]["misc"].cast<String>());
        });
        // _prefs = value['prefs'];
        // print(_prefs);
        if(_prefs !=null && _prefs.length!=0){
          sortArraywithPrefs();
        }
        else{
          setState(() {
            prefsHome = false;
            load =false;
          });
        }
      }
    });
    super.initState();
   
  }
  List<int> indices =[];
sortArraywithPrefs(){
  sortedarray.forEach((f){
    if(_prefs.contains(f.club)){
      var index = arrayWithclub.length /*> 0 ? arrayWithclub.length : 0*/;
      indices.add(sortedarray.indexOf(f));
      arrayWithclub.insert(index, f);
    }
    else{
      if(arrayWithclub.contains(f.club)){
        arrayWithclub.remove(f);
        if(indices.contains(sortedarray.indexOf(f))){
          indices.remove(sortedarray.indexOf(f));
        }
      }
    }
  });
  if(arrayWithclub.length != _prefs.length){
    setState(() {
    prefsHome = true;
    load =false;
  });
  }
}
  Iterable<Widget> get arrayofTime sync*{
    for (var i in arrayWithclub) {
      DateTime postTime = DateTime.parse(i.value['timeStamp']);
      var time;var day;
      // var dayTime = DateFormat('d mm yyyy').format;
      if (DateTime.now().day == postTime.day && DateTime.now().month == postTime.month && DateTime.now().year == postTime.year) {
                if (DateTime.now().hour == postTime.hour ||
                    (DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) < 3600000) {
                  switch (DateTime.now().minute - postTime.minute) {
                    case 0:
                      time = 'now';
                      day = 'Today';
                      break;
                    default:
                      var i = ((DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) /60000)
                          .round();
                      time = '$i minutes ago';
                      day = 'Today';
                  }
                } else {
                  time = DateFormat('kk:mm').format(postTime);
                  day = 'Today';
                }
              } else {
                time = DateFormat('d MMMM, yyyy : kk:mm').format(postTime);
                day = DateFormat('d MMMM, yyyy').format(postTime);
              }
      switch(i.dateasString){
        case 'Today':{
          if (arrayWithclub.firstWhere((test){
            return (test.dateasString == 'Today' && (test.value['exists'] == null || test.value['exists']))?
            true : false;
          }) == i) {
            yield Column(
               children: <Widget>[
                 Container(child: Text('Today'),),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    )
               ],
             );
          } else {
            yield (i.value['exists'] == null ||
                      !i.value['exists'])
                  ? Container()
                  // : time ==  ?
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    );
          }
        } 
          break;
        case 'Yesterday' : {
          if (arrayWithclub.firstWhere((test){
            return (test.dateasString == 'Yesterday' && (test.value['exists'] == null || test.value['exists']))?true:false;
          }) == i) {
             yield Column(
               children: <Widget>[
                 Container(child: Text('Yesterday'),),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    )
               ],
             );
          } else {
            yield (i.value['exists'] == null ||
                      !i.value['exists'])
                  ? Container()
                  // : time ==  ?
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    );
          }
        }
          break;
        default: if (sortedarray.firstWhere((test){
          return (test.dateasString == day && (test.value['exists'] == null || test.value['exists']))?true:false;
        }) == i) {
          yield Column(
               children: <Widget>[
                 Container(child: Text(day),),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    )
               ],
             );
        } else {
          yield (i.value['exists'] == null ||
                      !i.value['exists'])
                  ? Container()
                  // : time ==  ?
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: tile(i.value,sortedarray.indexOf(i) , time),
                    );
        }
        break;
      } 
    }
  }
  @override
  Widget build(BuildContext context) {
    return load ? Center(child: CircularProgressIndicator(),):
    prefsHome!=null && !prefsHome ?  Center(child:Text('You don,t have any preferences') )
     : Container(

        padding: EdgeInsets.only(top: 10.0),
        child: ListView(
          // shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          children: arrayofTime.toList(),
        ),
        // child: ListView.builder(
        //     physics: AlwaysScrollableScrollPhysics(),
        //     // controller: _controller,
        //     itemCount: arrayWithclub.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       DateTime postTime =
        //           DateTime.parse(arrayWithclub[index].value['timeStamp']);
        //       var time;
        //       var day;
        //       if (DateTime.now().day == postTime.day &&
        //           DateTime.now().month == postTime.month &&
        //           DateTime.now().year == postTime.year) {
        //         if (DateTime.now().hour == postTime.hour ||
        //             (DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) < 3600000) {
        //           switch (DateTime.now().minute - postTime.minute) {
        //             case 0:
        //               time = 'now';
        //               day = 'Today';
        //               break;
        //             default:
        //               var i = ((DateTime.now().millisecondsSinceEpoch - postTime.millisecondsSinceEpoch) /60000)
        //                   .round();
        //               time = '$i minutes ago';
        //               day = 'Today';
        //           }
        //         } else {
        //           time = 'Today, ' + DateFormat('kk:mm').format(postTime);
        //           day = 'Today';
        //         }
        //       } else {
        //         time = DateFormat('d MMMM, yyyy : kk:mm').format(postTime);
        //         day = DateFormat('d MMMM, yyyy').format(postTime);
        //       }
        //       return (arrayWithclub[index].value['exists'] == null ||
        //               !arrayWithclub[index].value['exists'])
        //           ? Container()
        //           // : time ==  ?
        //           : Container(
        //               margin: const EdgeInsets.symmetric(horizontal: 16.0),
        //               child: tile(arrayWithclub[index].value, index, time),
        //             );
        //     }
        //   )
    );
  }

  Widget tile(timenot, index, time) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          return Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return NotfDesc(index,indices,time);
          }));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              child: AutoSizeText(timenot['sub'][0],
                  // 'Science and Texhnology Council',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.blueGrey
                        : Colors.white70,
                    // fontWeight: FontStyle.italic,
                    fontSize: 13.0,
                  )),
            ),
            Container(
              // alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
              child: AutoSizeText(timenot['title'],
                  // 'Sit commodo fugiat duis consectetur sunt ipsum cupidatat adipisicing mollit et magna duis.',
                  minFontSize: 18.0,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  )),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
              child: AutoSizeText(
                timenot['message'],
                // 'Dolor consectetur in dolore anim reprehenderit velit pariatur veniam nostrud id ex exercitation.',
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[850]
                      : Colors.white70,
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 5.0),
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey
                        : Colors.white70,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
