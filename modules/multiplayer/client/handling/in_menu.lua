local protocol = require "multiplayer/protocol-kernel/protocol"

local handlers = {}

handlers[protocol.ServerMsg.StatusResponse] = function (server, packet)
    server.handlers.on_change_info(server, packet)
end

handlers["handshake"] = function (server)
    if server.state == 0  then
        local major, minor = external_app.get_version()
        local engine_version = string.format("%s.%s.0", major, minor)

        local buffer = protocol.create_databuffer()
        buffer:put_packet(protocol.build_packet("client", protocol.ClientMsg.HandShake, engine_version, protocol.data.version, {}, protocol.States.Status))
        buffer:put_packet(protocol.build_packet("client", protocol.ClientMsg.StatusRequest))
        server.network:send(buffer.bytes)

        server.state = protocol.States.Status
    end
end

return handlers