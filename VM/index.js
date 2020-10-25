const { v4: uuidv4 } = require('uuid');

let mongoose = require('mongoose');
const USER = require('./schema/userSchema.js');
const POST = require('./schema/postSchema.js');
const PEOPLE = require('./schema/peopleSchema.js');
const SUSER = require('./schema/suserSchema.js');
const fs=require('fs');
let express = require('express');
let bodyParser = require('body-parser');
let cors = require('cors');
var admin = require("firebase-admin");
let structure=JSON.parse(fs.readFileSync('./static/data.json'));
let serviceAccount=JSON.parse(fs.readFileSync('fbase-creds.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://notifier-phase-2.firebaseio.com"
});

var fcm = admin.messaging();
var auth = admin.auth();
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
app.use('/', express.static('static'));
var port = 8080;
port = process.env.PORT;
if (port == null || port == "") {port = 8080};

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

async function approveDef(id, uid){
    let fetchDoc = new Promise(function (resolve, reject) {
        SUSER.find({id, uid}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve(false); else resolve(true);
        });
    });
    return fetchDoc;
}

async function validatePost(data){
    if(!structure.councils.includes(data.council)) return false;
    let mentity = structure[data.council].entity.concat(structure[data.council].misc);
    let k = false;
    await data.sub.forEach((element) => {
        if(mentity.includes(element)) k=true;
    });
    if(!k) return false;
    return true;
}

async function postingVerification(data){
    let k = approveDef(data.auth.id, data.auth.uid);
    if(!k) return false;
    if(structure.level3.includes(data.auth.id)) return true;
    if(structure[data.council].level2.includes(data.auth.id)) return true;
    let fetchDoc = new Promise(function (resolve, reject) {
        PEOPLE.find({id: data.auth.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') {k=false; resolve({});} else resolve(docs[0]);
        });
    });
    let peepRec = await fetchDoc;
    if(!k) return false;
    if(!peepRec.councils.includes(data.council)) return false;
    if(!peepRec[data.council].includes(data.sub[0])) return false;
    return true;
}

async function deletionVerification(data){
    let k = approveDef(data.auth.id, data.auth.uid);
    if(!k) return false;
    if(data.owner != data.auth.id) return false;
    if(structure.level3.includes(data.auth.id)) return true;
    if(structure[data.council].level2.includes(data.auth.id)) return true;
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({owner: data.auth.id, id: data.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') {k=false; resolve({});} else resolve(docs[0]);
        });
    });
    let postRec = await fetchDoc;
    if(!k) return false;
    return true;
}

async function authVerify(data){
    let userRec = await auth.getUser(data.uid);
    userRec = userRec.toJSON();
    if(userRec.email != data.email) return false;
    return true;
}

async function elevationVerify(data){
    let k = approveDef(data.auth.id, data.auth.uid);
    if(!k) return false;
    if(structure.level3.includes(data.auth.id)) return true;
    if(structure[data.council].level2.includes(data.auth.id)) return true;
    return false;
}

async function verifyApproval(data){
    if(!approveDef(data.auth.id, data.auth.uid)) return false;
    if(structure.level3.includes(data.auth.id)) return true;
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({id: data.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') reject(); else resolve(docs[0]);
        });
    });
    let postDoc = await fetchDoc;
    if(structure[postDoc.council].level2.includes(data.auth.id)) return true;
    return false;
}

async function sendToTopicUpdate(id){
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') reject(); else resolve(docs[0]);
        });
    });
    let data = await fetchDoc;
    let sub = data.sub;
    if(data.message.length > 1000) return;
    let payload = {
        data: {
            owner: data.owner,
            title: data.title,
            council: data.council,
            fetchFF: 'true',
            message: data.message,
            type: data.type,
            notfID: data.notfID.toString(), // id of notification in integer
            id: data.id,
            sub: data.sub[0],
            priority: "",
            tags: "",
            body: "",
            author: "",
            url: "",
            startTime: "",
            endTime: "",
            timeStamp: ""
        }
    }
    await sub.forEach(async (element) => {
        payload["topic"] = element.replace(/ /g, '_');
        await fcm.send(payload);
    });
}

