local Player = require "multiplayer/classes/player"
local protocol = require "multiplayer/protocol-kernel/protocol"
local hash = require "lib/common/hash"

local handlers = {}

handlers["handshake"] = function (server)
    if server.state == 0  then
        local major, minor = external_app.get_version()
        local engine_version = string.format("%s.%s.0", major, minor)

        local buffer = protocol.create_databuffer()
        buffer:put_packet(protocol.build_packet("client", protocol.ClientMsg.HandShake, engine_version, "Neutron", protocol.data.version, {}, protocol.States.Status))
        buffer:put_packet(protocol.build_packet("client", protocol.ClientMsg.StatusRequest))
        server.network:send(buffer.bytes)

        server.state = protocol.States.Status
    end
end

handlers[protocol.ServerMsg.StatusResponse] = function (server, packet)
    server.network.socket:close()
    server.handlers.on_change_info(server, packet)
end

handlers[protocol.ServerMsg.Disconnect] = function (server, packet)
    menu:reset()
    menu.page = "quartz_connection"
    local document = Document.new("quartz:pages/quartz_connection")
    document.info.text = packet.reason
    CLIENT:disconnect()
end

handlers[protocol.ServerMsg.PacksList] = function (server, packet)
    local packs = packet.packs

    local pack_available = table.unique(table.merge(pack.get_available(), pack.get_installed()))
    local hashes = {}

    for i = #packs, 1, -1 do
        if not table.has(pack_available, packs[i]) then
            table.remove(packs, i)
        end
    end

    for i=1, #packs do
        local _pack = packs[i]
        if not table.has(CONTENT_PACKS, _pack) then
            table.insert(CONTENT_PACKS, _pack)
        end
    end

    local events_handlers = table.copy(events.handlers)

    external_app.reset_content()
    external_app.config_packs(CONTENT_PACKS)
    external_app.load_content()

    events.handlers = events_handlers

    for i, pack in ipairs(packs) do
        table.insert(hashes, pack)
        table.insert(hashes, hash.hash_mods({ pack }))
    end

    local buffer = protocol.create_databuffer()

    buffer:put_packet(protocol.build_packet("client", protocol.ClientMsg.PacksHashes, hashes))
    server.network:send(buffer.bytes)
end

handlers[protocol.ServerMsg.JoinSuccess] = function (server, packet)
    server.state = protocol.States.Active

    SERVER = server

    external_app.new_world("", "41530140565755", PACK_ID .. ":void", packet.entity_id)
    CLIENT.pid = packet.entity_id

    CHUNK_LOADING_DISTANCE = packet.chunks_loading_distance

    for _, rule in ipairs(packet.rules) do
        rules.set(rule[1], rule[2])
    end

    CLIENT_PLAYER = Player.new(hud.get_player(), CONFIG.Account.name)
end

return handlers