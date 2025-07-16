local protocol = require "multiplayer/protocol-kernel/protocol"
local Player = require "multiplayer/classes/player"

local api_events = require "api/events"
local api_entities = require "api/entities"
local api_env = require "api/env"
local api_particles = require "api/particles"
local api_audio = require "api/audio"
local api_text3d = require "api/text3d"
local api_wraps = require "api/wraps"

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
    for _, _player in ipairs(packet.list) do
        local pid = _player[1]
        local name = _player[2]
        if CLIENT_PLAYER.pid ~= pid then
            player.create(name, pid)
            PLAYER_LIST[pid] = Player.new(pid, name)
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
        PLAYER_LIST[pid] = Player.new(pid, name)
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

handlers[protocol.ServerMsg.Disconnect] = function (server, packet)
    CLIENT_PLAYER:set_slot(packet.slot, false)
end

handlers[ protocol.ServerMsg.PackEvent ] = function (server, packet)
    api_events.__emit__(packet.pack, packet.event, packet.bytes)
end

handlers[ protocol.ServerMsg.PackEnv ] = function (server, packet)
    api_env.__env_update__(packet.pack, packet.env, packet.key, packet.value)
end

handlers[ protocol.ServerMsg.WeatherChanged ] = function (server, packet)
    local name = packet.name
    if name == '' then
        name = nil
    end

    gfx.weather.change(
        packet.weather,
        packet.time,
        name
    )
end

handlers[ protocol.ServerMsg.PlayerFieldsUpdate ] = function (server, packet)
    api_entities.__update_player__(packet.pid, packet.dirty)
end

handlers[ protocol.ServerMsg.EntityUpdate ] = function (server, packet)
    api_entities.__emit__(packet.uid, packet.entity_def, packet.dirty)
end

handlers[ protocol.ServerMsg.EntityDespawn ] = function (server, packet)
    api_entities.__despawn__(packet.uid)
end

handlers[ protocol.ServerMsg.ParticleEmit ] = function (server, packet)
    api_particles.emit(packet.particle)
end

handlers[ protocol.ServerMsg.ParticleStop ] = function (server, packet)
    api_particles.stop(packet.pid)
end

handlers[ protocol.ServerMsg.ParticleOrigin ] = function (server, packet)
    api_particles.set_origin(packet.origin)
end

handlers[ protocol.ServerMsg.AudioEmit ] = function (server, packet)
    api_audio.emit(packet.audio)
end

handlers[ protocol.ServerMsg.AudioStop ] = function (server, packet)
    api_audio.stop(packet.id)
end

handlers[ protocol.ServerMsg.AudioState ] = function (server, packet)
    api_audio.apply(packet.state)
end

handlers[ protocol.ServerMsg.WrapShow ] = function (server, packet)
    api_wraps.show(packet)
end

handlers[ protocol.ServerMsg.WrapHide ] = function (server, packet)
    api_wraps.hide(packet.id)
end

handlers[ protocol.ServerMsg.WrapSetPos ] = function (server, packet)
    api_wraps.set_pos(packet.id, packet.pos)
end

handlers[ protocol.ServerMsg.WrapSetTexture ] = function (server, packet)
    api_wraps.set_texture(packet.id, packet.texture)
end

handlers[ protocol.ServerMsg.Text3DShow ] = function (server, packet)
    api_text3d.show(packet.data)
end

handlers[ protocol.ServerMsg.Text3DHide ] = function (server, packet)
    api_text3d.hide(packet.id)
end

handlers[ protocol.ServerMsg.Text3DState ] = function (server, packet)
    api_text3d.apply(packet.state)
end

handlers[ protocol.ServerMsg.Text3DAxis ] = function (server, packet)
    local state = {
        id = packet.id
    }

    if packet.is_x then
        state.axisX = packet.axis
    else
        state.axisY = packet.axis
    end

    api_text3d.apply(state)
end

return handlers