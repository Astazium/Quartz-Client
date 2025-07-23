local next_id = 0

function place_player(info)
    document.player_list:add(gui.template("player", info))
end

function leave()
    CLIENT:disconnect()
end

function player(id)
    local name = document["player_name_" .. id].text
    local is_friend = document["player_icon_" .. id].src == "gui/friend"

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

function on_open()
    local players_online = table.count_pairs(PLAYER_LIST or {})

    local friends = table.copy(CONFIG.Account.friends)
    local wait_time = math.max(time.uptime() - CLIENT_PLAYER.ping.last_upd - 5, 0)

    document.pid.text = "Pid: " .. CLIENT_PLAYER.pid
    document.ping.text = "Ping: " .. math.round(wait_time*1000) .. "ms"
    document.online.text = string.format("Online: %s/%s", players_online+1, SERVER.meta.max_online)

    if not PLAYER_LIST or players_online == 0 then
        document.cross.visible = true
        return
    else
        document.cross.visible = false
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

        place_player({
            id = next_id,
            player_icon = icon,
            player_pid = "pid: " .. player.pid,
            player_name = player.name,
            player_action = action
        })

        next_id = next_id + 1
    end
end