// import 'package:notifier/model/notification.dart';
// import 'package:notifier/model/posts.dart';
// import 'package:scoped_model/scoped_model.dart';

// // class DisplayPosts extends Model{
// //   // List<PostsSort> _globalPostArray;
// //   // dynamic _prefs ;
// //   SendToChildren _sendToChildren = SendToChildren(
// //     globalPostsArray: [],
// //     prefs: [] 
// //   );
// //   // List<PostsSort> get globalPostArray => _globalPostArray;
// //   // dynamic get prefs => _prefs;
// //   SendToChildren get sendToChildren => _sendToChildren;
// //   void updateData(SendToChildren sendToChildren){
// //     _sendToChildren = sendToChildren;
// //     // _globalPostArray = sendToChildren.globalPostsArray;
// //     // _prefs = sendToChildren.prefs;
// //     notifyListeners();
// //   }
// // }
// class DislpayPosts extends DataModel{

// }

import 'package:notifier/model/notification.dart';
import 'package:notifier/model/posts.dart';

class ArrayWithPrefs{
  static SendToChildren sendToChildren;
  void update(SendToChildren _sendToChildren){
    sendToChildren = _sendToChildren;
    // arrayWithPrefs.toList();
    // sort(_sendToChildren.globalPostsArray);

  }
  // void sort(List<PostsSort> globalPostsArray){
  //   globalPostsArray.sort((a,b)=>b.timeStamp.compareTo(a.timeStamp));
  //   sendToChildren.globalPostsArray = globalPostsArray;
  // }
  // void removeofSameType(List<PostsSort> globalPostsArray){
    
  // }
  // ArrayWithPrefs(this.sendToChildren);

  Iterable<PostsSort> get arrayWiths sync*{
    print(sendToChildren.globalPostsArray);
    // print(sendToChildren.prefs);
    for(var i in sendToChildren.globalPostsArray){
      // print(i);
      if(sendToChildren.prefs.contains(i.sub)){
        // print(i);
        yield i;
      }else{
        if(i.reminder == true){
          // DatabaseProvider().deletePost(i.id);
        }
      }
    }
  }

}