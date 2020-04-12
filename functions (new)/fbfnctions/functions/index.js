const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();
exports.makePost = functions.https.onRequest(async function (req, res) {
    // let FieldValue = require('firebase-admin').firestore.FieldValue
    // input must have these fields: id, owner, council, title, tags, sub, body, author, url, owner, message
    let data = req.body;
    let datax = {
        "title": data.title,
        "tags": data.tags,
        "council": data.council,
        "sub": data.sub,
        "body": data.body,
        "author": data.author,
        "url": data.url,
        "owner": data.owner,
        "message": data.message,
        "timeStamp": admin.firestore.FieldValue.serverTimestamp(),
        "exists":true
    }
    let ref = db.collection(data.council).doc()
    datax.id = ref.id;
    await ref.set(datax);
    await db.collection('people').doc(data.owner).update({
        posts: admin.firestore.FieldValue.arrayUnion(datax.id)
    })
    res.send(datax.id);
})

exports.editPost = functions.https.onRequest(async function (req, res) {
    // input must have these fields: id, council
    let data = req.body;
    let datax = {
        "title": data.title,
        "tags": data.tags,
        "council": data.council,
        "sub": data.sub,
        "body": data.body,
        "author": data.author,
        "url": data.url,
        "owner": data.owner,
        "message": data.message,
        "timeStamp": admin.firestore.FieldValue.serverTimestamp(),
        "exists":true
    };
    await db.collection(data.council).doc(data.id).update(datax);
    res.send(data.id);
})

exports.deletePost = functions.https.onRequest(async function (req, res) {
    // input must have these fields: id, owner, council
    let data = req.body;

    await db.collection(data.council).doc(data.id).update({
        timeStamp: admin.firestore.FieldValue.serverTimestamp(),
        exists: false,
    });
    await db.collection('people').doc(data.owner).update({
        posts: admin.firestore.FieldValue.arrayRemove(data.id)
    })
    res.send(data.id);
})

