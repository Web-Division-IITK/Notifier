
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifier/models/user.dart';
import 'package:notifier/services/database.dart';

class AuthService{


  final FirebaseAuth _auth = FirebaseAuth.instance; // to contact with firebse we will use this\

  // create user object based on firebase user
  User _userFromFirebaseUser(FirebaseUser user){
    return user != null ? User(uid: user.uid) : null;
  }
  //auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
      .map(_userFromFirebaseUser);
  }
 
  //sign in anno
  Future signInAnon() async{
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //sign in email and pass
  Future signInWithEmailAndPassword(String email,String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email,password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }
  // reset password
  Future sendPasswordResetEmail(String email) async{
    try{
       await _auth.sendPasswordResetEmail(email: email);
       return true;
    }catch(e){
      print(e);
      if(e.toString() == "PlatformException(ERROR_USER_NOT_FOUND, There is no user record corresponding to this identifier. The user may have been deleted., null)"){
        return "User not Found";
      }
      else if(e.toString() == "PlatformException(ERROR_TOO_MANY_REQUESTS, We have blocked all requests from this device due to unusual activity. Try again later., null)"){
        return "Too many request try again later";
      }

      return "Couldn\'t process at this time try again later";
    }
  }


  //register
   Future registerWithEmailAndPassword(String name,String email,String password) async{
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email,password: password);
      FirebaseUser user = result.user;

      //create anew document with users uid
      // await DatabaseService (uid: user.uid).updateUserData(name, email,);
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }
  //signout
  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}