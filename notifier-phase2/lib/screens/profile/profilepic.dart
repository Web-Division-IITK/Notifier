import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:notifier/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';


class UserProfilePic {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  SharedPreferences profilePicName;
  final SearchModel user;
  UserProfilePic(this.user);
  static String pic_name = 'pic_name';
  Future<dynamic> getUserProfilePic() async {
    profilePicName = await SharedPreferences.getInstance();
    try {
      String ima = profilePicName.getString(pic_name);
      if(!ima.contains('${user.rollno}')){
        ima= null;
      }
      File pic = await file(ima??'${user.rollno}.jpg');
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
          return this._memoizer.runOnce(()async{
            // try {
            //   String url = 'http://home.iitk.ac.in/~${user.username}/dp';
            //   Response res = await get(url);
            //   String format = '.jpg';
            //   if(res.statusCode == 200 && res.bodyBytes.isNotEmpty){
            //     format = res.headers['content-location'].replaceAll('dp', '');
            //     profilePicName.setString(pic_name, '${user.rollno}$format');
            //     pic = await file('${user.rollno}$format');
            //     pic.createSync();
            //     pic.writeAsBytesSync(res.bodyBytes);
            //     return MemoryImage(res.bodyBytes);
            //   }
            // } catch (e) {
            //   print(e);
            // }
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