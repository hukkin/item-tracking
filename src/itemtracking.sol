pragma solidity ^0.4.0;
contract ItemTracking {
    
    struct Item {
        uint id;
        address owner;
        bool exists;
        bool created;
    }
    
    mapping(uint => Item) items;
    
    modifier itemNotCreated(uint id) {
        if (items[id].created) {
            throw;
        }
        _;
    }
    
    modifier itemExists(uint id) {
        if (items[id].exists == false) {
            throw;
        }
        _;
    }
    
    modifier itemOwnedBySender(uint id) {
        if (items[id].owner != msg.sender) {
            throw;
        }
        _;
    }
    
    // Create a new item
    function create(uint id)
    itemNotCreated(id) {
        items[id].id = id;
        items[id].exists = true;
        items[id].owner = msg.sender;
    }
    
    // Combine two items to create a new one
    function combine(uint srcId1, uint srcId2, uint resultId)
    itemExists(srcId1)
    itemExists(srcId2)
    itemOwnedBySender(srcId1)
    itemOwnedBySender(srcId2) {
        items[srcId1].exists = false;
        items[srcId2].exists = false;
        create(resultId);
    }
    
    // Split item to create two new ones
    function split(uint srcId, uint resultId1, uint resultId2)
    itemExists(srcId)
    itemOwnedBySender(srcId) {
        items[srcId].exists = false;
        create(resultId1);
        create(resultId2);
    }
    
    // Handover ownership of the item
    function handover(uint id, address receiver)
    itemExists(id)
    itemOwnedBySender(id) {
        items[id].owner = receiver;
    }
}