let mongoose = require('mongoose');
const USER = require('./userSchema.js');
const fs=require('fs');

function createUsers(userdata) {
    let promise = new Promise((resolve, reject) => {
        userdata._id=new mongoose.Types.ObjectId()
        let newuser = new USER(userdata)
        newuser.save((err) => {
            if (err) {
                console.log(err)
                reject()
            }
            resolve()
        })
    })
    return promise
}

function getAllStudData(){
    var promiseforcheck = new Promise(function (resolve, reject) {
        var userrecord = USER.find({}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') reject(); else resolve(docs);
        });
    });
    return promiseforcheck;
}

function updateStudData(data){
    var conditions = {roll: data.roll}
    var update = {$set : data}
    var opts = {multi : false}
    var prom = new Promise((resolve, reject) => {
        USER.update(conditions, update, opts, function(err, numAffected){
            resolve();
        })
    })
    return prom;    
}

var url = "mongodb://127.0.0.1:27017/oarsscrap";
let options = {
    useNewUrlParser: true,
    useFindAndModify: false,
    useCreateIndex: true
}
mongoose.connect(url, options, async function (err) {
    let userx = JSON.parse(fs.readFileSync('hexml.json'));
    for(let i=0; i<userx.length; i++){
        await createUsers(userx[i]);
        console.log(userx.length);
    }
    // console.log(await getAllStudData());
})

// async function xx(){
//     let db = await mongoose.connect(url, options);
//     let data = {roll: "10017", hall: "HALL3"};
//     await updateStudData(data);
//     db.disconnect();
// }

// xx();