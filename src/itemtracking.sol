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

    modifier itemsExist(uint[] ids) {
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

    modifier itemContainsComponents(uint id, uint[] componentIds) {

        for (uint i = 0; i < componentIds.length; i++) {
            bool componentFound = false;

            for (uint j = 0; j < items[id].components.length; j++) {
                if (items[id].components[j] == componentIds[i]) {
                    componentFound = true;
                    break;
                }
            }

            if (!componentFound) {
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
    itemsExist(srcIds)
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

    // Extract the sub-components listed in the parameter. Leave the rest of the
    // components in the parent item. Parent item maintains its old ID.
    // If less than 2 components would remain in the parent component, then
    // extract behaves exactly like split.
    function extract(uint srcId, uint[] toBeExtractedIds)
    itemExists(srcId)
    itemOwnedBySender(srcId)
    itemIsCombined(srcId)
    itemContainsComponents(srcId, toBeExtractedIds) {
        // If less than 2 components would remain in the parent item after
        // the extraction, perform split.
        if (items[srcId].components.length - toBeExtractedIds.length < 2) {
            split(srcId);
            return;
        }

        // Make extracted components exist and grant ownership to owner of
        // parent item.
        for (uint i = 0; i < toBeExtractedIds.length; i++) {
            uint componentId = toBeExtractedIds[i];
            items[componentId].exists = true;
            items[componentId].owner = items[srcId].owner;
        }

        // Remove extracted components from parent item's component listing
        for (uint i = 0; i < toBeExtractedIds.length; i++) {

            // Find out what the components index is in parent item's component
            // listing.
            uint componentIndex = 0;
            for (uint j = 0; j < items[srcId].components.length; j++) {
                if (componentId == items[srcId].components[j]) {
                    componentIndex = j;
                    break;
                }
            }

            // Remove item from componentIndex. To not bloat the array, let's do
            // this by copying value from the last index to componentIndex and
            // then remove the last index.
            uint lastIndex = items[srcId].components.length - 1;
            items[srcId].components[componentIndex] = items[srcId].components[lastIndex]
            delete items[srcId].components[lastIndex];
            items[srcId].components.length--;
        }
    }
    
    // Handover ownership of the item
    function handover(uint id, address receiver)
    itemExists(id)
    itemOwnedBySender(id) {
        items[id].owner = receiver;
    }
}