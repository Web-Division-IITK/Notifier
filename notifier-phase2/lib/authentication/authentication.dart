import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<String> getCurrentUser();

  Future<void> sendEmailVerification();
  Future<dynamic> sendPasswordResetEmail(String _email);
  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<dynamic> sendPasswordResetEmail(String _email) async{
     try{
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
    try {
      SharedPreferences userId = await SharedPreferences.getInstance();
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
      FirebaseUser user = result.user;
      if (user.isEmailVerified) {
        return await councilData().then((var v)async{
          await userId.setString('userID', user.uid);
          return user.uid;
        });
        
      }else{
        showInfoToast('Please verify your account in the link sent to email to begin');
        await userId.setString('userID', 'notverified');
        return 'notverified';
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> signUp(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
      FirebaseUser user = result.user;
      await user.sendEmailVerification();
      
      // if (user.isEmailVerified) {
      //   return user.uid;
      // }else{
        showInfoToast('Please verify your account in the link sent to email to begin');
        return null;
      //   return 'notverified';
      // }
    } catch (e) {
      print(e);
      showErrorToast(e.message.toString());
      // showInfoToast('Please verify account in the link sent to email to begin');
      return null;
    }
  }

  Future<String> getCurrentUser() async {
    try {
      SharedPreferences userId = await SharedPreferences.getInstance();
      var user = userId.getString('userID');
      return user;
      // FirebaseUser user = await _firebaseAuth.currentUser();
      // // return user;
      // if(user.isEmailVerified){
      //   return user.uid;
      // }else{
      //   return 'notverified';
      // }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    // var v=  await deleteContent('users');
    // v != null ? print('deletion success'): print('deletefailed');
    // var vf = await deleteContent('people');
    //  vf != null ? print('deletion success'): print('deletefailed');
    // var vfk = await deleteContent('allData');
    //  vfk != null ? print('deletion success'): print('deletefailed');
    // var vh = await deleteContent('allPosts');
    //  vh != null ? print('deletion success'): print('deletefailed');
    //  var vhj = await deleteContent('posts');
    //  vhj != null ? print('deletion success'): print('deletefailed');
    try {
      SharedPreferences userId = await SharedPreferences.getInstance();
      await userId.remove('userID');
      return _firebaseAuth.signOut();
    } catch (e) {
      print(e);
    }
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