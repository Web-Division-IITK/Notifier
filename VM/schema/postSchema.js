var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var post = new Schema({
    _id: mongoose.Schema.Types.ObjectId,
    id: {type: String, required: true, unique: true},
    title: {type: String, required: true},
    tags: {type: String, default: ''},
    council: {type: String, required: true},
    sub: {type: [String], required: true},
    body: {type: String, required: true},
    author: {type: String, required: true}, // check
    url: {type: String, default: ''},
    type: {type: String, default: 'permission'}, // pre-defined values
    priority: {type: String, required: true}, // pre-defined values
    owner: {type: String, required: true}, // check
    message: {type: String, required: true},
    startTime: {type: String, default: ''},
    endTime: {type: String, default: ''},
    notfID: {type: String, required: true},
    timeStamp: {type: Number, required: true},
});

        
module.exports = mongoose.model('Post', post);