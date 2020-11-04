const { v4: uuidv4 } = require('uuid');

let mongoose = require('mongoose');
const USER = require('./schema/userSchema.js');
const POST = require('./schema/postSchema.js');
const PEOPLE = require('./schema/peopleSchema.js');
const SUSER = require('./schema/suserSchema.js');
const PREF = require('./schema/prefsSchema.js');
const fs=require('fs');
let express = require('express');
let bodyParser = require('body-parser');
let cors = require('cors');
var admin = require("firebase-admin");
let structure=JSON.parse(fs.readFileSync(__dirname+'/static/data.json'));
let serviceAccount=JSON.parse(fs.readFileSync(__dirname+'/fbase-creds.json'));

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
app.use('/', express.static(__dirname + '/static'));
var url = "mongodb://127.0.0.1:27017/oarsscrap";
let options = {
    useNewUrlParser: true,
    useFindAndModify: false,
    useCreateIndex: true,
    useUnifiedTopology: true
}
var port = 8080;
port = process.env.PORT;
if (port == null || port == "") {port = 8080};

/**
 * Add user entry to 'USER' collection.
 * @param {Object} userdata : All fields in USER Schema
 */
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

/**
 * Returns all the documents from USER Collection
 */
function getAllStudData(){
    var promiseforcheck = new Promise(function (resolve, reject) {
        var userrecord = USER.find({}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') reject(); else resolve(docs);
        });
    });
    return promiseforcheck;
}

/**
 * Updates USER document of the supplied Roll Number
 * @param {Object} data : Requires "roll" and the data to update
 */
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

/**
 * Generates a generic notification targetting a particular user.
 * @param {Object} data : Requires "id" of the user and the "fetchField" info you want to send.
 */
async function genericNotification(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        PREF.find({id: data.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') reject(); else resolve(docs[0]);
        });
    });
    let data = await fetchDoc;
    let payload = {
        data: {
            fetchField: data.fetchField,
            notfID: Date.now().toString(), // id of notification in integer
        }
    }
    payload["tokens"] = data.deviceid;
    if(payload["tokens"]!=[])
    await fcm.sendMulticast(payload);
}

/**
 * Checks if the user exists in the system
 * @param {String} id  : CC-id
 * @param {String} uid : Firebase UID
 */
async function approveDef(id, uid){
    let fetchDoc = new Promise(function (resolve, reject) {
        SUSER.find({id, uid}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve(false); else resolve(true);
        });
    });
    return fetchDoc;
}

/**
 * Checks if the data in the post is valid.
 * @param {Object} data : Requires "council", "sub"
 */
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

/**
 * Checks if the poster has sufficient permissions to create the post.
 * @param {Object} data : Requires "auth", "owner", "council", "sub"
 */
async function postingVerification(data){
    let k = await approveDef(data.auth.id, data.auth.uid);
    if(!k) return false;
    if(data.owner != data.auth.id) return false;
    if(structure.level3.includes(data.auth.id)) return true;
    if(structure[data.council].level2.includes(data.auth.id)) return true;
    if(data.priority) return false;
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

/**
 * Checks if the person has sufficient permissions to delete a post.
 * @param {Object} data : Requires "auth", "council", "sub"
 */
async function deletionVerification(data){
    let k = await approveDef(data.auth.id, data.auth.uid);
    if(!k) return false;
    if(data.owner != data.auth.id) return false;
    if(structure.level3.includes(data.auth.id)) return true;
    if(structure[data.council].level2.includes(data.auth.id)) return true;
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({owner: data.auth.id, id: data.id, sub: data.sub}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') {k=false; resolve({});} else resolve(docs[0]);
        });
    });
    let postRec = await fetchDoc;
    if(!k) return false;
    return true;
}

/**
 * Verifies if the Firebase UID and user emails correspond.
 * @param {*} data : Requires "uid", "email"
 */
async function authVerify(data){
    let userRec = await auth.getUser(data.uid);
    userRec = userRec.toJSON();
    if(userRec.email != data.email) return false;
    return true;
}

/**
 * Checks if the person giving posting rights has them hiself.
 * @param {Object} data : Requires "auth", "council"
 */
async function elevationVerify(data){
    let k = await approveDef(data.auth.id, data.auth.uid);
    if(!k) return false;
    if(structure.level3.includes(data.auth.id)) return true;
    if(structure[data.council].level2.includes(data.auth.id)) return true;
    return false;
}

/**
 * Verifies if the person approving has sufficient rights
 * @param {Object} data : Requires "auth", "id", "council"
 */
async function verifyApproval(data){
    if(!(await approveDef(data.auth.id, data.auth.uid))) return false;
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

async function approveDraft(data){
    if(!(await approveDef(data.auth.id, data.auth.uid))) return false;
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({id: data.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') reject(); else resolve(docs[0]);
        });
    });
    let postDoc = await fetchDoc;
    if(data.auth.id == postDoc.owner) return true;
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

