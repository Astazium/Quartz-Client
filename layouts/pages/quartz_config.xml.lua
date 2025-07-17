local name = nil

function on_open()
    name = CONFIG.Account.name
    document.username.text = CONFIG.Account.name
end

function username_changed(text)
    name = text
end

function add_server()
    local server_ip = document.ip.text
    local server_name = document.server_name.text

    if not name or not ip then
        return
    end

    local address, port = unpack(string.split(server_ip, ':'))

    if not address or not port then
        return
    end

    table.insert(CONFIG.Servers, {name = server_name, address = address, port = port})
end

function finish()
    CONFIG.Account.name = name

    file.write(CONFIG_PATH, json.tostring(CONFIG))
    menu:back()
end