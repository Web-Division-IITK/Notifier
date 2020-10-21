import 'package:hive/hive.dart';
import 'package:notifier/model/hive_models/hive_allCouncilData.dart';
import 'package:notifier/model/hive_models/hive_model.dart';
import 'package:notifier/model/hive_models/people_hive.dart';
import 'package:notifier/model/hive_models/ss_model.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:hive/hive.dart';
/// don't forget to include null also
class HiveDatabaseUser{
  final String databaseName;
  HiveDatabaseUser({this.databaseName = 'users',});
  // final dir = await getApplicationDocumentsDirectory();

  static Box _userBox;
  static Box _peopleBox;
  static Box _councilBox;
  static Box _studSearch;
  Future<Box> initHive()async{
    // if(getBoxWithDatabase() == null){
    //   return null;
    // }
    
    switch (databaseName) {
      case 'users':
        Hive.registerAdapter(UserModelAdapter());
        break;
      case 'people':
        Hive.registerAdapter(PeopleModelAdapter());
      break;
      case 'councilData':
         Hive.registerAdapter(CouncilsAdapter());
         Hive.registerAdapter(SubCouncilAdapter());
         break;
      case 'ss':
        Hive.registerAdapter(SearchModelAdapter());
        break;
      default:Hive.registerAdapter(UserModelAdapter());
      
        break;
    }
    
    
   
    return await _openBox();
  }
  Future _openBox() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    if(databaseName == 'users'){
      _userBox = await Hive.openBox(databaseName);
       return _userBox;
    }else if(databaseName == 'people'){
      _peopleBox = await Hive.openBox(databaseName);
       return _peopleBox;
    }else if(databaseName == 'councilData'){
      _councilBox = await Hive.openBox(databaseName);
       return _councilBox;
    }else if(databaseName == 'ss'){
      _studSearch = await Hive.openBox(databaseName);
    }else{
      return null;
    }
   
  }
  Box getBoxWithDatabase(){
    switch (databaseName) {
      case 'users': return _userBox;
        break;
      case 'people':return _peopleBox;
      break;
      case 'councilData' :return _councilBox;
      break;
      case 'ss':  return _studSearch;
      break;
      default: return null;
    }
  }
  
  Future deleteBox() async{
    getBoxWithDatabase().deleteAll(getBoxWithDatabase().keys);
  }
  Future deleteAllBoxes() async{
    try {
      // _userBox.deleteAll(_userBox.keys);
      _userBox.clear();
      // _userBox.deleteFromDisk();
      // _userBox = null;
    } catch (e) {
      print(e);
      return false;
    }
    try {
      _peopleBox.clear();
      // _peopleBox.deleteFromDisk();
      // _peopleBox = null;
    } catch (e) {
      print(e);
      return false;
    }
    try {
      _councilBox.clear();
      // _councilBox.deleteFromDisk();
      // _councilBox = null;
    } catch (e) {
      print(e);
      return false;
    }
  }
  
  /// returns null or box
  Future<Box> get hiveBox async{
    Box box = getBoxWithDatabase();
    print('$box name of box');
    if(box != null){
        return box;
      }
    return box = await initHive();
  }
}