async function sendToTopicDelete(id, owner, sub){
    let payload = {
        data: {
            timeStamp: Date.now().toString(),
            type: "delete",
            notfID: Date.now().toString(),
            id, owner
        }
    };
    await sub.forEach(async (element) => {
        payload["topic"] = element.replace(/ /g, '_');
        await fcm.send(payload);
    });
}

async function getSuser(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        SUSER.find({id: data.auth.id, uid: data.auth.uid}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve(false); else resolve(docs[0]);
        });
    });
    return fetchDoc;
}

async function getPeople(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        PEOPLE.find({id: data.auth.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve(false); else resolve(docs[0]);
        });
    });
    return fetchDoc;
}

async function makePost(data){
    let notfID = Date.now();
    let datax = {
        "title": data.title,
        "tags": data.tags,
        "council": data.council,
        "sub": data.sub,
        "body": data.body,
        "author": data.author,
        "url": data.url,
        "priority": data.priority,
        "owner": data.owner,
        "message": data.message,
        "startTime": data.startTime,
        "endTime": data.endTime,
        "notfID": notfID,
        "timeStamp": notfID,
        "type": "permission",
        "id": uuidv4()
    }
    var addToPost = new Promise((resolve, reject) => {
        let newpost = new POST(datax);
        newpost.save((err) => {
            if (err) {
                console.log(err)
                reject()
            }
            resolve()
        })
    })
    await addToPost;
    var addToPeople = new Promise((resolve, reject) => {
        let coun = "posts." + datax["council"].toString();
        let update = {};
        update["$push"][coun] = datax["id"];
        PEOPLE.update({id: datax.owner}, update, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await addToPeople;
    await sendToTopicUpdate(datax.id);
    return datax.id;
}

async function editPost(data){
    let datax = {
        "title": data.title,
        "tags": data.tags,
        "council": data.council,
        "sub": data.sub,
        "body": data.body,
        "url": data.url,
        "priority": data.priority,
        "message": data.message,
        "startTime": data.startTime,
        "endTime": data.endTime,
        "timeStamp": Date.now()
    }
    var addToPost = new Promise((resolve, reject) => {
        POST.update({id: data.id}, datax, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await addToPost;
    await sendToTopicUpdate(data.id);
    return data.id;
}

async function deletePost(data){
    var deletePost = new Promise((resolve, reject) => {
        POST.deleteOne({id: data.id}, function(err, numAffected){
            resolve();
        })
    })
    await deletePost;
    var addToPeople = new Promise((resolve, reject) => {
        let coun = "posts." + data["council"].toString();
        let update = {};
        update["$pull"][coun] = data["id"];
        PEOPLE.update({id: data.owner}, update, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await addToPeople;
    await sendToTopicDelete(data.id, data.owner, data.sub);
    return data.id;
}

async function elevatePerson(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        SUSER.find({id: data.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') reject(); else resolve(docs[0]);
        });
    });
    let suserDoc = await fetchDoc;
    if(!suserDoc.admin){
        var updateSuser = new Promise((resolve, reject) => {
            SUSER.update({id: data.id}, {admin: true}, {multi : false}, function(err, numAffected){
                resolve();
            })
        })
        await updateSuser;
        var addToPeople = new Promise((resolve, reject) => {
            let newpeep = new PEOPLE({id: data.id});
            newpeep.save((err) => {
                if (err) {
                    console.log(err)
                    reject()
                }
                resolve()
            })
        })
        await addToPeople;
    }
    let updatex = {$addToSet: {councils: data.council}};
    updatex["$addToSet"][data.council]=data.por;
    var updatePeep = new Promise((resolve, reject) => {
        PEOPLE.update({id: data.id}, updatex, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await updatePeep;
    return data.id;
}

async function linkAccount(data){
    let k = true;
    let fetchDoc = new Promise(function (resolve, reject) {
        USER.find({username: data.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') {k=false; resolve({});} else resolve(docs[0]);
        });
    });
    let userDoc = await fetchDoc;
    if(!k) return;
    var updateSuser = new Promise((resolve, reject) => {
        SUSER.update({id: data.id}, {name: userDoc.name, rollno: userDoc.roll}, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await updateSuser;
}

async function createAccount(data){
    let id = data.email.replace("@iitk.ac.in", "");
    let datax = {
        uid: data.uid,
        email: data.email,
        name: "",
        rollno: "",
        id
    }
    var addToSuser = new Promise((resolve, reject) => {
        let newsuser = new SUSER(datax);
        newsuser.save((err) => {
            if (err) {
                console.log(err)
                reject()
            }
            resolve()
        })
    })
    await addToSuser;
    await linkAccount(datax);
}

async function approvePosts(data){
    let datax = {
        "type": "create",
        "timeStamp": Date.now()
    }
    var addToPost = new Promise((resolve, reject) => {
        POST.update({id: data.id}, datax, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await addToPost;
    await sendToTopicUpdate(data.id);
    return data.id;
}

async function updatePrefs(data){
    var updateRef = new Promise((resolve, reject) => {
        SUSER.update({id: data.auth.id}, {council: data.council}, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await updateRef;
    return data.auth.id;
}

async function fetchPostUsingID(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({id: data.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve(false); else resolve(docs[0]);
        });
    });
    return fetchDoc;
}

async function fetchPostUsingTimestamp(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({timeStamp: {$gte: data.timeStamp}}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve(false); else {
                docs.sort((a, b) => b.timeStamp - a.timeStamp);
                resolve(docs);
            }
        });
    });
    return fetchDoc;
}

async function fetchPostUsingTypeCouncil(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({type: data.type, council: data.council}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve(false); else {
                docs.sort((a, b) => b.timeStamp - a.timeStamp);
                resolve(docs);
            }
        });
    });
    return fetchDoc;
}

app.post('/makePost', async (req, res)=>{
    let data = req.body;
    let v = await validatePost(data);
    if(!v) res.send("Fuck Off Impostor!");
    v = await postingVerification(data);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await makePost(data));
})

app.post('/editPost', async (req, res)=>{
    let data = req.body;
    let v = await validatePost(data);
    if(!v) res.send("Fuck Off Impostor!");
    v = await postingVerification(data);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await editPost(data));
})

app.post('/deletePost', async (req, res)=>{
    let data = req.body;
    let v = await deletionVerification(data);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await deletePost(data));
})

app.post('/elevatePerson', async (req, res)=>{
    let data = req.body;
    let v = elevationVerify(data);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await elevatePerson(data));
})

app.post('/createAccount', async (req, res)=>{
    let data = req.body;
    let v = authVerify(data);
    if(!v) res.send("Fuck Off Impostor!");
    await createAccount(data);
    res.end();
})

app.post('/approvePosts', async (req, res)=>{
    let data = req.body;
    let v = verifyApproval(data);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await approvePosts(data));
})

app.post('/getSuser', async (req, res)=>{
    let data = req.body;
    res.json(await getSuser(data));
    res.end();
})

app.post('/getPeople', async (req, res)=>{
    let data = req.body;
    res.json(await getPeople(data));
    res.end();
})

app.post('/getPostWithID', async (req, res)=>{
    let data = req.body;
    res.json(await fetchPostUsingID(data));
    res.end();
})

app.post('/getPostWithTimestamp', async (req, res)=>{
    let data = req.body;
    res.json(await fetchPostUsingTimestamp(data));
    res.end();
})

app.post('/getPostWithTypeCouncil', async (req, res)=>{
    let data = req.body;
    res.json(await fetchPostUsingTypeCouncil(data));
    res.end();
})

app.get('/getAllStudents', async (req, res)=>{
    res.json(await getAllStudData());
    res.end();
})

app.post('/updateStudent', async (req, res)=>{
    res.json(await updateStudData(req.body));
    res.end();
})

app.post('/updatePrefs', async (req, res)=>{
    let data = req.body;
    let v = approveDef(data.auth.id, data.auth.uid);
    if(!v) res.send(false);
    res.send(await updatePrefs(data));
})

app.get('/hehe', (req,res)=>{
    res.send("Okay! Runner is working now.");
})

mongoose.connect(url, options, async function (err) {
    // let userx = JSON.parse(fs.readFileSync('hexml.json'));
    // for(let i=0; i<userx.length; i++){await createUsers(userx[i]);console.log(i+1);}
    app.use('/', router);
    app.listen(port);
    console.log("Connected at: "+port);
})