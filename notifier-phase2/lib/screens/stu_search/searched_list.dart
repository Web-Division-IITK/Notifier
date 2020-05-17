import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/screens/stu_search/card_details.dart';

class SearchedList extends StatelessWidget {
  final List<SearchModel> list;
  SearchedList(this.list);

  @override
  Widget build(BuildContext context) {
    list.sort((a, b) => a.name.compareTo(b.name));
    return Scaffold(
      appBar: AppBar(title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Search Results'),
          list.length !=0?(list.length.toString()):Container(),
        ],
      )),
      body: list == null || list.length == 0
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
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return ListItemStudent(
                    MediaQuery.of(context).size.width, list[index]);
              }),
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
      height: 90.0,
      width: itemWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
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
              child: Container(
                width: itemWidth - 88,
                padding: const EdgeInsets.only(left: 16.0, top: 8),
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
            'https://oa.cc.iitk.ac.in/Oa/Jsp/Photo/${user.rollno}_0.jpg';
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
        print(e);
        return 'assets/profilepic.jpg';
      }
    });
}
}


