import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:notifier/models/user.dart';
import 'package:notifier/models/userField.dart';
import 'package:http/http.dart' as http;
// import 'package:random_string/random_string.dart';



class DatabaseService {

  final String uid;
  DatabaseService({this.uid});
  //collection reference
  final CollectionReference userField = Firestore.instance.collection("users");

  // Future updateUserData (List<String> positions) async{
  //   return await userField.document(uid).setData({
  //     // 'Name' : name,
  //     // 'Email': email,
  //     // 'Password' : randomString(15),
     
  //   }); //create and link document with uid
  // }
  
  //name from snapshot
  // List<SNTUser> _nameEmailFromSnapshot(QuerySnapshot snapshot){
  //   return snapshot.documents.map((doc){
  //     return SNTUser(
  //       name : doc.data["Name"] ?? "Not Found",
  //       email: doc.data["Email"] ?? "Not FOUND",
  //       password: doc.data["Password"] ?? "Not Found",
  //     );
  //   }).toList();
  // }

  //user data from snapshots

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot){
    return UserData(
      uid: uid,
      admin: snapshot.data['admin'],
      id: snapshot.data['id'],
      // name: snapshot.data["Name"],
      // email: snapshot.data["Email"],
      // password: snapshot.data["Password"],
    );
  }
  //stream
  // Stream<List<SNTUser>> get eclubIITK{
  //   return userField.snapshots()
  //   .map(_nameEmailFromSnapshot);
  // }

  //get user doc sstream
  Stream<UserData> get userData {
    return userField.document(uid).snapshots()
    .map(_userDataFromSnapshot);
  }

}

// class SelectionController {
  void submit(String id, var value) async{
    Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"id": "$id","sub":$value}';
  print(json);
    // try{
  //  String url = 'https://us-central1-notifier-snt.cloudfunctions.net/elevatePerson';
  //   // }catch(e){
  //   //   print(e.toString());
  //   // }
  //   Response response = await post(url, headers: headers, body: json);
  //   int statusCode = response.statusCode;
  //   print(statusCode);
  // this API passes back the id of the new item added to the body
  // String body = response.body;
  // {
  //   "title": "Hello",
  //   "body": "body text",
  //   "userId": 1,
  //   "id": 101
  // }
  }
// }