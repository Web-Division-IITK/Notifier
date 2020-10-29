import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';


class ProfilePic{
  SharedPreferences _profilePicName;
  /// user whose profile pic is needed
  final SearchModel user;
  ProfilePic(this.user);
  
  /// first try to fetch image from directory and if not found
  /// calls `getSavedProfilePic` function
  Future<ImageProvider> getProfilePic() async{
    try{
      _profilePicName = await SharedPreferences.getInstance();
      Response res = await get(directoryProfileUrl(user.username));
      print("RESPONSE STATUS CODE - ${res.statusCode}" );
      if(res != null && res.statusCode == 200 && res.bodyBytes != null &&  res.bodyBytes.isNotEmpty){
          // format = res.headers['content-location'].replaceAll('dp', '');\
          if(user.username == id){
            String format = '.jpg';
            format = res.headers['content-location'].replaceAll('dp', '');
            _profilePicName.setString(PICNAME, '${user.rollno}$format');
            File pic = await file('${user.rollno}$format');
            pic.createSync();
            pic.writeAsBytesSync(res.bodyBytes);
          }
        return MemoryImage(res.bodyBytes);
      }else {
        return await getSavedProfilePic();
      }
    }catch(e){
      print("ERROR IN FUNCTION getProfilePic");
      print(e);
      return await getSavedProfilePic();
    }
  }
  /// first tries to get image from storage and if not found calls
  /// `getOarsProfile` function
  Future<ImageProvider> getSavedProfilePic()async{
    String picName = '';
    try{
      picName = _profilePicName.getString(PICNAME);
      if(picName != null && !picName.contains(user.rollno)){
        picName = null;
      }
      File pic = await file(picName??'${user.rollno}.jpg');
      print(pic);
      return await pic.exists().then((exists) async{
        print("PROFILE PIC EXISTS : $exists");
        if(exists == true){
          return MemoryImage(pic.readAsBytesSync());
        }else{
          return await getOarsProfile(picName);
        }
      });
    }catch(e){
      print("ERROR WHILE FETCHING PIC FROM STORAGE");
      print(e);
      return await getOarsProfile(picName);
    }
  }

  /// fetches image from oars and saves it locally
  Future<ImageProvider> getOarsProfile(String picName) async {
    try{
      Response res = await get(oarsProfileUrl(user.rollno));
      print("RESPONSE STATUS CODE - ${res.statusCode}" );
      if(res != null && res.statusCode == 200 && res.bodyBytes != null && res.bodyBytes.isNotEmpty){
        File pic = await file(picName??'${user.rollno}.jpg');
        pic.createSync();
        pic.writeAsBytesSync(res.bodyBytes);
        return MemoryImage(res.bodyBytes);
      }else{
        return AssetImage(defaultProfileUrl(user.gender));
      }
    }catch(e){
      print("ERROR IN FUNCTION getOarsProfile");
      print(e);
      return AssetImage(defaultProfileUrl(user.gender));
    }
  }
}


class UserProfilePic {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  SharedPreferences _profilePicName;
  final SearchModel user;
  UserProfilePic(this.user);
  // static String pic_name = 'pic_name';
  Future getUserProfilePic() async{
    String picName = '';
    try{
      _profilePicName = await SharedPreferences.getInstance();
      picName = _profilePicName.getString(PICNAME);
      if(picName != null && !picName.contains(user.rollno)){
        picName = null;
      }
      File pic = await file(picName??'${user.rollno}.jpg');
      print(pic);
      return await pic.exists().then((exists) async{
        print("PROFILE PIC EXISTS : $exists");
        if(exists == true){
          return MemoryImage(pic.readAsBytesSync());
        }else{
          return await getDirectoryProfilePic();
        }
      });
    }catch(e){
      print("ERROR IN FUNCTION getUserProfilePic");
      print(e);
      return await getDirectoryProfilePic();
    }
  }

  Future<bool> getDirectoryProfilePic()async{
    String picName = '';
    try{
      _profilePicName = await SharedPreferences.getInstance();
      picName = _profilePicName.getString(PICNAME);
      if(picName != null && !picName.contains(user.rollno)){
        picName = null;
      }
      print('FETCHING DIRECTORY PROFILE .....');
      print(directoryProfileUrl(user.username));
      Response res = await get(directoryProfileUrl(user.username));
      print("RESPONSE STATUS CODE - ${res.statusCode}" );
      if(res != null && res.statusCode == 200 && res.bodyBytes != null &&  res.bodyBytes.isNotEmpty){
        String format = '.jpg';
        format = res.headers['content-location'].replaceAll('dp', '');
        _profilePicName.setString(PICNAME, '${user.rollno}$format');
        File pic = await file('${user.rollno}$format');
        pic.createSync();
        pic.writeAsBytesSync(res.bodyBytes);
        return true;
      }else {
        return await getOarsProfilePic(picName);
      }
    }catch(e){
      print("ERROR IN FUNCTION getDirectoryProfilePic");
      print(e);
      return await getOarsProfilePic(picName);
    }
  }

