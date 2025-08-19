function on_open(params)
    if params then
        mode = params.mode
    end
    refresh()
end

-- add - packs to be added to the world (after apply)
-- rem - packs that should be removed from the world (after apply)
add_packs = {}
rem_packs = {}

-- included - connected packs to the world
-- excluded - packs that are not connected to the world
packs_included = {}
packs_excluded = {}

packs_info = {}

local function include(id, is_include)
    if is_include then
        table.insert(packs_included, id)
        table.remove_value(packs_excluded, id)
    else
        table.insert(packs_excluded, id)
        table.remove_value(packs_included, id)
    end
end

function apply()
    if not table.has(add_packs, PACK_ID) then
        table.insert(add_packs, "quartz")
    end

    for i, pack in ipairs(rem_packs) do
        if table.has(add_packs, pack) then
            table.remove(add_packs, i)
        end
    end

    for i=#CONTENT_PACKS, 1, -1 do
        if CONTENT_PACKS[i] ~= PACK_ID then table.remove(CONTENT_PACKS, i) end
    end

    external_app.reset_content()
    external_app.reconfig_packs(add_packs, {})
    core.load_content()

    CONTENT_PACKS = table.unique(table.merge(CONTENT_PACKS, add_packs))
    if mode ~= "world" then
        menu:back()
    end
end

function reposition_func(_pack)
    local INTERVAL = 2
    local STEP = 1
    local SIZE = 80

    local tbl = nil
    if table.has(packs_included, _pack) then
        tbl = packs_included
    elseif table.has(packs_excluded, _pack) then
        tbl = packs_excluded
    else
        tbl = packs_excluded
        local packinfo = pack.get_info(_pack)
        packinfo[packinfo.id] = {packinfo.id, packinfo.title}
        table.insert(packs_excluded, packinfo.id)
    end

    local indx = table.index(tbl, _pack) - 1
    local pos = {0, (SIZE + INTERVAL) * indx + STEP}

    return pos[1], pos[2]
end


function refresh_search()
    local search_text = document.search_textbox.text:lower()

    local new_included = table.copy(packs_included)
    local new_excluded = table.copy(packs_excluded)

    local function score(pack_name)
        if pack_name:lower():find(search_text) then
            return 1
        end
        return 0
    end

    local function sorting(a, b)
        local score_a = score(packs_info[a][2])
        local score_b = score(packs_info[b][2])

        if score_a ~= score_b then
            return score_a > score_b
        else
            return packs_info[a][2] < packs_info[b][2]
        end
    end

    table.sort(new_included, sorting)
    table.sort(new_excluded, sorting)

    packs_included = new_included
    packs_excluded = new_excluded

    for _, id in ipairs(table.merge(table.copy(packs_included), packs_excluded)) do
        local content = document["pack_" .. id]
        content:reposition()
    end
end


