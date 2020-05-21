import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection;
class DBConnection {

  static DBConnection _instance;
  final String url = "mongodb+srv://webdivision:webdivision@cluster0-ke6fc.mongodb.net/studdata?retryWrites=true&w=majority";
  final String _dbName = "studdata";
  final String collection = "users";
  Db _db;
  // static DbCollection _dbCollection;
  static getInstance(){
    if(_instance == null) {
      _instance = DBConnection();
    }
    return _instance;
  }

  Future<Db> getConnection() async{
    if (_db == null){
      try {
        _db =
        //  Db(
        //   // "mongodb://webdivision:webdivision@cluster0-shard-00-00-ke6fc.mongodb.net:27017,,cluster0-shard-00-02-ke6fc.mongodb.net:27017/studdata?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin&retryWrites=true&w=majority"
        //  );
          //  "mongodb://webdivision:webdivision@cluster0-ke6fc.mongodb.net/studdata?ssl=true&retryWrites=true&w=majority");
        new Db.pool([
          "mongodb://webdivision:webdivision@cluster0-shard-00-00-ke6fc.mongodb.net:27017/studdata?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin&retryWrites=true&w=majority",
          "mongodb://webdivision:webdivision@cluster0-shard-00-01-ke6fc.mongodb.net:27017/studdata?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin&retryWrites=true&w=majority",
          "mongodb://webdivision:webdivision@cluster0-shard-00-02-ke6fc.mongodb.net:27017/studdata?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin&retryWrites=true&w=majority"
        ]);
        await _db.open(secure: true);
        print(_db);
        // await _db.open();
        // return _db.collection('users');
      } catch(e){
        print(e);
      }
    }
    return _db;
  }

  // _getConnectionString(){
  //   return url;
  // }

  closeConnection() {
    _db.close();
  }

}