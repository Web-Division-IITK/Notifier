var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var people = new Schema({
    id: {type:String, required: true, unique: true},
    councils: {type: [String], default:[]},
    snt: {type: [String], default:[]},
    psg: {type: [String], default:[]},
    anc: {type: [String], default:[]},
    mnc: {type: [String], default:[]},
    gns: {type: [String], default:[]},
    senate: {type: [String], default:[]},
    posts: {
        snt: {type: [String], default:[]},
        mnc: {type: [String], default:[]},
        anc: {type: [String], default:[]},
        gns: {type: [String], default:[]},
        psg: {type: [String], default:[]},
        senate: {type: [String], default:[]}
    }
});


module.exports = mongoose.model('People', people);