  /// fetches image from oars and saves it locally
  Future<bool> getOarsProfilePic(String picName) async {
    try{
      print('FETCHING OARS PROFILE .....');
      print(oarsProfileUrl(user.rollno));
      Response res = await get(oarsProfileUrl(user.rollno));
      print("RESPONSE STATUS CODE - ${res.statusCode}" );
      if(res != null && res.statusCode == 200 && res.bodyBytes != null && res.bodyBytes.isNotEmpty){
        File pic = await file(picName??'${user.rollno}.jpg');
        pic.createSync();
        pic.writeAsBytesSync(res.bodyBytes);
        return true;
      }else{
        return false;
      }
    }catch(e){
      print("ERROR IN FUNCTION getOarsProfilePic");
      print(e);
      return false;
    }
  }
  /*
  Future<dynamic> getUserProfilePic() async {
    profilePicName = await SharedPreferences.getInstance();
    try {
      String ima = profilePicName.getString(PICNAME);
      if(!ima.contains('${user.rollno}')){
        ima= null;
      }
      File pic = await file(ima??'${user.rollno}.jpg');
      print(pic);
          return this._memoizer.runOnce(()async{
            try {
              return await pic.exists().then((exists)async{
                if(exists == true){
                  return MemoryImage(pic.readAsBytesSync());
                }else{
                  try {
                    String url = 'http://home.iitk.ac.in/~${user.username}/dp';
                    Response res = await get(url);
                    String format = '.jpg';
                    if(res.statusCode == 200){
                      format = res.headers['content-location'].replaceAll('dp', '');
                      profilePicName.setString(pic_name, '${user.rollno}$format');
                      pic = await file('${user.rollno}$format');
                      pic.createSync();
                      pic.writeAsBytesSync(res.bodyBytes);
                      return MemoryImage(res.bodyBytes);
                    }else{
                      String url1 =
                        'https://oa.cc.iitk.ac.in:443/Oa/Jsp/Photo/${user.rollno}_0.jpg';
                      Response res = await get(url1);
                      if(res.statusCode == 200){
                        pic = await file('${user.rollno}.jpg');
                        pic.createSync();
                        pic.writeAsBytesSync(res.bodyBytes);
                        return MemoryImage(res.bodyBytes);
                      }else{
                        return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
                      }
                    }
                  } catch (e) {
                    print(e);
                    return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
                  }
                }
              });
            } catch (e) {
              print(e);
              return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
            }
          });
      
    } catch (e) {
      print(e);
      return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
    }
  }*/
}
/*
class ProfilePic {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  SharedPreferences profilePicName;
  final SearchModel user;
  
  ProfilePic(this.user);
  Future<dynamic>getUserProfilePic()async{
    // profilePicName = await SharedPreferences.getInstance();
    try {
      // String ima = profilePicName.getString('pic_name');
      File pic = await file('${user.rollno}.jpg');
      print(pic);
      // Connectivity().onConnectivityChanged.listen((event) {ConnectivityCheck().connection.listen((data){
      //   print('connectivity result $data');
      // });});
      // return await Connectivity().checkConnectivity().then((connectivityResult)async{
      //   // try {
      //     if(connectivityResult == ConnectivityResult.none){
      //       return await pic.exists().then((exists)async{
      //           if(exists == true){
      //             return MemoryImage(pic.readAsBytesSync());
      //           }else{
      //             return AssetImage('assets//${user.gender.toLowerCase()}profile.png');
      //           }
      //       });
      //     }
          // return this._memoizer.runOnce(()async{
            try {
              String url = 'http://home.iitk.ac.in/~${user.username}/dp';
              Response res = await get(url);
              String format = '.jpg';
              if(res.statusCode == 200 && res.bodyBytes.isNotEmpty){
                format = res.headers['content-location'].replaceAll('dp', '');
                // profilePicName.setString('pic_name', '${user.rollno}$format');
                // pic = await file('${user.rollno}$format');
                // pic.createSync();
                // pic.writeAsBytesSync(res.bodyBytes);
                return MemoryImage(res.bodyBytes);
              }
            } catch (e) {
              print(e);
            }
            try {
              return await pic.exists().then((exists)async{
                if(exists == true){
                  return MemoryImage(pic.readAsBytesSync());
                }else{
                  try {
                    String url = 'http://home.iitk.ac.in/~${user.username}/dp';
                    Response res = await get(url);
                    String format = '.jpg';
                    if(res.statusCode == 200){
                      format = res.headers['content-location'].replaceAll('dp', '');
                      // profilePicName.setString('pic_name', '${user.rollno}$format');
                      // pic = await file('${user.rollno}$format');
                      // pic.createSync();
                      // pic.writeAsBytesSync(res.bodyBytes);
                      return MemoryImage(res.bodyBytes);
                    }else{
                      String url1 =
                        'https://oa.cc.iitk.ac.in:443/Oa/Jsp/Photo/${user.rollno}_0.jpg';
                      Response res = await get(url1);
                      if(res.statusCode == 200){
                        pic = await file('${user.rollno}.jpg');
                        pic.createSync();
                        pic.writeAsBytesSync(res.bodyBytes);
                        return MemoryImage(res.bodyBytes);
                      }else{
                        return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
                      }
                    }
                  } catch (e) {
                    print(e);
                    return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
                  }
                }
              });
            } catch (e) {
              print(e);
              return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
            }
          // });
        // } catch (e) {
        //   print(e);
        //   return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
        // }
      // }).catchError((onError){
      //   print(onError);
      //   return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
      // });
      
    } catch (e) {
      print(e);
      return AssetImage('assets/${user.gender.toLowerCase()}profile.png');
    }
  }
}
*/
class ConnectivityCheck {
  static final StreamController connectionStream = StreamController.broadcast();
  bool status = false;
  checkNetwork() async{
    try {
      await get('https://google.com')
      .then((value) {
        if(status!= true){
          status = true;
          addValue(true);
        }
      })
      .catchError((onError){
        print(onError);
        if(status!= false){
          status = false;
          addValue(false);
        }
      });
      
    } on SocketException catch (e) {
        if(status!= false){
          status = false;
          addValue(false);
        }
        print(e);
    }

  }

  Stream get connection => connectionStream.stream;
  addValue(data) => connectionStream.add(data);

  disposeStream() => connectionStream.close();
}