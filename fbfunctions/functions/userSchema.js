var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var user = new Schema({
    _id: mongoose.Schema.Types.ObjectId,
    username: String,
    hometown: String,
    hall: String,
    gender: String,
    name: String,
    roll: String,
    room: String,
    program: String,
    dept: String,
    blood_group: String
});

module.exports = mongoose.model('User', user);