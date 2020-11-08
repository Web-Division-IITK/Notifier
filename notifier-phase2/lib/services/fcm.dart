import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:notifier/constants.dart';
import 'package:notifier/database/hive_database.dart';
import 'package:notifier/database/reminder.dart';
import 'package:notifier/main.dart';
import 'package:notifier/model/hive_models/hive_allCouncilData.dart';
import 'package:notifier/model/hive_models/people_hive.dart';
import 'package:notifier/model/posts.dart';
import 'package:notifier/screens/home.dart';
import 'package:notifier/services/database.dart';
import 'package:notifier/services/functions.dart';
import 'package:notifier/widget/showtoast.dart';

Future<dynamic> onMessage(Map<String,dynamic> message){
  print('onMessage' + '$message');
  try{
  Map<String,dynamic> data = message['data']?.cast<String,dynamic>();

  if(data.containsKey(TYPE)){
    switch (data[TYPE]) {
      case NOTF_TYPE_PERMISSION:
        return permissionNotificationHandler(data,message);
        break;
      case NOTF_TYPE_CREATE:
        return createNotificationHandler(data,message);
      break;
      case NOTF_TYPE_DELETE:  
        return deleteNotificationHamdler(data);
      break;
    }
  }
  if(data.containsKey(NOT_FETCHFIELD)
    /*&& data.containsKey(OWNER) && data[OWNER] == id*/ ){
    switch (data[NOT_FETCHFIELD]) {
      /// if people file is updated
      case NOT_FETCHFIELD_PEOPLE:
        return updatePeopleData();
        break;
      /// f suer is updated
      case NOT_FETCHFIELD_SUSER: 
        return updateUser();
    }
  }
  }catch(e){
    print(e);
  }
}

Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) async{
  print('AppPushs myBackgroundMessageHandler : $message');
  try{
  Map<dynamic,dynamic> data = message['data'];
  data = data?.cast<String,dynamic>();
  if(data.containsKey(TYPE)){
    switch (data[TYPE]) {
      case NOTF_TYPE_PERMISSION:
        return permissionNotificationHandler(data,message);
        break;
      case NOTF_TYPE_CREATE:
        return createNotificationHandler(data,message);
      break;
      case NOTF_TYPE_DELETE:  
        return deleteNotificationHamdler(data);
      break;
    }
  }
  if(data.containsKey(NOT_FETCHFIELD)
    /*&& data.containsKey(OWNER) && data[OWNER] == id*/ ){
    switch (data[NOT_FETCHFIELD]) {
      /// if people file is updated
      case NOT_FETCHFIELD_PEOPLE:
        return updatePeopleData();
        break;
      /// f suer is updated
      case NOT_FETCHFIELD_SUSER: 
        return updateUser();
    }
  }
  }catch(e){
    print(e);
  }

  /*if(data['type'] == 'permission'){
      if((ids.contains(id) && 
          allCouncilData.coordOfCouncil.contains(data['council']))
            || allCouncilData.level3.contains(id)){
        print('permission');
          if(data['fetchFF'] == 'true'){
            return await fetchPostFromFirebase(data['id']).then((var data)async{
              if(data!=null){
                data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                if(data.containsKey("startTime")){
                  data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                }
                if(data.containsKey("endTime")){
                  data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                }
                message.update('priority',(v)=>'max',ifAbsent: ()=>'max');
                if(id!="" || id!= null||id.isNotEmpty){
                  await showPermissionNotification(message);
                }
                return await DBProvider().insertPost(postsFromJson(json.encode(data)));
              }
              else{
                // showInfoToast('A request has been published but we are not able to load it,please, load it manually under requested permissions');
                return 1;
              }
            });
          }
          if(data!=null){
            data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
            if(data.containsKey("startTime")){
              data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
            }
            if(data.containsKey("endTime")){
              data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
            }
            message.update('priority',(v)=>'max',ifAbsent: ()=>'max');
            if(id!="" || id!= null||id.isNotEmpty){
                    await showPermissionNotification(message);
                  }
              return await DBProvider().insertPost(postsFromJson(json.encode(data)));
            }
            else{
              // showInfoToast('A request has been published but we are not able to load it,please, load it manually under requested permissions');
              return 1;
            }
      }else{
       return Future<void>.value();
      }
    } 
      else  if(data['type'] == 'delete'){
        // await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(data['id']);
         await DBProvider().deletePost(data['id']);
        }else{
          if(data['fetchFF'] == 'true'){
            return await fetchPostFromFirebase(data['id']).then((data)async{
              if(data!=null){
                data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                if(data.containsKey("startTime")){
                  data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                }
                if(data.containsKey("endTime")){
                  data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                }
                // if(ids.contains(id)) await DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(
                //   PostsFromJson(json.encode(data))
                // );
                await DBProvider().insertPost(postsFromJson(json.encode(data)));
                message.update('priority', (v)=>'max',ifAbsent: ()=>'max');
                if(id!="" || id!= null||id.isNotEmpty){
                    await showNotification(message);
                  }
                
              }else{
                message = {
                  'data': {
                    'timeStamp': DateTime.now().millisecondsSinceEpoch,
                    'priority':'max',
                    'title':'A pending publish request was unable to fetch',
                    'message':'Click to check it out yourself',
                    'sub': 'Notifier',
                  }
                };
              }
            });
          }
          else{
            if(data!=null){
              data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
              if(data.containsKey("startTime")){
                data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
              }
              if(data.containsKey("endTime")){
                data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
              }
              // if((ids.contains(id) && allCouncilData.coordOfCouncil.contains(data['council'])) || allCouncilData.level3.contains(id)){
              //   DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(data['id']);
              // }else if(data['owner'] == id){
              //   DatabaseProvider(databaseName: 'permission',tableName: 'perm').insertPost(PostsFromJson(json.encode(data)));
              // }
              await DBProvider().insertPost(postsFromJson(json.encode(data)));
              if(id!="" || id!= null||id.isNotEmpty){
                    await showNotification(message);
                  }
            }else{
              // message = {
              //   'data': {
              //     'timeStamp': DateTime.now().millisecondsSinceEpoch,
              //     'priority':'max',
              //     'title':'A pending publish request was unable to fetch',
              //     'message':'Click to check it out yourself',
              //     'sub': 'Notifier',
              //   }
              // };
            }
          }
          // globalPostsArray.insert(0,PostsFromJson(json.encode(data)));
        }
    return Future<void>.value();
  }*/ 
}

