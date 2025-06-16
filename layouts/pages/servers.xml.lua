local handlers = {}

function place_server(panel, server_info, callback)
    server_info.callback = callback
    panel:add(gui.template("server", server_info))
end

function on_open()
    for id, server in ipairs(CONFIG.Servers) do

        place_server(document.server_list, {
            id = id,
            server_favicon = "gui/not_connected",
            server_name = server.name,
            server_desc = '',
            server_status = COLORS.gray .. "pending...",
            players_online = ""
        })

        CLIENT:connect(server.address, server.port, server.name, id, {
            on_change_info = handlers.on_change_info,
            on_disconnect = handlers.on_disconnect
        })
    end
end

function handlers.on_change_info(server)

end

function handlers.on_disconnect(server)
    document["serverstatus_" .. tostring(server.id)].text = COLORS.red .. "offline"
end