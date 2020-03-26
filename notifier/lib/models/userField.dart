class SNTUser {
  final String name;
  final String email;
  final String password;
  SNTUser({this.name,this.email,this.password});
}


// class Profile{
//   final String email;
//   final String id;
//   final String admin;
//   // final String ;
//   final String name;
//   final prefs;
//   final String rollno;
//   final String uid;
//   Profile({this.admin,this.email,this.name,this.rollno,this.id,this.prefs,this.uid});
// }

class Profile{
  final String key;
  final dynamic value;
  Profile(this.key,this.value);
}