local Pipeline = require "lib/common/pipeline"
local protocol = require "multiplayer/protocol-kernel/protocol"

local ServerPipe = Pipeline.new()

--Отправляем позицию региона
ServerPipe:add_middleware(function(server)
    if CLIENT_PLAYER.changed_flags.region then
        server:push_packet("client", protocol.ClientMsg.PlayerRegion, CLIENT_PLAYER.region.x, CLIENT_PLAYER.region.z)
        CLIENT_PLAYER.changed_flags.region = false
    end
    return server
end)

--Отправляем позицию игрока
ServerPipe:add_middleware(function(server)
    if CLIENT_PLAYER.changed_flags.pos then
        server:push_packet("client", protocol.ClientMsg.PlayerPosition, {CLIENT_PLAYER.pos.x, CLIENT_PLAYER.pos.y, CLIENT_PLAYER.pos.z})
        CLIENT_PLAYER.changed_flags.pos = false
    end
    return server
end)

--Отправляем поворот
ServerPipe:add_middleware(function(server)
    if CLIENT_PLAYER.changed_flags.rot then
        server:push_packet("client", protocol.ClientMsg.PlayerRotation, CLIENT_PLAYER.rot.yaw, CLIENT_PLAYER.rot.pitch)
        CLIENT_PLAYER.changed_flags.rot = false
    end
    return server
end)

return ServerPipe