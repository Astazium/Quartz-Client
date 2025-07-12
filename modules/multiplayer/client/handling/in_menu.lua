local Player = require "multiplayer/classes/player"
local protocol = require "multiplayer/protocol-kernel/protocol"
local hash = require "lib/common/hash"

local handlers = {}

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

handlers[protocol.ServerMsg.StatusResponse] = function (server, packet)
    server.handlers.on_change_info(server, packet)
end

handlers[protocol.ServerMsg.PacksList] = function (server, packet)
    local packs = packet.packs
    local pack_available = pack.get_available()
    local hashes = {}

    for i = #packs, 1, -1 do
        if not table.has(pack_available, packs[i]) then
            table.remove(packs, i)
        end
    end

    external_app.reset_content()
    external_app.config_packs({ PACK_ID })
    external_app.reconfig_packs(packs, {})
    external_app.load_content()

    for i, pack in ipairs(packs) do
        table.insert(hashes, pack)
        table.insert(hashes, hash.hash_mods({ pack }))
    end

    CONTENT_PACKS = packs

    local buffer = protocol.create_databuffer()
    buffer:put_packet(protocol.build_packet("client", protocol.ClientMsg.PacksHashes, hashes))
    server.network:send(buffer.bytes)
end

handlers[protocol.ServerMsg.JoinSuccess] = function (server, packet)
    server.state = protocol.States.Active

    external_app.new_world("", "41530140565755", PACK_ID .. ":void", packet.entity_id)
    CLIENT.pid = packet.entity_id

    for _, rule in ipairs(packet.rules) do
        rules.set(rule[1], rule[2])
    end

    CLIENT_PLAYER = Player.new(hud.get_player(), CONFIG.Account.name)
    SERVER = server
end

return handlers