dynamic updateUser() async{
  print("USER UPDATING FROM NOTIFICATION");
  Box userData = await HiveDatabaseUser().hiveBox;
  if(userData != null && userData.toMap()[0] != null){
    auth.update("id", (value) => userData.toMap()[0]?.id,ifAbsent: () => userData.toMap()[0]?.id,);
    auth.update("uid", (value) => userData.toMap()[0]?.uid,ifAbsent: () => userData.toMap()[0]?.uid,);
  }
  return await populateUsers().then((status)async{
    if(status == true){
      Box userBox = await HiveDatabaseUser().hiveBox;
      if(userBox.isNotEmpty){
        id = userBox.toMap()[0].id;
        admin = userBox.toMap()[0].admin ?? false;
        name = userBox.toMap()[0].name ?? id;
        subscribeUnsubsTopic(userBox.toMap()[0].prefs ?? [], []);
        if(admin == true){
          return await updatePeopleData();
        }else{
          return true;
        }
      }else{
        return false;
      }
    }else{
      return false;
    }
  });
}

dynamic updatePeopleData()async{
  
  print("PEOPLE DATA UPDATING FROM NOTIFICATION");
  Box userData = await HiveDatabaseUser().hiveBox;
  if(userData != null && userData.toMap()[0] != null){
    auth.update("id", (value) => userData.toMap()[0]?.id,ifAbsent: () => userData.toMap()[0]?.id,);
    auth.update("uid", (value) => userData.toMap()[0]?.uid,ifAbsent: () => userData.toMap()[0]?.uid,);
  }
  return await populatePeople(id).then((value)async{
        if(value == true){
          Box peopleBox = await HiveDatabaseUser(databaseName: 'people').hiveBox;
          if(peopleBox.isNotEmpty){
            try {
               PeopleModel model =peopleBox.toMap()[0];
                allCouncilData.coordOfCouncil = model.councils.keys.toList();
                  allCouncilData.subCouncil.forEach((councilName,subCouncil){
                    subCouncil.coordiOfInCouncil = (model.councils[councilName] == null )? 
                      []
                        :model.councils[councilName];
              }); 
              return true; 
            } catch (e) {
              print(e);
              return false;
            }
          }else{
            return false;
          }
        }else{
          return false;
        }
  });
}

