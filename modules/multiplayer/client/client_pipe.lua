local protocol = require "multiplayer/protocol-kernel/protocol"

local in_menu_handlers = require "multiplayer/client/handling/in_menu"
local in_game_handlers = require "multiplayer/client/handling/in_game"

local Pipeline = require "lib/common/pipeline"
local List = require "lib/common/list"

local ClientPipe = Pipeline.new()

ClientPipe:add_middleware(function(server)
    local co = server.meta.recieve_co
    if not co then
        co = coroutine.create(function()
            while true do
                local received_any = false
                while true do
                    local success, packet = pcall(function()
                        return protocol.parse_packet("server", function (len) return server.network:recieve_bytes(len) end)
                    end)

                    if success and packet then
                        List.pushright(server.received_packets, packet)
                        received_any = true
                    else
                        break
                    end
                end
                if not received_any then
                    coroutine.yield()
                end
            end
        end)
        server.meta.recieve_co = co
    end
    coroutine.resume(co)
    return server
end)

ClientPipe:add_middleware(function(server)
    if List.is_empty(server.received_packets) then
        return server
    end

    local packet = List.popleft(server.received_packets)

    local success, err = pcall(function()
        if server.state ~= 3 then
            server.fsm:handle_event(server, packet)
            in_menu_handlers[packet.packet_type](server, packet)
        elseif server.state == 3 then
            in_game_handlers[packet.packet_type](server, packet)
        end
    end)

    if not success then
        logger.log("Error while reading packet: " .. err, 'E')
    end

    return server, not List.is_empty(server.received_packets)
end)

ClientPipe:add_middleware(function(server)
    while not List.is_empty(server.response_queue) do
        local packet = List.popleft(server.response_queue)
        local success, err = pcall(function()
            server.network:send(packet)
        end)
        if not success then
            break
        end
    end
    return server
end)

return ClientPipe