function refresh_changes()
    document.apply_btn.enabled = (#add_packs>0) or (#rem_packs>0)
    refresh_search()
end

function move_pack(id)
    -- cancel pack addition
    if table.has(add_packs, id) then
        document["pack_"..id]:moveInto(document.packs_add)
        table.remove_value(add_packs, id)
        include(id, false)
    -- cancel pack removal
    elseif table.has(rem_packs, id) then
        document["pack_"..id]:moveInto(document.packs_cur)
        table.remove_value(rem_packs, id)
        include(id, true)
    -- add pack
    elseif table.has(packs_installed, id) then
        document["pack_"..id]:moveInto(document.packs_add)
        table.insert(rem_packs, id)
        include(id, false)
    -- remove pack
    else
        document["pack_"..id]:moveInto(document.packs_cur)
        table.insert(add_packs, id)
        include(id, true)
    end
    refresh_changes()
end

function pin(id)
    if not table.has(packs_included, id) then
        move_pack(id)
    end

    if table.has(CONFIG.Pinned_packs, id) then
        table.remove_value(CONFIG.Pinned_packs, id)
        document["pin_" .. id].color = {138, 127, 142, 255}
    else
        table.insert(CONFIG.Pinned_packs, id)
        document["pin_" .. id].color = {255, 255, 255, 255}
    end

    file.write(CONFIG_PATH, json.tostring(CONFIG))
end

function place_pack(panel, packinfo, callback, position_func)
    if packinfo.error then
        callback = nil
    end
    if packinfo.has_indices then
        packinfo.id_verbose = packinfo.id.."*"
    else
        packinfo.id_verbose = packinfo.id
    end
    packinfo.callback = callback
    packinfo.position_func = position_func or function () end

    panel:add(gui.template("quartz_pack", packinfo))
    if not callback or packinfo.has_indices then
        document["pack_"..packinfo.id].enabled = false
    end

    if not table.has(CONFIG.Pinned_packs, packinfo.id) then
        document["pin_" .. packinfo.id].color = {138, 127, 142, 255}
    end
end

function check_dependencies(packinfo)
    if packinfo.dependencies == nil then
        return
    end
    for i,dep in ipairs(packinfo.dependencies) do
        local depid = dep:sub(2,-1)
        if dep:sub(1,1) == '!' then 
            if not table.has(packs_all, depid) then
                return string.format(
                    "%s (%s)", gui.str("error.dependency-not-found"), depid
                )
            end
            if table.has(packs_installed, packinfo.id) then
                table.insert(required, depid)
            end
        end
    end
end

function check_deleted()
    for i = 1, math.max(#packs_included, #packs_excluded) do
        local pack = packs_included[i]
        if pack and not table.has(packs_all, pack) then
            table.remove(packs_included, i)
            table.insert(rem_packs, pack)
        end

        pack = packs_excluded[i]
        if pack and not table.has(packs_all, pack) then
            table.remove(packs_excluded, i)
            table.insert(rem_packs, pack)
        end
    end
end

function refresh()
    packs_installed = pack.get_installed()
    packs_available = pack.get_available()
    base_packs = pack.get_base_packs()
    packs_all = {unpack(packs_installed)}
    required = {}

    for _, pack in ipairs({PACK_ID}) do
        if not table.has(base_packs, pack) then
            table.insert(base_packs, pack)
        end
    end

    table.merge(packs_all, packs_available)

    local packs_cur = document.packs_cur
    local packs_add = document.packs_add
    packs_cur:clear()
    packs_add:clear()

    -- Блокируем пакет, содержащий используемый генератор
    if world.is_open() then
        local genpack, genname = parse_path(world.get_generator())
        if genpack ~= "core" then
            table.insert(base_packs, genpack)
        end
    end

    local packids = {unpack(packs_installed)}
    for i,k in ipairs(packs_available) do
        table.insert(packids, k)
    end
    local packinfos = pack.get_info(packids)

    for _,id in ipairs(base_packs) do
        local packinfo = pack.get_info(id)
        packs_info[id] = {packinfo.id, packinfo.title}
    end

    for _,id in ipairs(packs_all) do
        local packinfo = pack.get_info(id)
        packs_info[id] = {packinfo.id, packinfo.title}
    end

    for i,id in ipairs(packs_installed) do
        if table.has(required, id) then
            document["pack_"..id].enabled = false
        end
    end

    if #packs_excluded == 0 then packs_excluded = table.copy(packs_available) end
    if #packs_included == 0 then packs_included = table.copy(packs_installed) end

    for i,id in ipairs(packs_installed) do
        local packinfo = packinfos[id]
        packinfo.index = i
        local callback = not table.has(base_packs, id) and string.format('move_pack("%s")', id) or nil
        packinfo.error = check_dependencies(packinfo)
        place_pack(packs_cur, packinfo, callback, string.format('reposition_func("%s")', packinfo.id))
    end

    for i,id in ipairs(packs_available) do
        local packinfo = packinfos[id]
        packinfo.index = i
        local callback = string.format('move_pack("%s")', id)
        packinfo.error = check_dependencies(packinfo)
        place_pack(packs_add, packinfo, callback, string.format('reposition_func("%s")', packinfo.id))
    end

    check_deleted()
    apply_movements(packs_cur, packs_add)
    refresh_changes()
end

function apply_movements(packs_cur, packs_add)
    for i,id in ipairs(packs_installed) do
        if table.has(rem_packs, id) then
            document["pack_"..id]:moveInto(packs_add)
        end
    end
    for i,id in ipairs(packs_available) do
        if table.has(add_packs, id) then
            document["pack_"..id]:moveInto(packs_cur)
        end
    end
end
