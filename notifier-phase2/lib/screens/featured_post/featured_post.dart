import 'package:auto_size_text/auto_size_text.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:notifier/colors.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/screens/posts/post_desc.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';

class FeaturedPost extends StatelessWidget {  
  String _council = "SnT";
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            // Map<String, String> value = {COUNCIL : "SnT",index: 0};
            return Scaffold(
              appBar: AppBar(
                title: Text('Featured'),
                actions: [
                  Container(
                    width: 100,
                    margin: EdgeInsets.only(right: 20),
                    child: DropdownButtonFormField(
                      icon: Icon(Entypo.chevron_down),
                      onChanged: (newValue) {
                        print(newValue);
                        _index = newValue;
                        setState(()=> _council = allCouncilData.subCouncil.keys.toList()[newValue]);
                      },
                      items: List.generate(allCouncilData.subCouncil.length,
                        (index) => DropdownMenuItem(
                          child: Tooltip(
                            message: councilNameTOfullForms(allCouncilData.subCouncil.keys.toList()[index]),
                            child: new Text(convertToCouncilName(allCouncilData.subCouncil.keys.toList()[index]))),
                          value: index,
                        )
                      ),
                      isExpanded: false,
                      decoration: InputDecoration(
                        // labelText: 'Council',
                        hintText: 'SnT',
                        hintStyle: TextStyle(
                          color: CustomColors(context).textColor
                        )
                        // isDense: true
                      ),
                      // validator: (String val) =>
                      //   val == null ? 'Entity can\'t be null' : null,
                      // onSaved: (val) => _selectedEntity = val,
                    ),
                  )
                ],
              ),
              body: FutureBuilder(
                future: DBProvider().getAllPostsWithoutPermissions(
                  isFeatured: 1,
                  map: true,
                  council: _council.toLowerCase()
                ),
                builder: (context,AsyncSnapshot<List<Posts>> snapshot) {
                  if (snapshot != null &&
                      snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    print(_council);
                    return snapshot.data.isEmpty ?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(child: Text("No featured post available from ${councilNameTOfullForms(_council)}",
                        textAlign: TextAlign.center,
                      )),
                    )
                    : ListView.builder(
                      itemCount: snapshot.data.length + 1 ?? 0,
                      itemBuilder: (context, int index) {
                       if(index == 0){
                        return Container();
                        }
                        return eventListTiles(context,
                                  snapshot.data??[], index - 1);
                      },
                    );
                    // return Container();
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            );
          }
        ),
      ),
    );
  }
}

Widget eventListTiles(
    BuildContext context, List<Posts> arrayOfPosts, int index) {
      // print(arrayOfPosts);
      // print(index);
  return Card(
    elevation: 5.0,
    margin: index == 0
        ? EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0)
        : EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    child: InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return FeatureDiscovery(
              child: PostDescription(
            listOfPosts: arrayOfPosts,
            type: PostDescType.NOTICE,
            index: 0,
          ));
        }));
      },
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(16.0, 8.0, 40.0, 0.0),
                    child: AutoSizeText(arrayOfPosts[index].sub[0].toString(),
                        //                                  'Science and Texhnology Council',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.blueGrey
                                  : Colors.white70,
                          // fontWeight: FontStyle.italic,
                          fontSize: 10.0,
                        )),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 10.0),
                child: AutoSizeText(arrayOfPosts[index].title,
                    // 'Sit commodo fugiat duis consectetur sunt ipsum cupidatat adipisicing mollit et magna duis.',
                    minFontSize: 15.0,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    )),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 84.0,
                ),
                child: AutoSizeText(
                  arrayOfPosts[index].message,
                  // 'Dolor consectetur in dolore anim reprehenderit velit pariatur veniam nostrud id ex exercitation.',
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.0,
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
                    convertDateToString(DateTime.fromMillisecondsSinceEpoch(
                            arrayOfPosts[index].timeStamp)) +
                        ' at ' +
                        DateFormat("hh:mm a").format(
                            DateTime.fromMillisecondsSinceEpoch(
                                arrayOfPosts[index].timeStamp)),
                    style: TextStyle(
                      fontSize: 8.0,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey
                          : Colors.white70,
                    ),
                  )),
            ],
          ),
        ],
      ),
    ),
  );
}
