local protocol = require "multiplayer/protocol-kernel/protocol"
local sandbox = require "multiplayer/client/sandbox"
local utils = require "lib/utils"

local buffer = {}
function on_chunk_present(x, z)
    if #buffer < core.get_setting("chunks.load-distance") then
        table.insert(buffer, x)
        table.insert(buffer, z)
        return
    end

    local packet = protocol.create_databuffer()
    packet:put_packet(protocol.build_packet("client", protocol.ClientMsg.RequestChunks, buffer))
    SERVER.network:send(packet.bytes)
    buffer = {x, z}
end

function on_world_tick()
    utils.__tick()

    if CLIENT_PLAYER then
        CLIENT_PLAYER:tick()
    end

    local x, y, z = player.get_pos(CLIENT_PLAYER.pid)

    if y < 0 or y > 255 then
        player.set_pos(CLIENT_PLAYER.pid, x, math.clamp(y, 0, 255), z)
    end

    if external_app.get_setting("chunks.load-distance") > CHUNK_LOADING_DISTANCE then
        external_app.set_setting("chunks.load-distance", CHUNK_LOADING_DISTANCE)
    end
end

function on_block_placed(blockid, x, y, z, playerid)
    if not CLIENT_PLAYER then return end
    if playerid ~= CLIENT_PLAYER.pid then return end

    local states = block.get_states(x, y, z)

    sandbox.on_placed(blockid, x, y, z, states)
end

function on_block_broken(blockid, x, y, z, playerid)
    if not CLIENT_PLAYER then return end
    if playerid ~= CLIENT_PLAYER.pid then return end

    sandbox.on_broken(blockid, x, y, z)
end

function on_block_interact(blockid, x, y, z, playerid)
    if not CLIENT_PLAYER then return end
    if playerid ~= CLIENT_PLAYER.pid then return end

    x, y, z = block.seek_origin(x, y, z)
    sandbox.on_interact(blockid, x, y, z)
end

function on_world_open()
    require "init/cmd"
end