pragma solidity ^0.4.0;
contract ItemTracking {
    
    struct Item {
        uint id;
        address owner;
        uint[] components;
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

    modifier itemsExists(uint[] ids) {
        for (uint i = 0; i < ids.length; i++) {
            if (items[ids[i]].exists == false) {
                throw;
            }
        }
        _;
    }
    
    modifier itemOwnedBySender(uint id) {
        if (items[id].owner != msg.sender) {
            throw;
        }
        _;
    }

    modifier itemsOwnedBySender(uint[] ids) {
        for (uint i = 0; i < ids.length; i++) {
            if (items[ids[i]].owner != msg.sender) {
                throw;
            }
        }
        _;
    }
    
    // Create a new item
    function create(uint id)
    itemNotCreated(id) {
        items[id].id = id;
        items[id].exists = true;
        items[id].created = true;
        items[id].owner = msg.sender;
    }
    
    // Combine items to create a single new one
    function combine(uint[] srcIds, uint resultId)
    itemsExists(srcIds)
    itemsOwnedBySender(srcIds) {
        for (uint i = 0; i < srcIds.length; i++) {
            items[srcIds[i]].exists = false;
        }
        create(resultId);
        items[resultId].components = srcIds;
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