class User {
  final String uid;
  final String id;
  final bool admin;
  final bool isVerified;

  User({this.uid,this.id,this.admin,this.isVerified});
  
}

// class UserData{
//   final String uid;
//   final bool admin;
//   final String id;
//   // final String password;
//   // final String email;
//   UserData({this.uid,this.admin,this.id});
// }

class UserData{
  final String email;
  final String id;
  final bool admin;
  // final String ;
  final String name;
  final dynamic prefs;
  final String rollno;
  final String uid;
  UserData({this.admin,this.email,this.name,this.rollno,this.id,this.prefs,this.uid});
}