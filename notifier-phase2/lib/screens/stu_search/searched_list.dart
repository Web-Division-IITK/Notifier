
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/screens/profile/profilepic.dart';
import 'package:notifier/screens/stu_search/card_details.dart';
import 'package:notifier/services/functions.dart';

import '../../database/student_search.dart';
import 'stu_search.dart';


class Seraching extends StatelessWidget {
  final SearchModel query;
  Seraching(this.query);
  final AsyncMemoizer memorizer = AsyncMemoizer();
  @override
  Widget build(BuildContext context) {
    // var list = [];
    return SafeArea(
      child: StatefulBuilder(builder: (context,setState){
        return Scaffold(
          // appBar: AppBar(title: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: <Widget>[
          //     Text('Search Results'),
          //     // list == null || list.length ==0 ? Container():Text('${list.length}')
          //   ],
          // )),
          body: FutureBuilder(
            future: getList(),
            builder: (context,AsyncSnapshot<List<SearchModel>> snapshot){
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                // setState((){list = snapshot.data;});
                // list = snapshot.data;
                  return SearchedList(snapshot.data);
                  break;
                default: return Center(child: CircularProgressIndicator(),);
              }
          }),
        );
      }),
    );
  }
  Future<List<SearchModel>> getList() async{
    // return memorizer.runOnce(()async{
      return await StuSearchDatabase().getAllStuData().then((list)async{
      // var data = 
       return list.where((test){
        return 
        (checkifThereisAvalue(query.bloodGroup, test.bloodGroup) && 
        (checkifThereisAvalue(query.dept, test.dept)||checkifThereisAvalue(convertAbbrvofDeptToF(query.dept), test.dept)) &&
        checkifThereisAvalue(query.gender, test.gender) &&
        checkifThereisAvalue(query.hall, test.hall) &&
        checkifThereisAvalue(query.hometown, test.hometown) && 
        checkifThereisAvalue(query.program, test.program) &&
        (checkifThereisAvalue(query.rollno, test.rollno) ||
        checkifThereisAvalue(query.name, test.name) ||
        checkifThereisAvalue(query.username, test.username)) &&
        checkifThereisAvalue(query.year,test.year));
      }).toList();
      // return await Future.delayed(Duration(milliseconds:80),()=>data);
    });
    // });
  }
}

class SearchedList extends StatelessWidget {
  final List<SearchModel> list;
  SearchedList(this.list);

  @override
  Widget build(BuildContext context) {
    if(list != null && list.length != 0)
    list.sort((a, b) => a.name.compareTo(b.name));
    list.retainWhere((test){
      return (
        (test.name !=null && test.name.trim() != "")
        // && (test.gender != null && test.gender.trim() != "")
        // && (test.program != null && test.program.trim() != "")
        && (test.dept != null && test.dept.trim() != "")
        // && (test.bloodGroup != null && test.bloodGroup.trim() != "")
        // && (test.hall != null && test.hall.trim() != "")
        // && (test.hometown != null && test.hometown.trim() != "")
        // && (test.room != null && test.room.trim() != "")
        // && (test.rollno != null && test.rollno.trim() != "")
        // && (test.username != null && test.username.trim() != "")
      );
    });
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Search Results'),
            list == null || list.length ==0 ? Container():Text('${list.length}')
          ],
        )),
        body:
         list == null || list.length == 0
            ? Container(
                child: Center(
                  child: Wrap(
                     children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                MaterialIcons.sentiment_dissatisfied,
                                size: 35.0,
                              ),
                              SizedBox(width: 10.0),
                              Text('No results found !!!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18.0)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : CupertinoScrollbar(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return ListItemStudent(
                    MediaQuery.of(context).size.width, list[index]);
                }),
            ),
      ),
    );
  }
}

class ListItemStudent extends StatelessWidget {
  final double itemWidth;
  final SearchModel user;
  ListItemStudent(this.itemWidth, this.user);
  // final AsyncMemoizer _memorizer = AsyncMemoizer();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          minHeight: 90.0,
        ),
        width: itemWidth,
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
          onTap: () {
            return showDialog(
                context: (context),
                builder: (context) {
                  return StudentCard(user,ProfilePic(user).getProfilePic());
                });
          },
          borderRadius: BorderRadius.circular(16),
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 6,
                  child: Container(
                    width: itemWidth -112,
                    padding: const EdgeInsets.only(left: 16.0,top: 16.0,bottom: 16.0,right: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.name,
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 10,),
                        Text(user.username + '@iitk.ac.in',
                          style: TextStyle(fontSize: 17),
                        ),
                        SizedBox(height: 4,),
                        Text(user.dept,
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(height: 4,),
                        Text(user.rollno,
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: FutureBuilder(
                  future: ProfilePic(user).getProfilePic(),
                  builder: (context,  snapshot) {
                    switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if(snapshot== null || snapshot.data == null || !snapshot.hasData){
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset('assets/${user.gender.toLowerCase()}profile.png'));
                      }
                      else{
                        // print(snapshot.data);
                        return Container(
                          constraints: BoxConstraints(maxHeight: double.maxFinite),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image(
                              image: 
                              // AssetImage('assets/${user.gender.toLowerCase()}profile.png'),
                              snapshot.data,
                              fit: BoxFit.fitWidth,
                              loadingBuilder: (context,widget, event){
                                if(event == null){
                                  return widget;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: event.expectedTotalBytes!=null ?
                                    event.cumulativeBytesLoaded/event.expectedTotalBytes : null,
                                  ),
                                );
                              },
                              frameBuilder: (context,child,frame, wasSyncLoaded){
                                if(wasSyncLoaded){
                                  return child;
                                }
                                return AnimatedOpacity(
                                  child: child,
                                  opacity: frame == null?0:1, 
                                  duration: Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                );
                              },
                            )
                          ),
                        );
                      }
                      break;
                    default: return Center(
                      child: CircularProgressIndicator(),
                    );
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}

// Future<ImageProvider>getImageURL(SearchModel user,{memorizer}) async {
//     final HttpClient _httpClient = HttpClient();
//     File ima = await file('${user.rollno}.jpg');
//     File i_file;
//     try {
//        String url = 'http://home.iitk.ac.in/~${user.username}/dp';
//        Response res = await get(url);
//        if(res.statusCode ==  200){
//          return MemoryImage(res.bodyBytes);
//        }else{
//          return await ima.exists().then((existence)async{
//       // print(existence);
//           if(existence == true){
//             return MemoryImage(ima.readAsBytesSync());
//           }else{
//             return await memorizer.runOnce(()async{
//               try {
//                 String url1 =
//                     'https://oa.cc.iitk.ac.in:443/Oa/Jsp/Photo/${user.rollno}_0.jpg';
//                 Response res = await get(url1);
//                 String format = '.jpg';
//                 // print(res.request.url.scheme);
              
//                 if (res.statusCode != 200) {
//                     return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
//                 }
//                 try {
//                   print(format = res.headers['content-location'].replaceAll('dp', ''));
//                 } catch (e) {
//                   print(e);
//                 }
//                   try {
//                     i_file = await file('${user.rollno}.jpg');
//                   } catch (e) {
//                     print(e);
//                   }
//                   print(i_file);
//                 // }

//                 return NetworkToFileImage(file: i_file, url: url,debug: true);
//               } catch (e) {
//                 print(e);
//                 return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
//               }
//             });
//           }
//         });
//        }
//     } catch (e) {
//       print(e);
//       return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
//     }
    
    
    
    
// }
// class ImageAnimationLoading extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation:FadeInImage.memoryNetwork(placeholder: null, image: null),
      
//     );
//   }
// }

