import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifier/screens/posts/update/updateposts.dart';
import 'package:notifier/services/databse.dart';
import 'package:notifier/services/function.dart';
abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();
  Future<dynamic> sendPasswordResetEmail(String _email);
  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<dynamic> sendPasswordResetEmail(String _email) async{
     try{
      //  print(_email);
       await _firebaseAuth.sendPasswordResetEmail(email: _email);
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
  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    // if (user.isEmailVerified) {
      return await allData().then((var v){
        return user.uid;
      });
      
    // }else{
    //   Fluttertoast.showToast(msg: 'Please verify account in the link sent to email to begin',
    //   textColor: Colors.red,
    //   backgroundColor: Colors.grey[300]);
    //   return null;
    // }
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    // await user.sendEmailVerification();
    // if (user.isEmailVerified) {
  return user.uid;
// }else{
//   Fluttertoast.showToast(msg: 'Please verify account in the link sent to email to begin',
//   textColor: Colors.red,
//   backgroundColor: Colors.grey[300]);
//   return null;
// }
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    var v=  await deleteContent('users');
    if(update!=null){update.clear();}
    if(docById!=null ){docById.clear();}
    // if(sortedarray != null){sortedarray.clear();}
    if(peopleArr != null){peopleArr.clear();}
    if(jsonData != null){jsonData = null;}
    if(update != null){update.clear();}
    v != null ? print('deletion success'): print('deletefailed');
    var vf = await deleteContent('people');
     vf != null ? print('deletion success'): print('deletefailed');
    // var vh = await deleteContent('snt');
    //  vh != null ? print('deletion success'): print('deletefailed');
     var vhj = await deleteContent('posts');
     vhj != null ? print('deletion success'): print('deletefailed');
    var h = await removeValues();
    h != null ?print('deletion success'): print('deletefailed');
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }
}