var mongoose = require('mongoose');
var Schema = mongoose.Schema;
const fs= require('fs');
var prefs = new Schema({
    uid: {type:String, required:true, unique: true},
    id: {type:String, required:true, unique: true},
    reminder: {type: [String], default: []},
    bookmark: {type: [String], default: []},
    deviceid: {type: [String], default: []},
    seen: {type: [String], default: []}
});


module.exports = mongoose.model('Prefs', prefs);