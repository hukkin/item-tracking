/*
A helper script that provides a command line interface for running and testing
the functions of the itemtracking.sol smart contract.
*/

const fs = require('fs');
const Web3 = require('web3');
const web3 = new Web3();

// Set provider address
web3.setProvider(new web3.providers.HttpProvider('http://10.0.0.4:8080'));
// Name of the file that keeps track of created items (a comma separated list)
const idListFilename = "itemtracking_id_list.txt";
// Address of the smart contract
const contractAddress = "0x55e4d922f3d7ec50e7a6239230ffe020e1f94c02";
// ABI of the smart contract
const abi = [{"constant":true,"inputs":[{"name":"id","type":"uint256"}],"name":"getCreatedStatus","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"srcIds","type":"uint256[]"},{"name":"resultId","type":"uint256"}],"name":"combine","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"srcId","type":"uint256"},{"name":"toBeExtractedIds","type":"uint256[]"}],"name":"extract","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"id","type":"uint256"}],"name":"getExistsStatus","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"id","type":"uint256"},{"name":"receiver","type":"address"}],"name":"handover","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"id","type":"uint256"}],"name":"create","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"parentId","type":"uint256"},{"name":"componentIndex","type":"uint256"}],"name":"getComponentId","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"id","type":"uint256"}],"name":"getOwner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"srcId","type":"uint256"}],"name":"split","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"id","type":"uint256"}],"name":"getComponentCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"}];
// Address of the user performing the actions
const userAccount = web3.eth.accounts[0];


var myContractInstance = web3.eth.contract(abi).at(contractAddress);

if (process.argv[2] === "create") {
    const idStr = process.argv[3];
    myContractInstance.create.sendTransaction(parseInt(idStr), {from: userAccount, gas: 3000000});
    addIdToFile(idStr);
}
else if (process.argv[2] === "state") {
    var buf = fs.readFileSync(idListFilename, "utf8");
    var arr = buf.split(",");
    arr.forEach(function(idStr) {
        printItem(parseInt(idStr));
    });
}
else if (process.argv[2] === "handover") {
    const itemIdStr = process.argv[3];
    const recipient = process.argv[4];
    myContractInstance.handover.sendTransaction(parseInt(itemIdStr), parseInt(recipient), {from: userAccount, gas: 3000000});
}
else if (process.argv[2] === "combine") {
    const combinedItemId = process.argv[3];
    var arr = [];
    for (var i = 4; i < process.argv.length; i++) {
        arr.push(parseInt(process.argv[i]));
    }
    myContractInstance.combine.sendTransaction(arr, parseInt(combinedItemId), {from: userAccount, gas: 3000000});
    addIdToFile(combinedItemId);
}
else if (process.argv[2] === "split") {
    const itemIdStr = process.argv[3];
    myContractInstance.split.sendTransaction(parseInt(itemIdStr), {from: userAccount, gas: 3000000});
}
else if (process.argv[2] === "extract") {
    const srcTtemIdStr = process.argv[3];
    var arr = [];
    for (var i = 4; i < process.argv.length; i++) {
        arr.push(parseInt(process.argv[i]));
    }
    myContractInstance.extract.sendTransaction(parseInt(srcTtemIdStr), arr, {from: userAccount, gas: 3000000});
}

function addIdToFile(idStr) {
    var buf = fs.readFileSync(idListFilename, "utf8");
    var arr = buf.split(",");

    // if the file was empty, an empty string will be created as a result of
    // using split. Remove that empty string.
    if (arr[0] === "") {
        arr.shift();
    }

    if (arr.indexOf(idStr) === -1) {
        arr.push(idStr);
    }
    fs.writeFileSync(idListFilename, arr.join(), 'utf8');
}

function printItem(id) {
    var jsonItem = new Object();
    jsonItem.id = id;
    jsonItem.created = myContractInstance.getCreatedStatus(id);
    jsonItem.exists = myContractInstance.getExistsStatus(id);
    jsonItem.owner = myContractInstance.getOwner(id);
    jsonItem.componentCount = myContractInstance.getComponentCount(id);
    console.log(JSON.stringify(jsonItem));
}