exports.sendToTopicCreate = functions.firestore.document('snt/{id}').onCreate(async snapshot => {
    let data = snapshot.data();
    let sub = data.sub;
    sub.unshift("Science and Technology Council")
    let payload = {
        notification: {
            title: data.title,
            council: data.council,
            message: data.message,
            body:data.body,
            type: "create",
            id: data.id,
            // badge: data.id,
            // priority: "HIGH",
            sound: "default",
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        },
        
        // priority: "Priority.High",
        data:{
            title: data.title,
            council: data.council,
            message: data.message,
            body:data.body,
            type: "create",
            id: data.id,
            // status: "done",
            // priority:"high",
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    let options = {
        mutableContent : true,
        contentAvailable: true,
        priority:"high",
        collapseKey: data.message,
    };
    await sub.forEach(async (element) => {await fcm.sendToTopic(element.replace(/ /g, '_'), payload,options)});
})

exports.sendToTopicUpdate = functions.firestore.document('snt/{id}').onUpdate(async (change, context) => {
    let data = change.after.data();
    let sub = data.sub;
    sub.unshift("Science and Technology Council")
    let payload = {
        notification: {
            title: data.title,
            council: data.council,
            message: data.message,
            body:data.body,
            type: "update",
            id: data.id,
            // badge: data.id,
            // priority: "HIGH",
            sound: "default",
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        },
        
        // priority: "Priority.High",
        data:{
            title: data.title,
            council: data.council,
            message: data.message,
            body:data.body,
            type: "update",
            id: data.id,
            // status: "done",
            // priority:"high",
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
        
    };
    let options = {
        mutableContent : true,
        contentAvailable: true,
        priority:"high",
        collapseKey: data.message,
    };
    await sub.forEach(async (element) => {await fcm.sendToTopic(element.replace(/ /g, '_'), payload,options)});
})

exports.sendToTopicDelete = functions.firestore.document('snt/{id}').onDelete(async snapshot => {
    let data = snapshot.data();
    let sub = data.sub;
    sub.unshift("Science and Technology Council")
    let payload = {
        notification: {
            title: data.title,
            council: data.council,
            message: data.message,
            body:data.body,
            type: "delete",
            id: data.id,
            // badge: data.id,
            // priority: "HIGH",
            sound: "default",
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        },
        
        // priority: "Priority.High",
        data:{
            title: data.title,
            council: data.council,
            message: data.message,
            body:data.body,
            type: "delete",
            id: data.id,
            // status: "done",
            // priority:"high",
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    let options = {
        mutableContent : true,
        contentAvailable: true,
        priority:"high",
        collapseKey: data.message,
    };
    await sub.forEach(async (element) => {await fcm.sendToTopic(element.replace(/ /g, '_'), payload,options)});
})

exports.elevatePerson = functions.https.onRequest(async function (req, res) {
    // input: id, sub (array)
    let data = req.body;
    
    await db.collection('people').doc(data.id).get().then(async function(document){
        if(document.exists){
            
            await document.ref.update({
                councils: admin.firestore.FieldValue.arrayUnion(data.councils),
                snt: admin.firestore.FieldValue.arrayUnion(data.snt),
                ss: admin.firestore.FieldValue.arrayUnion(data.ss),
                anc: admin.firestore.FieldValue.arrayUnion(data.anc),
                mnc: admin.firestore.FieldValue.arrayUnion(data.mnc),
                gnc: admin.firestore.FieldValue.arrayUnion(data.gnc),
                councils: admin.firestore.FieldValue.arrayRemove(null),
                snt: admin.firestore.FieldValue.arrayRemove(null),
                ss: admin.firestore.FieldValue.arrayRemove(null),
                anc: admin.firestore.FieldValue.arrayRemove(null),
                mnc: admin.firestore.FieldValue.arrayRemove(null),
                gnc: admin.firestore.FieldValue.arrayRemove(null),
            });            
        }else{
            let datax = {
                "id": data.id,
                "councils": data.councils,
                "snt":  data.snt,
                "ss":data.ss,
                "anc": data.anc,
                "mnc":data.mnc,
                "gnc": data.gnc,
                // "sub": data.sub,
                "posts": []
            };
            await db.collection('people').doc(data.id).set(datax,{merge:true});
                // let dxc = await db.collection('users').where('id', '==', data.id).get()
                // dxc.forEach(async (res)=> await db.collection('users').doc(res.data().uid).update({"admin": true}))
                // res.send(data.id);
        }
    });
    
    let dxc = await db.collection('users').where('id', '==', data.id).get()
    dxc.forEach(async (res)=> await db.collection('users').doc(res.data().uid).update({"admin": true}))
    res.send(data.id)
    // });
    // try {
    //     console.log((await db.collection('people').doc(data.id).get()).exists);
    // } catch (error) {
    //     console.log(error);
    // }
    // await db.collection('people').where('id', '==', data.id).get();
    
    
})

exports.resetCouncil = functions.https.onRequest(async function (req, res) {
    if (req.body.id != "sntsecy") {
        res.send({
            "status": "Not Authorized"
        })
    }
    else {
        let data = {
            "id": "sntsecy",
            "posts": [],
            "councils":["snt"],
            "snt": ["Science and Technology Council"],
            "ss": [],
            "anc": [],
            "mnc": [],
            "gnc": [],
            // "sub": ["Science and Technology Council"]
        }
        await db.collection('people').listDocuments().then(val => {
            val.map((val) => {
                val.delete()
            })
        })
        await db.collection('snt').listDocuments().then(val => {
            val.map((val) => {
                val.delete()
            })
        })
        await db.collection('people').doc(data.id).set(data);
        res.send(data.id);
    }
})

exports.createAccountDocument = functions.auth.user().onCreate(async (user) => {
    let id = user.email.replace("@iitk.ac.in", "");
    const account = {
        uid: user.uid,
        email: user.email,
        name: "",
        rollno: "",
        id,
        admin: false,
        council: {
            "snt":{
                "entity":[ "Aeromodelling Club",
            "Astronomy Club",
            "Electronics Club",
            "Robotics Club",
            "Programming Club",
            "Speedcubing Club",
            "Finance and Analytics Club",
            "Science Coffee House",
             "DESCON",
              "Consulting Group",
            "Game Development Society",
            "Web Division", 
            "Outreach and Connect",
             "Product Development Society",
            "Aerial Robotics",
            "AUV",
            "IITK Motorsports",
            "ERA IITK",
            "Vision",
            "ZURA",
            "Humanoid",
            "iGEM",
            "Robocon"],
            "misc" : ["Science and Technology Council", "Techkriti"]
            },
            "mnc":{
                "entity":[ "Dance Club",
            "Music Club",
            "ERA IITK",
            "Vision",
            "ZURA",
            "Humanoid",
            "iGEM",
            "Robocon"],
            "misc" : ["Antaragni","Galaxy"]
            },
            "ss":{
                "entity":[ "Aeromodelling Club",
            "Astronomy Club",
            "Electronics Club",
             "Product Development Society",
            "Aerial Robotics",
            "AUV",
            "IITK Motorsports",
            "ERA IITK",
            "Vision",
            "ZURA",
            "Humanoid",
            "iGEM",
            "Robocon"],
            "misc" : [""]
            },
            "anc":{
                "entity":[ "Aeromodelling Club",
            "Astronomy Club",
            "Electronics Club",
            "Robotics Club",
            "Programming Club",
            "Speedcubing Club",
            "Finance and Analytics Club",
            "Science Coffee House",
             "DESCON"
              ],
            "misc" : [""]
            },
            "gns" : {
                "entity":[ 
                    "ERA IITK",
                    "Vision",
                    "ZURA",
                    "Humanoid",
                    "iGEM",
                    "Robocon"],
                "misc" : [""]
            }
        },
        prefs: [
        "Aeromodelling Club",
        "Astronomy Club",
        "Electronics Club",
        "Robotics Club",
        "Programming Club",
        "Speedcubing Club",
        "Finance and Analytics Club",
        "Science Coffee House",
        "DESCON",
        "Consulting Group",
        "Game Development Society",
        "Web Division", 
        "Outreach and Connect",
        "Product Development Society",
        "Aerial Robotics",
        "AUV",
        "IITK Motorsports",
        "ERA IITK",
        "Vision",
        "ZURA",
        "Humanoid",
        "iGEM",
        "Dance Club",
        "Music Club",
        "Robocon","Science and Technology Council", "Techkriti","Antaragni"]
    }
    await db.collection('users').doc(user.uid).set(account); 
});

exports.updateUser = functions.https.onRequest(async function (req, res) {
    // update: name, rollno and prefs array, input: uid of the person
    let data = req.body;
    await db.collection('users').doc(data.uid).update(data);
    res.send(data.uid)
})
// const allpost = express();
// allpost.get('/home',async function(req,res){
    
//     await db.collection('posts').doc('council').listCollections().then(async function(val){
//         let arr = [];
//         await val.forEach(async function(f){
//             await f.get().then(async function(value){
//                 arr.push(value);
//             })
//         })
//         res.send(arr);
//     })
// })
exports.allpost = functions.https.onCall(async (data)=>{
    let arr = [];
    const collections = await db.collection('posts').doc('council').listCollections();
    const document = await collections.map(col => col.listDocuments());
    const datax = document.map(datas => datas);
    return {
        datax
    };
        // res.send(arr);
        // await val.forEach(async function(f){
        //     await f.get().then(async function(value){
        //         // arr.push(value);
        //         arr += [value];
        //         res.send(value);
        //     })
        // })
       
    // });
    
})
exports.allposts = functions.https.onRequest(async function(req,res){
    // let data 
    let array= [];
    await db.collection('posts').doc('council').listCollections().then(async val => {
       await val.forEach(async (collection) => {
            await collection.listDocuments().then(val=>{
                // res.send
                val.forEach((f) => {
                    // res.send(f);
                    // array.push()
                    array.push(f.id);
                    // array.concat([f.id]);
                    // console.info(f);
                });
                
            });
        });
        res.send(array);
    });
    
})