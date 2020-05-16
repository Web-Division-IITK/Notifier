let fs=require('fs');
let arr = JSON.parse(fs.readFileSync('hexml.json'));
let jsx={
    "Y10":[],
    "Y11":[],
    "Y12":[],
    "Y13":[],
    "Y14":[],
    "Y15":[],
    "Y16":[],
    "Y17":[],
    "Y18":[],
    "Y19":[],
    "misc":[]
}
for(var i=0; i<arr.length; i++){
    if(parseInt(arr[i].roll.substring(0, 2))>=10 && parseInt(arr[i].roll.substring(0, 2))<20) jsx['Y'+arr[i].roll.substring(0, 2)].push(arr[i]);
    else jsx['misc'].push(arr[i]);
}
let kys = Object.keys(jsx);
for(var k=0; k<kys.length; k++){
    fs.writeFileSync(kys[k]+'.json', JSON.stringify(jsx[kys[k]]));
}
fs.writeFileSync('njs.json', JSON.stringify(jsx));