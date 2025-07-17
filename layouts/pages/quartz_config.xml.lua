local name = nil

function on_open()
    name = CONFIG.Account.name
    document.username.text = CONFIG.Account.name
end

function username_changed(text)
    name = text
end

function add_server()
    local ip = document.ip.text
    local name = document.server_name.text

    if not name or not ip then
        return
    end

    local address, port = unpack(string.split(ip, ':'))

    if not address or not port then
        return
    end

    table.insert(CONFIG.Servers, {name = name, address = address, port = port})
end

function finish()
    CONFIG.Account.name = name

    file.write(CONFIG_PATH, json.tostring(CONFIG))
    menu:back()
end