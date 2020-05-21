
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/services/beautify_body.dart';

class StudentCard extends StatelessWidget {
  final SearchModel userData;
  final Future<ImageProvider> url;
  StudentCard(this.userData, this.url);
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.brightness == Brightness.dark?
              Colors.blueGrey[800]
              : Colors.blueGrey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // CircleAvatar(
                //     radius: 60.0,
                //     child: (url == null)
                //         ? Image.asset('assets/profilepic.jpg')
                //         : (url.contains('assets/')) ?
                //         Image.asset('assets/profilepic.jpg'):
                //         ClipRRect(
                //             borderRadius: BorderRadius.circular(40),
                //             child: CachedNetworkImage(
                //               imageUrl: url,
                //               errorWidget: (context, string, dy) {
                //                 return Image.asset('assets/profilepic.jpg');
                //               },
                //               progressIndicatorBuilder: (context, st, prog) {
                //                 return Center(
                //                   child: CircularProgressIndicator(),
                //                 );
                //               },
                //             ),
                //           )),
                 CircleAvatar(
                  radius: 60.0,
                  child: FutureBuilder(
                      future: url,
                      builder: (context,AsyncSnapshot<ImageProvider> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            if(snapshot== null || snapshot.data == null || !snapshot.hasData || snapshot.hasError){
                              return ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          // child:Image(image: MemoryImage()));
                          //   }else if (snapshot.data.contains('assets')) {
                          //     return ClipRRect(
                          // borderRadius: BorderRadius.circular(650),
                          child: Image.asset('assets/${userData.gender.toLowerCase()}profile.png'));
                            }
                            else{
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image(image: snapshot.data,
                                fit: BoxFit.fill,
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
                                // ),
                                // child: CachedNetworkImage(
                                //   fit: BoxFit.fill,
                                //   width: 190,
                                //   height: 190,
                                //   imageUrl: snapshot.data,
                                  // errorWidget: (context, string, dy) {
                                  //   return Image(image: snapshot.data);
                                  // },
                                  // progressIndicatorBuilder: (context, st, prog) {
                                  //   return Center(
                                  //     child: CircularProgressIndicator(),
                                  //   );
                                  // },
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
                SizedBox(height: 10.0),
                Text(
                  userData.name,
                  style: TextStyle(fontSize: 20.0,color: Colors.white),
                ),
                SizedBox(height: 5.0),
                Text('(${userData.rollno})',
                style: TextStyle(
                            color:Colors.white
                            // Theme.of(context).appBarTheme.textTheme.title.color,
                            ),),
                SizedBox(height: 5.0),
                Text('${userData.program}, ${userData.dept}',
                style: TextStyle(
                            color:Colors.white
                            // Theme.of(context).appBarTheme.textTheme.title.color,
                            ),),
                SizedBox(height: 3.0),
                Text('${userData.room}, ${userData.hall}',
                style: TextStyle(
                            color:Colors.white
                            // Theme.of(context).appBarTheme.textTheme.title.color,
                            ),),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    Icon(FontAwesome.home,color: Colors.white,),
                    SizedBox(width: 5.0),
                    Text(userData.hometown,
                    style: TextStyle(
                            color:Colors.white
                            // Theme.of(context).appBarTheme.textTheme.title.color,
                            ),),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  children: <Widget>[
                    Icon(Entypo.drop,color: Colors.white,),
                    SizedBox(width: 5.0),
                    Text(userData.bloodGroup,
                    style: TextStyle(
                            color:Colors.white
                            // Theme.of(context).appBarTheme.textTheme.title.color,
                            ),),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  children: <Widget>[
                    Icon(Ionicons.md_mail,color: Colors.white,),
                    SizedBox(width: 5.0),
                    RichText(
                      text: TextSpan(
                        text: '${userData.username}@iitk.ac.in',
                        style: TextStyle(
                            color:Colors.white
                            // Theme.of(context).appBarTheme.textTheme.title.color,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchMail('${userData.username}@iitk.ac.in');
                          },
                      ),
                    ),
                  ],
                ),
                Center(
                  child: IconButton(
                    icon:Icon(
                      Entypo.globe,
                      color: Theme.of(context).brightness == Brightness.dark ?Colors.blue :Colors.blue[900],
                    ),
                    tooltip: 'Homepage', 
                    onPressed: () async{
                      await launchUrl('http://home.iitk.ac.in/~${userData.username}');
                    },
                  ),
                  // child: FlatButton.icon(
                  //     onPressed: () {
                  //       launchUrl(
                  //           'https://home.iitk.ac.in/~${userData.username}');
                  //     },
                  //     icon: Icon(
                  //       Entypo.globe,
                  //       color: Colors.blue,
                  //     ),
                  //     label: Text(
                  //       'HomePage',
                  //       style: TextStyle(
                  //           color: Colors.blue,
                  //           decoration: TextDecoration.underline),
                  //     )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
