// class Notification{
//   final String title;
//   final String body;
//   Notification(this.title,this.body);
// }

import 'package:notifier/model/posts.dart';

class Res{
  final String uid;
  final int statusCode;
  final dynamic value;
  Res(
    {this.uid,this.statusCode,this.value}
  );
}
// class UpdatePostsFormat{
//   final String uid;
//   final dynamic value;
//   UpdatePostsFormat({
//     this.uid,this.value
//   });
// }
// class SortDateTime{
//   final String uid;
//   final int date;
//  dynamic value;
//   final String club;
//   final String dateasString;
//   SortDateTime(this.uid,this.date,this.value,this.club,this.dateasString);
// }
class PostATC{
  List<String> postsId;
  PostATC({this.postsId});
}

/// class which has parameters to send the  data to send to the inherited Widget
class SendToChildren{
   List<PostsSort> globalPostsArray;
  List<dynamic>prefs;
  // List<Map<String,PostsSort>>globalPostMap;
  // final Function<void> load
  SendToChildren({this.globalPostsArray,this.prefs,/*this.globalPostMap*/});
}