dynamic createNotificationHandler(Map<String,dynamic> data, Map<String,dynamic> message)async{
  
  print("NEW NOTIFICATION");
  if(data.containsKey(FETCH_FROM_FF) && data[FETCH_FROM_FF] == 'true'){
    return await fetchPostFromFirebase(data[ID]).then((res) async{
        if(res != null){
          if(res.containsKey(TIMESTAMP))
            res[TIMESTAMP] = (res[TIMESTAMP] is String)? double.parse(res[TIMESTAMP]).round() :res[TIMESTAMP];
          if(res.containsKey(STARTTIME))
            res[STARTTIME] = (res[STARTTIME] is String)? double.parse(res[STARTTIME]).round() :res[STARTTIME];
          if(res.containsKey(ENDTIME))
            res[ENDTIME] = (res[ENDTIME] is String)? double.parse(res[ENDTIME]).round() :res[ENDTIME];
          // if(id!="" || id!= null||id.isNotEmpty)
            await showNotification(message,false);
          return await DBProvider().insertPost(postsFromJson(json.encode(res)));
        }else{
          // if(data.containsKey(TIMESTAMP))
          //   data[TIMESTAMP] = (data[TIMESTAMP] is String)? double.parse(data[TIMESTAMP]).round() :data[TIMESTAMP];
          // if(data.containsKey(STARTTIME))
          //   data[STARTTIME] = (data[STARTTIME] is String)? double.parse(res[STARTTIME]).round() :res[STARTTIME];
          // if(data.containsKey(ENDTIME))
          //   data[ENDTIME] = (data[ENDTIME] is String)? double.parse(data[ENDTIME]).round() :data[ENDTIME];
          // if(id!="" || id!= null||id.isNotEmpty)
          //   await showNotification(message);
          // Posts posts = postsFromJson(json.encode(data));
          // posts.isFetched = false;
          // await DBProvider().insertPost(posts);
          showInfoToast(
            'A request has been published but we are not able to load it,please, refresh it manually under pending approval section');
          return 1;
          }
    });
  }
}

dynamic deleteNotificationHamdler(Map<String,dynamic> data) async{
  print(".....DELETING POST.......");
  try{
    await DatabaseProvider().deletePost(data[ID]);
  return await DBProvider().deletePost(data[ID]);
  }catch(e){
    print("....ERROR WHILE DELETING POSTS.....");
    print(e);
  }
}

