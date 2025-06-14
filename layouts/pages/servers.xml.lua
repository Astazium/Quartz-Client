function place_server(panel, server_info, callback)
    server_info.callback = callback
    panel:add(gui.template("server", server_info))
end

function on_open()
    place_server(document.server_list, {
        server_favicon = "gui/not_connected",
        id = 1,
        server_name = "test",
        server_motd = "111"

    })
end