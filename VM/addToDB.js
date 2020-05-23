let mongoose = require('mongoose');
const USER = require('./userSchema.js');
const fs=require('fs');
let express = require('express');
let bodyParser = require('body-parser');
let cors = require('cors');

let app = express();
app.use(cors());
let router = express.Router();
app.use(bodyParser.json({type: 'application/json'}));
var url = "mongodb://127.0.0.1:27017/oarsscrap";
let options = {
    useNewUrlParser: true,
    useFindAndModify: false,
    useCreateIndex: true
}

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

app.get('/getAllStudents', async (req, res)=>{
    res.json(await getAllStudData());
    res.end();
})

app.post('/updateStudent', async (req, res)=>{
    res.json(await updateStudData(req.body));
    res.end();
})

mongoose.connect(url, options, async function (err) {
    // let userx = JSON.parse(fs.readFileSync('hexml.json'));
    // for(let i=0; i<userx.length; i++) await createUsers(userx[i]);
    app.use('/', router);
    app.listen(port);
    console.log("Connected at: "+port);
})