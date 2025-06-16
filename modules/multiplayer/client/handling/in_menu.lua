local protocol = require "multiplayer/protocol-kernel/protocol"

local handlers = {}

handlers[protocol.ServerMsg.StatusResponse] = function (server, packet)
    
end

return handlers