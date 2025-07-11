local protocol = require "multiplayer/protocol-kernel/protocol"
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