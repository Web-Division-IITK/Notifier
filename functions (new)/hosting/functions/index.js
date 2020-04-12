const functions = require('firebase-functions');
const express = require('express');

const app = express();

app.get('/home',(request,response) => {
    response.send(
        {
            "level3": ["adtgupta","utkarshg"],
            "councils": ["ss", "snt", "gns", "anc", "mnc"],
            "snt" : {
                "level2" : ["sntsecy"],
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
            "ss" : {
                "level2" : ["sssecy"],
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
            "mnc" : {
                "level2" : ["mncsecy"],
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
            "gns" : {
                "level2" : ["gnssecy"],
                "entity":[ 
                    "ERA IITK",
                    "Vision",
                    "ZURA",
                    "Humanoid",
                    "iGEM",
                    "Robocon"],
                    "misc" : [""]
            },
            "anc" : {
                "level2" : ["ancsecy"],
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
            }
        }
    );
})
exports.app = functions.https.onRequest(app);
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
