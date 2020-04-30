const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();

exports.makePost = functions.https.onRequest(async function (req, res) {
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
        "message": data.message
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
    await db.collection(data.council).doc(data.id).update(data);
    res.send(data.id);
})

exports.deletePost = functions.https.onRequest(async function (req, res) {
    // input must have these fields: id, owner, council
    let data = req.body;
    await db.collection(data.council).doc(data.id).delete();
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
            type: "creation",
            id: data.id,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    await sub.forEach(async (element) => {await fcm.sendToTopic(element.replace(/ /g, '_'), payload)});
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
            type: "update",
            id: data.id,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    await sub.forEach(async (element) => {await fcm.sendToTopic(element.replace(/ /g, '_'), payload)});
})

exports.sendToTopicDelete = functions.firestore.document('snt/{id}').onDelete(async snapshot => {
    let data = snapshot.data();
    let sub = data.sub;
    sub.unshift("Science and Technology Council")
    let payload = {
        notification: {
            type: "delete",
            id: data.id,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    await sub.forEach(async (element) => {await fcm.sendToTopic(element.replace(/ /g, '_'), payload)});
})

exports.elevatePerson = functions.https.onRequest(async function (req, res) {
    // input: id, sub (array)
    let data = req.body;
    let datax = {
        "id": data.id,
        "sub": data.sub,
        "posts": []
    }
    await db.collection('people').doc(data.id).set(datax);
    let dxc = await db.collection('users').where('id', '==', data.id).get()
    dxc.forEach(async (res)=> await db.collection('users').doc(res.data().uid).update({"admin": true}))
    res.send(data.id)
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
            "sub": ["Science and Technology Council"]
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
        prefs: []
    }
    await db.collection('users').doc(user.uid).set(account); 
});

exports.updateUser = functions.https.onRequest(async function (req, res) {
    // update: name, rollno and prefs array, input: uid of the person
    let data = req.body;
    await db.collection('users').doc(data.uid).update(data);
    res.send(data.uid)
})