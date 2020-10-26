var mongoose = require('mongoose');
var Schema = mongoose.Schema;
const fs= require('fs');
let vals=JSON.parse(fs.readFileSync(__dirname + '/vals.json'));
var suser = new Schema({
    uid: {type:String, required:true, unique: true},
    id: {type:String, required:true, unique: true},
    email: {type:String, required:true},
    name: {type:String, required:false},
    rollno: {type:String, required:false},
    admin: {type:Boolean, default:false},
    council: {type:Schema.Types.Mixed, default: vals}
});


module.exports = mongoose.model('Suser', suser);