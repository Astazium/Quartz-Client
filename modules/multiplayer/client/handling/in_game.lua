local protocol = require "multiplayer/protocol-kernel/protocol"

local handlers = {}

handlers[protocol.ServerMsg.ChunkData] = function (server, packet)
    world.set_chunk_data(packet.x, packet.z, packet.data, true)
end

handlers[protocol.ServerMsg.ChunksData] = function (server, packet)
    for _, chunk in ipairs(packet.list) do
        world.set_chunk_data(chunk[1], chunk[2], chunk[3], true)
    end
end

handlers[protocol.ServerMsg.PlayerHandSlot] = function (server, packet)
    player.set_selected_slot(hud.get_player(), packet.slot)
end

handlers[protocol.ServerMsg.BlockChanged] = function (server, packet)
    local pid = packet.pid

    if pid == 0 then
        pid = -1
    end

    block.set(packet.x, packet.y, packet.z, packet.block_id, packet.block_state, pid)
end

handlers[protocol.ServerMsg.TimeUpdate] = function (server, packet)
    if world.is_open() then
        local day_time = packet.game_time / 65535
        world.set_day_time( day_time )
    end
end

handlers[protocol.ServerMsg.ChatMessage] = function (packet)
    console.chat("| "..packet.message)
end

return handlers