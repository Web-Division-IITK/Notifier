import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/services/beautify_body.dart';

class StudentCard extends StatelessWidget {
  final SearchModel userData;
  final Future<String> url;
  StudentCard(this.userData, this.url);
  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            if(snapshot== null || snapshot.data == null || !snapshot.hasData){
                              return ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.asset('assets/profilepic.jpg'));
                            }else if (snapshot.data.contains('assets')) {
                              return ClipRRect(
                          borderRadius: BorderRadius.circular(650),
                          child: Image.asset('assets/profilepic.jpg'));
                            }
                            else{
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(60),
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
                SizedBox(height: 5.0),
                Text(
                  userData.name,
                  style: TextStyle(fontSize: 20.0),
                ),
                Text('(${userData.rollno})'),
                Text('${userData.program}, ${userData.dept}'),
                SizedBox(height: 3.0),
                Text('${userData.room}, ${userData.hall}'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 5.0),
                Row(
                  children: <Widget>[
                    Icon(FontAwesome.home),
                    SizedBox(width: 5.0),
                    Text(userData.hometown),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  children: <Widget>[
                    Icon(Entypo.drop),
                    SizedBox(width: 5.0),
                    Text(userData.bloodGroup),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  children: <Widget>[
                    Icon(Ionicons.md_mail),
                    SizedBox(width: 5.0),
                    RichText(
                      text: TextSpan(
                        text: '${userData.username}@iitk.ac.in',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // _service.sendEmail(b[0]);
                            launchMail('${userData.username}@iitk.ac.in');
                          },
                      ),
                    ),
                  ],
                ),
                Center(
                  child: FlatButton.icon(
                      onPressed: () {
                        launchUrl(
                            'https://home.iitk.ac.in/~${userData.username}');
                      },
                      icon: Icon(
                        Entypo.globe,
                        color: Colors.blue,
                      ),
                      label: Text(
                        'HomePage',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