async function makePost(data, ptype="permission"){
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
        "type": ptype,
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
        let update = {$push: {}};
        update["$push"][coun] = datax["id"];
        PEOPLE.update({id: datax.owner}, update, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await addToPeople;
    await sendToTopicUpdate(datax.id);
    await genericNotification({
        id: data.owner,
        fetchField: "people"
    });
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
        let update = {$pull: {}};
        update["$pull"][coun] = data["id"];
        PEOPLE.update({id: data.owner}, update, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await addToPeople;
    await sendToTopicDelete(data.id, data.owner, data.sub);
    await genericNotification({
        id: data.owner,
        fetchField: "people"
    });
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
    await genericNotification({
        id: data.id,
        fetchField: "suser"
    });
    await genericNotification({
        id: data.id,
        fetchField: "people"
    });
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
    datax = {uid: data.uid,id}
    var addToPrefs = new Promise((resolve, reject) => {
        let newpref = new PREF(datax);
        newpref.save((err) => {
            if (err) {
                console.log(err)
                reject()
            }
            resolve()
        })
    })
    await addToPrefs;
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

async function publishDraft(data){
    let datax = {
        "type": "permission",
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
    await genericNotification({
        id: data.auth.id,
        fetchField: "suser"
    });
    return data.auth.id;
}

async function fetchPostUsingID(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({id: data.id}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve([]); else resolve(docs[0]);
        });
    });
    return fetchDoc;
}

async function fetchPostUsingTimestamp(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        POST.find({timeStamp: {$gte: data.timeStamp}}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve([]); else {
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
            if (err || typeof docs[0] === 'undefined') resolve([]); else {
                docs.sort((a, b) => b.timeStamp - a.timeStamp);
                resolve(docs);
            }
        });
    });
    return fetchDoc;
}

async function storeDevice(data){
    let datax = {$addToSet: {deviceid: data.deviceid}}
    var addToPref = new Promise((resolve, reject) => {
        PREF.update({id: data.auth.id, uid: data.auth.uid}, datax, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await addToPref;
    return data.deviceid;
}

async function updateSData(data){
    let datax = {reminder: data.reminder, bookmark: data.bookmark}
    var addToPref = new Promise((resolve, reject) => {
        PREF.update({id: data.auth.id, uid: data.auth.uid}, datax, {multi : false}, function(err, numAffected){
            resolve();
        })
    })
    await addToPref;
    return data.deviceid;
}

async function fetchSData(data){
    let fetchDoc = new Promise(function (resolve, reject) {
        PREF.find({id: data.auth.id, uid:data.auth.uid}, function (err, docs) {
            if (err || typeof docs[0] === 'undefined') resolve([]); resolve(docs[0]);
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

app.post('/makeDraft', async (req, res)=>{
    let data = req.body;
    let v = await validatePost(data);
    if(!v) res.send("Fuck Off Impostor!");
    v = await postingVerification(data);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await makePost(data, "draft"));
})

app.post('/publishDraft', async(req, res)=>{
    let data = req.body;
    let v = await approveDraft(data);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await publishDraft(data));
})

app.post('/elevatePerson', async (req, res)=>{
    let data = req.body;
    let v = await elevationVerify(data);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await elevatePerson(data));
})

app.post('/createAccount', async (req, res)=>{
    let data = req.body;
    let v = await authVerify(data);
    if(!v) res.send("Fuck Off Impostor!");
    await createAccount(data);
    res.end();
})

app.post('/approvePosts', async (req, res)=>{
    let data = req.body;
    let v = await verifyApproval(data);
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

app.post('/storeDevice', async (req, res)=>{
    let data = req.body;
    let v = await approveDef(data.auth.id, data.auth.uid);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await storeDevice(data));
})

app.post('/updateSData', async (req, res)=>{
    let data = req.body;
    let v = await approveDef(data.auth.id, data.auth.uid);
    if(!v) res.send("Fuck Off Impostor!");
    res.send(await updateSData(data));
})

app.post('/fetchSData', async (req, res)=>{
    let data = req.body;
    let v = await approveDef(data.auth.id, data.auth.uid);
    if(!v) res.send("Fuck Off Impostor!");
    res.json(await fetchSData(data));
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
    let v = await approveDef(data.auth.id, data.auth.uid);
    if(!v) res.send(false);
    res.send(await updatePrefs(data));
})

app.get('/dev', (req, res)=>{
    res.send("DEV end-points: ENABLED.");
})

mongoose.connect(url, options, async function (err) {
    // let userx = JSON.parse(fs.readFileSync(__dirname + '/hexml.json'));
    // for(let i=0; i<userx.length; i++){await createUsers(userx[i]);console.log(i+1);}
    app.use('/', router);
    app.listen(port);
    console.log("Connected at: "+port);
})