dynamic permissionNotificationHandler(Map<String,dynamic> data, Map<String,dynamic> message)async{
  
  print("....PERMISSION NOTIFICATION");
  Box peopleBox = await HiveDatabaseUser(databaseName: 'people').hiveBox;
  Box councilData = await HiveDatabaseUser(databaseName: 'councilData').hiveBox;
  Box userData = await HiveDatabaseUser().hiveBox;
  List<String> _ids = ids??[];
  Councils _allCouncilData = allCouncilData??Councils(level3: [],coordOfCouncil: []);
  _allCouncilData.coordOfCouncil = allCouncilData?.coordOfCouncil ?? [];
  String _id = id??"";
  print(userData.toMap()[0]?.id);
  if(councilData.toMap()[0] != null){
    _allCouncilData = councilData.toMap()[0];
    for (var i in _allCouncilData.subCouncil.values.toList()) {
      _ids+= i.level2;
    }
    PeopleModel model =peopleBox.toMap()[0];
    _allCouncilData.coordOfCouncil = model.councils.keys.toList();
    _id = userData.toMap()[0]?.id;
  }
  print(_ids);
  print(_id);
  print(_allCouncilData?.coordOfCouncil);
  print(_allCouncilData?.level3);
  if((_ids.contains(_id) && _allCouncilData.coordOfCouncil.contains(data[COUNCIL])
    || _allCouncilData.level3.contains(_id))){
      print("...PERMISSION NOTIFICATION ARRIVED.....");
    if(data.containsKey(FETCH_FROM_FF) && data[FETCH_FROM_FF] == 'true'){
      return await fetchPostFromFirebase(data[ID]).then((res) async{
        if(res != null){
          if(res.containsKey(TIMESTAMP))
            res[TIMESTAMP] = (res[TIMESTAMP] is String)? double.parse(res[TIMESTAMP]).round() :res[TIMESTAMP];
          if(res.containsKey(STARTTIME))
            res[STARTTIME] = (res[STARTTIME] is String)? double.parse(res[STARTTIME]).round() :res[STARTTIME];
          if(res.containsKey(ENDTIME))
            res[ENDTIME] = (res[ENDTIME] is String)? double.parse(res[ENDTIME]).round() :res[ENDTIME];
          // if(id!="" || id!= null||id.isNotEmpty)
            await showNotification(message,true);
          print(res);
          return await DBProvider().insertPost(postsFromJson(json.encode(res)));
        }else{
          // if(data.containsKey(TIMESTAMP))
          //   data[TIMESTAMP] = (data[TIMESTAMP] is String)? double.parse(data[TIMESTAMP]).round() :data[TIMESTAMP];
          // if(data.containsKey(STARTTIME))
          //   data[STARTTIME] = (data[STARTTIME] is String)? double.parse(res[STARTTIME]).round() :res[STARTTIME];
          // if(data.containsKey(ENDTIME))
          //   data[ENDTIME] = (data[ENDTIME] is String)? double.parse(data[ENDTIME]).round() :data[ENDTIME];
          // if(id!="" || id!= null||id.isNotEmpty)
          //   await showPermissionNotification(message);
          // Posts posts = postsFromJson(json.encode(data));
          // posts.isFetched = false;
          // await DBProvider().insertPost(posts);
          showInfoToast(
            'A request has been published but we are not able to load it,please, refresh it manually under pending approval section');
          return 1;
          }
      });
    }
  }
}

