local module = {
    blocks = {}
}

function module.blocks.sync_inventory(pos)
    local invid = inventory.get_block(pos.x, pos.y, pos.z)
    local inv = inventory.get_inv(invid)

    SERVER:push_packet(protocol.ClientMsg.BlockInventory, pos.x, pos.y, pos.z, inv)
end

function module.blocks.sync_slot(pos, slot)
    SERVER:push_packet(protocol.ServerMsg.BlockInventorySlot, pos.x, pos.y, pos.z, slot.slot_id, slot.item_id, slot.item_count)
end

return module