var mongoose = require('mongoose');
var Schema = mongoose.Schema;
const fs= require('fs');
let vals=JSON.parse(fs.readFileSync('./schema/vals.json'));
var suser = new Schema({
    _id: mongoose.Schema.Types.ObjectId,
    uid: {type:String, required:true, unique: true},
    id: {type:String, required:true, unique: true},
    email: {type:String, required:true},
    name: {type:String, required:true},
    rollno: {type:String, required:true},
    admin: {type:Boolean, default:false},
    council: {type:Schema.Types.Mixed, default: vals}
});


module.exports = mongoose.model('Suser', suser);