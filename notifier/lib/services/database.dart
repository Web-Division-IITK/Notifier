import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:notifier/data/data.dart';
import 'package:notifier/models/user.dart';
import 'package:notifier/models/userField.dart';
import 'package:http/http.dart' as http;
import 'package:notifier/screens/home/type1.dart';
import 'package:notifier/shared/function.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:random_string/random_string.dart';
// class TodoItem{
//   String title;
//   bool done;
//   TodoItem({this.title,this.done});
//   toJSONEncodable(){
//     Map<String,dynamic> m= Map();
//     m['title'] = title;
//     m['done'] = done;
//     return m;
    
//   }
// }

class  Storage{

  
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory 
    print(directory.path);
    return directory.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/data.json');
  }

  Future<bool> get existence async{
    final existence = await localFile;
    return existence.exists();
  }

  Future<Map<String,dynamic>> readData() async {
    try {
      final file = await localFile;
      // Read the file
      var content = await file.readAsString();
      var contents = json.decode(content);
      // String contents = await file.readAsString();
      return contents;
    } catch (e) {
      print(e);
      // If there is an error reading, return a default String
      return null;
    }
  }
    Future<File> writeData(String key,dynamic value) async {
    Map<String,dynamic> content = {key:value};
    
    final file = await localFile;
    // Write the file
    
    var jsonContent = await file.readAsString();
    Map<String,dynamic> jsonFileContent = json.decode(jsonContent);
    jsonFileContent.addAll(content);
    return file.writeAsString(json.encode(jsonFileContent));
    // return file.writeAsString(');
  }
}

class DatabaseService {

  final String uid;
  DatabaseService({this.uid});
  //collection reference
  final CollectionReference userField = Firestore.instance.collection("users");
  //user data from snapshots
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot){
    return UserData(
      uid: uid,
      admin: snapshot.data['admin'],
      id: snapshot.data['id'],
      name: snapshot.data['name'],
      rollno: snapshot.data['rollno'],
      prefs: snapshot.data['prefs'],
      email: snapshot.data['email'],
      
      // name: snapshot.data["Name"],
      // email: snapshot.data["Email"],
      // password: snapshot.data["Password"],
    );
  }
  
  Stream<UserData> get userData {
    return userField.document(uid).snapshots()
    .map(_userDataFromSnapshot);
  }
  

}
var arr = [];
final databaseReference = Firestore.instance;
dynamic getData() {
  
  var c =0;
    // selectionDataPeople.length < 3 ?
  // databaseReference
  //     .collection("people")
  //     .getDocuments()
  //     .then((QuerySnapshot snapshot) {
  //   snapshot.documents.forEach((f){
  //     //  print('${f.data['id']}');
  //     checkPresent(f.data['id']) ? null :
  //      selectionDataPeople.add(f.data['id']);
    
  // });
  databaseReference.collection('people').getDocuments().then((QuerySnapshot snapshot){
    snapshot.documents.forEach((f){
      print(json.encode(f.data));
      
      arr.add((f.data));
      print(arr.length.toString() + c.toString() + 'hkj');
    });
  }).whenComplete(( ){
    // writeContent('people', arr)
    for(var i in arr){
      if(!selectionDataPeople.contains(i)){
    selectionDataPeople.add(i['id']);
      }
  }
  print(selectionDataPeople);
  });
  // c+=1;
  // print(c);
  return  selectionDataPeople;
 
}
void updateInFireBase(String uid,var prefs){
  databaseReference.collection('users').document(uid).updateData({'prefs': prefs});
}

// class SelectionController {
  void submit(String id, var value) async{
    Map<String, String> headers = {"Content-type": "application/json"};
    value = jsonEncode(value);
  String json = '{"id": "$id","sub":$value}';
  // print(json);
    // try{
   String url = 'https://us-central1-notifier-snt.cloudfunctions.net/elevatePerson';
  // //   // }catch(e){
  // //   //   print(e.toString());
  // //   // }
    Response response = await post(url, headers: headers, body: json);
    int statusCode = response.statusCode;
    print(statusCode);
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