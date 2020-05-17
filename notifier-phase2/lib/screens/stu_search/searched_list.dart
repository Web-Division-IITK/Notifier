import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/screens/stu_search/card_details.dart';
import 'package:notifier/services/functions.dart';

import '../../database/student_search.dart';
import 'stu_search.dart';


class Seraching extends StatelessWidget {
  final SearchModel query;
  Seraching(this.query);
  AsyncMemoizer memorizer = AsyncMemoizer();
  @override
  Widget build(BuildContext context) {
    // var list = [];
    return StatefulBuilder(builder: (context,setState){
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
    });
  }
  Future<List<SearchModel>> getList() async{
    // return memorizer.runOnce(()async{
      return await StuSearchDatabase().getAllStuData().then((list){
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
    return Scaffold(
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
              itemCount: list.length,
              itemBuilder: (context, index) {
                return ListItemStudent(
                  MediaQuery.of(context).size.width, list[index]);
              }),
          ),
    );
  }
}

class ListItemStudent extends StatelessWidget {
  final double itemWidth;
  final SearchModel user;
  ListItemStudent(this.itemWidth, this.user);
  AsyncMemoizer _memorizer = AsyncMemoizer();
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 90.0,
      ),
      width: itemWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          

          /*Positioned(
            right: 0.0,
            child: */
          InkWell(
            onTap: () {
              return showDialog(
                  context: (context),
                  builder: (context) {
                    return StudentCard(user,getImageURL(user));
                  });
            },
            // width: double.maxFinite,
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: <Widget>[
                  Container(
                    width: itemWidth -112,
                    padding: const EdgeInsets.only(left: 16.0,),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.name,
                          style: TextStyle(fontSize: 17),
                        ),
                        Text(user.dept),
                        Text(user.rollno)
                      ],
                    ),
                  ),
                  CircleAvatar(
            radius: 40.0,
            child: FutureBuilder(
                future: getImageURL(user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if(snapshot== null || snapshot.data == null || !snapshot.hasData){
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset('assets/profilepic.jpg'));
                      }else if (snapshot.data.contains('assets')) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset('assets/profilepic.jpg'));
                      }
                      else{
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          // child: Image.network(
                          //   snapshot.data,
                          //    fit: BoxFit.fill,
                          //    loadingBuilder: (context,wid,ch){
                          //      return Center(
                          //       child: CircularProgressIndicator(),
                          //     );
                          //    },
                          //  ),
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            width: 190,
                            height: 190,
                            imageUrl: snapshot.data,
                            errorWidget: (context, string, dy) {
                              return Image.asset('assets/profilepic.jpg');
                            },
                            progressIndicatorBuilder: (context, st, prog) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
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
          )
          // )
        ],
      ),
    );
  }
  Future<String>getImageURL(SearchModel user) async {
    return await this._memorizer.runOnce(()async{
      try {
        String url = 'http://home.iitk.ac.in/~${user.username}/dp';
        String url1 =
            'https://oa.cc.iitk.ac.in:443/Oa/Jsp/Photo/${user.rollno}_0.jpg';
        Response res = await get(url);
        if (res.statusCode != 200) {
          res = await get(url1);
          if (res.statusCode != 200) {
            return 'assets/profilepic.jpg';
          }
          return url1;
        }
        return url;
      } catch (e) {
        // print(e);
        return 'assets/profilepic.jpg';
      }
    });
}
}


