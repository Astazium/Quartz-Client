function place_player(info)
    document.player_list:add(gui.template("player", info))
end

function leave()
    CLIENT:disconnect()
end

-- Тута надо функцию переименовать, но я пока не придумал
function player(id)
    local name = document["player_name_" .. id].text
    local is_friend = table.has(CONFIG.Account.friends, id)

    if is_friend then
        document["player_icon_" .. id].src = "gui/entity"
        document["player_action_" .. id].src = "gui/invite_friend"
        table.remove_value(CONFIG.Account.friends, name)
    else
        document["player_icon_" .. id].src = "gui/friend"
        document["player_action_" .. id].src = "gui/delete_friend"
        table.insert(CONFIG.Account.friends, name)
    end

    file.write(CONFIG_PATH, json.tostring(CONFIG))
end

local custom_icons = {}

function update()
    local players_online = table.count_pairs(PLAYER_LIST or {})

    local friends = table.copy(CONFIG.Account.friends)
    -- TODO: Исправить пинг
    local wait_time = math.max(time.uptime() - CLIENT_PLAYER.ping.last_upd - 5, 0)

    document.pid.text = "PID: " .. CLIENT_PLAYER.pid
    document.ping.text = "Ping: " .. math.round(wait_time*1000) .. "ms"
    document.online.text = string.format("Online: %s/%s", players_online+1, SERVER.meta.max_online)

    if not PLAYER_LIST or players_online == 0 then
        document.sad.visible = true
        return
    else
        document.sad.visible = false
    end

    for _, player in pairs(PLAYER_LIST) do
        local icon = nil
        local action = nil

        if table.has(friends, player.name) then
            icon = "gui/friend"
            action = "gui/delete_friend"
        else
            icon = "gui/entity"
            action = "gui/invite_friend"
        end

        if custom_icons[player.name] then
            icon = custom_icons[player.name]
        end

        place_player({
            id = player.name,
            player_icon = icon,
            player_pid = "PID: " .. player.pid,
            player_name = player.name,
            player_action = action
        })
    end
end

function on_open()
    update()
    local main_container = document.player_list.parent

    events.emit("quartz:pause_opened", document)

    main_container:setInterval(700, function ()
        for _, player in pairs(PLAYER_LIST) do
            if  custom_icons[player.name] and
                custom_icons[player.name] ~= "gui/friend" and
                custom_icons[player.name] ~= "gui/entity"
            then
                custom_icons[player.name] = document["player_icon_" .. player.name].src
            end
        end
        document.player_list:clear()
        update()
        custom_icons = {}
    end)
end
