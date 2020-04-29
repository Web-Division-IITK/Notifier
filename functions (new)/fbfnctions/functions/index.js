const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fs=require('fs');
admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();

exports.makePost = functions.https.onRequest(async function (req, res) {
    // let FieldValue = require('firebase-admin').firestore.FieldValue
    // input must have these fields: id, owner, council, title, tags, sub, body, author, url, owner, message,startTime,endTime
    // startTime and endTime would be int
    let data = req.body;
    let notfID = Date.now();
    let datax = {
        "title": data.title,
        "tags": (data.tags == null) ? '' : data.tags,
        "council": data.council,
        "sub": data.sub,
        "body": data.body,
        "author": data.author,
        "url": (data.url == null) ? '' : data.url,
        "type": "create",
        "owner": data.owner,
        "message": data.message,
        "startTime": (data.startTime == null) ? '' : data.startTime,
        'endTime': (data.endTime == null) ? '' : data.endTime,
        "notfID": notfID,
        "timeStamp": Date.now(),
    }
    let ref = db.collection('allPosts').doc()
    datax.id = ref.id;
    await ref.set(datax);
    let coun = data.council.toString();
    let x = {};
    x[coun] = admin.firestore.FieldValue.arrayUnion(datax.id);
    await db.collection('posts').doc('council').update(x)
    await db.collection('people').doc(data.owner).update({
        posts: x,
    })
    res.send(datax.id);
})

exports.editPost = functions.https.onRequest(async function (req, res) {
    // input must have these fields: id, council
    // startTime and endTime would be int
    let data = req.body;
    let datax = {
        "title": data.title,
        "tags": (data.tags == null) ? '' : data.tags,
        "council": data.council,
        "sub": data.sub,
        "body": data.body,
        "startTime": (data.startTime == null) ? '' : data.startTime,
        'endTime': (data.endTime == null) ? '' : data.endTime,
        "type": "update",
        "author": data.author,
        "url": (data.url == null) ? '' : data.url,
        "owner": data.owner,
        "message": data.message,
        "timeStamp": Date.now(),
    };
    await db.collection('allPosts').doc(data.id).update(datax);
    res.send(data.id);
})

exports.deletePost = functions.https.onRequest(async function (req, res) {
    // input must have these fields: id, owner, council
    let data = req.body;
    await db.collection('allPosts').doc(data.id).delete();
    let x={};
    x[data.council]=admin.firestore.FieldValue.arrayRemove(data.id);
    await db.collection('posts').doc('council').update(x)
    await db.collection('people').doc(data.owner).update({
        posts: x
    })
    res.send(data.id);
})

exports.sendToTopicCreate = functions.firestore.document('allPosts/{id}').onCreate(async snapshot => {
    let data = snapshot.data();
    let sub = data.sub;
    // sub.unshift("Science and Technology Council");
    let payload = {
        data: {
            owner: data.owner,
            title: data.title,
            council: data.council,
            fetchFF: 'true',
            message: data.message,
            type: "create",
            notfID: data.notfID.toString(), // id of notification in integer
            id: data.id,
            sub: data.sub[0],
        }
    }
    await sub.forEach(async (element) => {
        await fcm.sendToTopic(element.replace(/ /g, '_'), payload, options)
    });
})

exports.sendToTopicUpdate = functions.firestore.document('allPosts/{id}').onUpdate(async (change, context) => {
    let data = change.after.data();
    let sub = data.sub;
    let payload;
    payload = {
        data: {
            owner: data.owner,
            title: data.title,
            council: data.council,
            message: data.message,
            fetchFF: 'true',
            type: "update",
            notfID: data.notfID.toString(), // id of notification in integer
            id: data.id,
            sub: data.sub[0],
        }
    }
    await sub.forEach(async (element) => {
        await fcm.sendToTopic(element.replace(/ /g, '_'), payload)
    });
})

exports.sendToTopicDelete = functions.firestore.document('allPosts/{id}').onDelete(async snapshot => {
    let data = snapshot.data();
    let sub = data.sub;
    let payload = {
        data: {
            timeStamp: Date.now().toString(),
            type: "delete",
            notfID: data.notfID.toString(),
            id: data.id,
        }
    };
    await sub.forEach(async (element) => {
        await fcm.sendToTopic(element.replace(/ /g, '_'), payload)
    });
})

exports.elevatePerson = functions.https.onRequest(async function (req, res) {
    // input: id, sub (array)
    let data = req.body;
    await db.collection('people').doc(data.id).get().then(async function (document) {
        if (document.exists) {
            let x = {
                councils: admin.firestore.FieldValue.arrayUnion(data.council)
            };
            x[data.council] = admin.firestore.FieldValue.arrayUnion(data.por);
            await document.ref.update(x);
        } else {
            let datax = {
                "id": data.id,
                "councils": [data.council],
                "snt": [],
                "ss": [],
                "anc": [],
                "mnc": [],
                "gns": [],
                "posts": {
                    "snt": [],
                    "mnc": [],
                    "anc": [],
                    "gns": [],
                    "ss": []
                }
            };
            datax[data.council] = data.por;
            await db.collection('people').doc(data.id).set(datax);
        }
    });

    let dxc = await db.collection('users').where('id', '==', data.id).get()
    dxc.forEach(async (res) => await db.collection('users').doc(res.data().uid).update({
        "admin": true
    }))
    res.send(data.id)
})

exports.resetCouncil = functions.https.onRequest(async function (req, res) {
    if (req.body.id != "sntsecy") {
        res.send({
            "status": "Not Authorized"
        })
    } else {
        let data = {
            "id": "sntsecy",
            "posts": [],
            "councils": ["snt"],
            "snt": ["Science and Technology Council"],
            "ss": [],
            "anc": [],
            "mnc": [],
            "gns": [],
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
    let vals = JSON.stringify(fs.readFileSync('vals.json'));
    let id = user.email.replace("@iitk.ac.in", "");
    const account = {
        uid: user.uid,
        email: user.email,
        name: "",
        rollno: "",
        id,
        admin: false,
        council: vals
    }
    await db.collection('users').doc(user.uid).set(account);
});