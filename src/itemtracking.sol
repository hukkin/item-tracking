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

    modifier itemIsCombined(uint id) {
        if (items[id].components.length < 2) {
            throw;
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
        // Verify that at least 2 components are being combined
        if (srcIds.length < 2) {
            throw;
        }

        for (uint i = 0; i < srcIds.length; i++) {
            items[srcIds[i]].exists = false;
        }
        create(resultId);
        items[resultId].components = srcIds;
    }
    
    // Split a combined item into its components
    function split(uint srcId)
    itemExists(srcId)
    itemOwnedBySender(srcId)
    itemIsCombined(srcId) {
        items[srcId].exists = false;
        for (uint i = 0; i < items[srcId].components.length; i++) {
            uint componentId = items[srcId].components[i];
            items[componentId].exists = true;
            items[componentId].owner = items[srcId].owner;
        }
    }
    
    // Handover ownership of the item
    function handover(uint id, address receiver)
    itemExists(id)
    itemOwnedBySender(id) {
        items[id].owner = receiver;
    }
}