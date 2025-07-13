local protocol = require "multiplayer/protocol-kernel/protocol"
local Player = require "multiplayer/classes/player"

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

handlers[protocol.ServerMsg.ChatMessage] = function (server, packet)
    console.chat("| "..packet.message)
end

handlers[protocol.ServerMsg.SynchronizePlayerPosition] = function (server, packet)
    local player_data = packet.data

    CLIENT_PLAYER:set_pos(player_data.pos, false)
    CLIENT_PLAYER:set_rot(player_data.rot, false)
    CLIENT_PLAYER:set_cheats(player_data.cheats, false)
end

handlers[protocol.ServerMsg.PlayerList] = function (server, packet)
    for _, player in ipairs(packet.list) do
        local pid = player[1]
        local name = player[2]
        if CLIENT_PLAYER.pid ~= pid then
            player.create(name, pid)
            PLAYER_LIST[pid] = Player(pid, name)
        end
    end
end

handlers[protocol.ServerMsg.PlayerListRemove] = function (server, packet)
    local player = PLAYER_LIST[packet.entity_id]
    if player then
        player:despawn()
        PLAYER_LIST[packet.entity_id] = nil
    end
end

handlers[protocol.ServerMsg.PlayerListAdd] = function (server, packet)
    local pid = packet.entity_id
    local name = packet.username
    if CLIENT_PLAYER.pid ~= pid and not PLAYER_LIST[pid] then
        player.create(name, pid)
        PLAYER_LIST[pid] = Player(pid, name)
    end
end

handlers[protocol.ServerMsg.PlayerMoved] = function (server, packet)
    local player = PLAYER_LIST[packet.entity_id]

    if not player then return end
    if packet.entity_id == CLIENT_PLAYER.entity_id then return end

    local data = packet.data
    player:set_pos(data.pos)
    player:set_rot(data.rot)
    player:set_cheats(data.cheats)
end

handlers[protocol.ServerMsg.KeepAlive] = function (server, packet)
    server:push_packet(protocol.ClientMsg.KeepAlive, packet.challenge)
end

handlers[protocol.ServerMsg.PlayerInventory] = function (server, packet)
    CLIENT_PLAYER:set_inventory(packet.inventory, false)
end

handlers[protocol.ServerMsg.PlayerHandSlot] = function (server, packet)
    CLIENT_PLAYER:set_slot(packet.slot, false)
end

return handlers