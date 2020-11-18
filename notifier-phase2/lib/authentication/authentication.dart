import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/database/student_search.dart';
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
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<dynamic> sendPasswordResetEmail(String _email) async{
     try{
       await _firebaseAuth.sendPasswordResetEmail(email: _email);
       return true;
    }catch(e){
      print(e);
      if(e.code.toString() == "ERROR_USER_NOT_FOUND"){
        return "This account is not registered with us!!!";
      }
      else if(e.code.toString() == "ERROR_TOO_MANY_REQUESTS"){
        return "Too many request!!! Please try again later!!!";
      }

      return "Couldn\'t process your request at this time!!! Please try again later";
    }
  }
  Future<String> signIn(String email, String password) async {
    try {
      SharedPreferences userId = await SharedPreferences.getInstance();
      // AuthResult 
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password).timeout((Duration(seconds: 20)));
        User user = result.user;
      if (user.emailVerified) {
        _fcm.getToken().then((value)async{
          print('DEVICE TOKEN IS: $value');
          try{
            Response res = await post(SEND_DEVICE_TOKEN,headers:HEADERS, body: json.encode({
              "auth": {"id": user.email.replaceAll("@iitk.ac.in", ""),
               "uid": user.uid},
              "deviceid": value,
            }));
            print("....RESPONSE STATUSCODE FOR DEVICE TOKEN..... ${res.statusCode}");
            print("...RESPONSE BODY.... ${res.body}");

          }catch(e){
            print(e);
          }
        });
        return await councilData().then((var v)async{
          
          await userId.setString(USERID, user.uid);
          return user.uid;
        });
        
      }else{
        showInfoToast('Please verify your account in the link sent to email to begin');
        await userId.setString(USERID, NOT_VERIFIED);
        return NOT_VERIFIED;
      }
    }on FirebaseException catch (e) {
      print(e);
      switch(e?.code.toString()){
        case 'ERROR_WRONG_PASSWORD': showErrorToast("Wrong credentials ");
        return null;
        case 'ERROR_INVALID_EMAIL': showErrorToast("Provided email doesn't looks like an email");
        return null;
        case 'ERROR_USER_NOT_FOUND': showErrorToast("This account is not registered with us!!! Try creating one !!!");
        return null;
        // case 'ERROR_USER_DISABLED': showErrorToast("This account is currently blocked!!! Try contacting the admin to re-activate");
        // return null; TODO
        case 'ERROR_TOO_MANY_REQUESTS': showErrorToast("Too many requests have been received from your side!!! Please try again later");
        return null;
        default: showErrorToast("Something went wrong !!! Please try again !!!");
        return null;
      }
      // return null;
    } catch(e){
      print(e);
      showErrorToast("Something went wrong !!! Please try again !!!");
      return null;
    }
  }

  Future<String> signUp(String email, String password) async {
    final url = CREATE_USERDATA_API;
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password).timeout(Duration(seconds: 30));
      User user = result.user;
      await user.sendEmailVerification();
      final values = json.encode({"uid": user.uid,"email": email});
      try{
        Response res = await post(url,headers: HEADERS,body: values);
        print("RESPONSE STATUSCODE - " + res.statusCode.toString());
        print(res.body);
        if(res.statusCode == 200)
          print("CREATED USER DATA SUCCESSFULLY!!");
        else print("SOMETHING WENT WRONG WHILE CREATING USERDATA !!!");
      }
      catch(e) {
        print("$e || ERROR WHILE CREATING USERDATA !!!");
      }
        showInfoToast('Please verify your account in the link sent to email to begin');
        return null; 
    }on FirebaseException catch (e) {
      print(e.toString() + 'catch2');
      switch(e.code){
        case 'ERROR_WEAK_PASSWORD': showErrorToast("Please provide a more strong password with upto 6 charachters");
        return null;
        case 'ERROR_INVALID_EMAIL': showErrorToast("Provided email doesn't looks like an email");
        return null;
        case 'ERROR_EMAIL_ALREADY_IN_USE': showErrorToast("This account is already registered with us!!! Try signing in !!!");
        return null;
        default: showErrorToast("Something went wrong !!! Please try again !!!");
        return null;
      }
    }catch(e){
      print(e);
      showErrorToast("Something went wrong !!! Please try again !!!");
      return null;
    }
  }

  Future<String> getCurrentUser() async {
    try {
      SharedPreferences userId = await SharedPreferences.getInstance();
      var user = userId.getString(USERID);
      return user;
      // FirebaseUser user = await _firebaseAuth.currentUser();
      // // return user;
      // if(user.isEmailVerified){
      //   return user.uid;
      // }else{
      //   return NOT_VERIFIED;
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
      await userId.remove(USERID);
      return _firebaseAuth.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendEmailVerification() {
    User user = _firebaseAuth.currentUser;
    return user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }
}