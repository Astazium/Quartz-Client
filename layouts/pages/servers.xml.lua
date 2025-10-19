local protocol = require "multiplayer/protocol-kernel/protocol"
local server_list = document.server_list
local servers_infos = {}
local handlers = {}

function place_server(panel, server_info, callback)
    server_info.callback = callback
    panel:add(gui.template("server", server_info))
end

function on_open()
    for id, server in ipairs(CONFIG.Servers) do

        place_server(server_list, {
            id = id,
            server_favicon = "gui/not_connected",
            server_name = server.name,
            server_desc = '',
            server_status = COLORS.gray .. "pending...",
            players_online = ""
        })

        CLIENT:connect(server.address, server.port, server.name, nil, id, {
            on_change_info = handlers.on_change_info
        })
    end

    events.emit("quartz:server_list_opened", document)
end

function refresh()
    server_list:clear()
    for id, server in ipairs(CONFIG.Servers) do
        place_server(server_list, {
            id = id,
            server_favicon = "gui/not_connected",
            server_name = server.name,
            server_desc = '',
            server_status = COLORS.gray .. "pending...",
            players_online = ""
        })

        CLIENT:connect(server.address, server.port, server.name, nil, id, {
            on_change_info = handlers.on_change_info
        })
    end
end

function handlers.on_change_info(server, packet)
    assets.load_texture(packet.favicon, server.name .. ".icon")

    local friends = {}

    for id, friend in ipairs(packet.friends_states) do
        if friend == true then
            table.insert(friends, CONFIG.Account.friends[id])
        end
    end

    servers_infos[server.id] = {
        name = server.name,
        max = packet.max,
        online = packet.online,
        description = packet.description,
        version = packet.version,
        friends_online = friends,
        server = server
    }

    if table.count_pairs(friends) > 0 then
        document["serverdata_" .. server.id].color = {139, 0, 255, 32}
    end

    document["servericon_" .. server.id].src = server.name .. ".icon"
    document["playersonline_" .. server.id].text = string.left_pad(string.format("%s / %s", packet.online, packet.max), 10)
    document["serverdesc_" .. server.id].text = packet.short_desc
    document["serverstatus_" .. server.id].text = ''
end

function handlers.on_disconnect(server)
    document["serverstatus_" .. server.id].text = COLORS.red .. "offline"
end

function get_info(id)
    local info = servers_infos[id]
    if not info then return end

    info.friends_online = info.friends_online or {}

    document.version.text = info.version or "None"
    document.description.text = info.description or "None"
    document.friends.text = table.concat(info.friends_online, ', ')

    if #info.friends_online == 0 then
        document.friends.text = "None"
    end
end

function remove_server(id)
    table.remove(CONFIG.Servers, id)
    file.write(CONFIG_PATH, json.tostring(CONFIG))

    document["serverdata_" .. id]:destruct()
end

local edited_server = nil
function start_edit(id)
    if edited_server then
        return
    end

    id = tonumber(id)

    local info = CONFIG.Servers[id]
    edited_server = id
    document.root:add(gui.template("server_edit", {
        name = info.name,
        ip = string.format("%s:%s", info.address, info.port)
    }))
end

function edit_server(data)
    local server_ip = data.ip
    local server_name = data.name

    if server_name then
        CONFIG.Servers[edited_server].name = server_name
    end

    if server_ip then
        local address, port = unpack(string.split(server_ip, ':'))

        if not address or not port then
            return
        end

        CONFIG.Servers[edited_server].address = address
        CONFIG.Servers[edited_server].port = port
    end
end

function finish_edit()
    file.write(CONFIG_PATH, json.tostring(CONFIG))
    edited_server = nil
    refresh()
    document.server_edit:destruct()
end

function edit_server_name(text)
    edit_server({name = text})
end

function edit_server_ip(text)
    edit_server({ip = text})
end

function connect(id)
    local info = servers_infos[id]
    if not info then return end

    local server = info.server

    CLIENT:connect(server.address, server.port, server.name, protocol.States.Login, id, {
        on_connect = function (_server)
            events.emit("quartz:server_connect", _server)
            _server.meta.max_online = info.max
            local buffer = protocol.create_databuffer()

            local major, minor = external_app.get_version()
            local engine_version = string.format("%s.%s.0", major, minor)

            buffer:put_packet(protocol.build_packet("client", protocol.ClientMsg.HandShake, engine_version, "Neutron", protocol.data.version, {}, protocol.States.Login))
            buffer:put_packet(protocol.build_packet("client", protocol.ClientMsg.JoinGame, CONFIG.Account.name))
            _server.network:send(buffer.bytes)
        end
    })

    menu.page = "quartz_connection"
end

function to_config()
    menu.page="quartz_config"
    events.emit("quartz:config_opened", document)
end

function main_menu()
    external_app.reset_content()
    menu.page="main"
end