/*
onMessage: (Map<String, dynamic> message)async{
        print('onMessage' + '$message');
        var data = message['data'];
        print(data['type'] == 'delete');
        if(data['type'] == 'permission'){
          if((ids.contains(id) && 
            allCouncilData.coordOfCouncil.contains(data['council']))
                || allCouncilData.level3.contains(id)){
            print('permission');

           if(data['fetchFF'] == 'true'){
             return await fetchPostFromFirebase(data['id'],collection: 'notification').then((var res)async{
                if(res!=null){
                  res['timeStamp'] = (res['timeStamp'] is String)? double.parse(res['timeStamp']).round() :res['timeStamp'];
                  if(res.containsKey("startTime")){
                    res['startTime'] = (res['startTime'] is String)? double.parse(res['startTime']).round() :res['startTime'];
                  }
                  if(res.containsKey("endTime")){
                    res['endTime'] = (res['endTime'] is String)? double.parse(res['endTime']).round() :res['endTime'];
                  }
                  //  message.update('priority',(v)=>'max',ifAbsent: ()=>'max');
                  if(id!="" || id!= null||id.isNotEmpty){
                    await showPermissionNotification(message);
                  }
                  return await DBProvider().insertPost(postsFromJson(json.encode(data)));
                }
                else{
                  data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                  if(data.containsKey("startTime")){
                    data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                  }
                  if(data.containsKey("endTime")){
                    data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                  }
                  if(id!="" || id!= null||id.isNotEmpty){
                    await showPermissionNotification(message);
                  }

                  await DBProvider().insertPost(postsFromJson(json.encode(data)));
                  showInfoToast('A request has been published but we are not able to load it,please, load it manually under pending approval section');
                  return 1;
                }
              });
           }else{
              data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                  if(data.containsKey("startTime")){
                    data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                  }
                  if(data.containsKey("endTime")){
                    data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                  }
                  //  message.update('priority',(v)=>'max',ifAbsent: ()=>'max');
                  if(id!="" || id!= null||id.isNotEmpty){
                    await showPermissionNotification(message);
                  }
                  
                  return await DBProvider().insertPost(postsFromJson(json.encode(data)));
           }
          }
          print('nothing');
          return;
        }
        else if(data['type'] == 'delete'){
          print('deleting');
          return await DBProvider().deletePost(data['id']);
        }else{
          print('line78');
          if(data['fetchFF'] == 'true'){
            
            return await fetchPostFromFirebase(data['id']).then((var data)async{
              if(data!=null){
                data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
                if(data.containsKey("startTime")){
                  data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
                }
                if(data.containsKey("endTime")){
                  data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
                }
                message.update('priority',(v)=>data['priority'],ifAbsent: ()=>data['priority']);
                if(id!="" || id!= null||id.isNotEmpty){
                  await showNotification(message);
                }
                return await  DBProvider().insertPost(postsFromJson(json.encode(data))).then((v)=>setState((){}));
              }else{
                _newPostStreamController.add(true);
              }
            });
          }
          else{
            data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
            if(data.containsKey("startTime")){
              data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
            }
            if(data.containsKey("endTime")){
              data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
            }
            // }
            print('line80');
            if(id!="" || id!= null||id.isNotEmpty){
              await showNotification(message);
            }
            
              globalPostsArray.add(postsFromJson(json.encode(data)));
            // if(!ids.contains(id) && data['owner'] == id) {
            //   await await DBProvider().newPost(postsFromJson(json.encode(data)));
            // }else{
            //   await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(data['id']);
            // }
            return await  DBProvider().insertPost(postsFromJson(json.encode(data)));
          }
        }
        // return ;
      },

  */
        // else{
        //       data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
        //           if(data.containsKey("startTime")){
        //             data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
        //           }
        //           if(data.containsKey("endTime")){
        //             data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
        //           }
        //           //  message.update('priority',(v)=>'max',ifAbsent: ()=>'max');
        //           if(id!="" || id!= null||id.isNotEmpty){
        //             await showPermissionNotification(message);
        //           }
                  
        //           return await DBProvider().insertPost(postsFromJson(json.encode(data)));
        //    }
        //   }
        //   print('nothing');
        //   return;
        // }
//         else if(data['type'] == 'delete'){
//           print('deleting');
//           return await DBProvider().deletePost(data['id']);
//         }else{
//           print('line78');
//           if(data['fetchFF'] == 'true'){
            
//             return await fetchPostFromFirebase(data['id']).then((var data)async{
//               if(data!=null){
//                 data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
//                 if(data.containsKey("startTime")){
//                   data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
//                 }
//                 if(data.containsKey("endTime")){
//                   data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
//                 }
//                 message.update('priority',(v)=>data['priority'],ifAbsent: ()=>data['priority']);
//                 if(id!="" || id!= null||id.isNotEmpty){
//                   await showNotification(message);
//                 }
//                 return await  DBProvider().insertPost(postsFromJson(json.encode(data))).then((v)=>setState((){}));
//               }else{
//                 _newPostStreamController.add(true);
//               }
//             });
//           }
//           else{
//             data['timeStamp'] = (data['timeStamp'] is String)? double.parse(data['timeStamp']).round() :data['timeStamp'];
//             if(data.containsKey("startTime")){
//               data['startTime'] = (data['startTime'] is String)? double.parse(data['startTime']).round() :data['startTime'];
//             }
//             if(data.containsKey("endTime")){
//               data['endTime'] = (data['endTime'] is String)? double.parse(data['endTime']).round() :data['endTime'];
//             }
//             // }
//             print('line80');
//             if(id!="" || id!= null||id.isNotEmpty){
//               await showNotification(message);
//             }
            
//               globalPostsArray.add(postsFromJson(json.encode(data)));
//             // if(!ids.contains(id) && data['owner'] == id) {
//             //   await await DBProvider().newPost(postsFromJson(json.encode(data)));
//             // }else{
//             //   await DatabaseProvider(databaseName: 'permission',tableName: 'perm').deletePost(data['id']);
//             // }
//             return await  DBProvider().insertPost(postsFromJson(json.encode(data)));
//           }
//         }
//         // return ;
// }