-- Инициализируем stdmin
require "quartz:std/stdmin"

initializator = {}

local default_config = {
    Account = {
        name = "Test",
        friends = {}
    },
    Servers = {
    },
    Pinned_packs = {
    }
}

-- Инициализируем конфиг

if not file.exists(CONFIG_PATH) then
    file.write(CONFIG_PATH, json.tostring(default_config))
end

CONFIG = table.merge(json.parse(file.read(CONFIG_PATH)), default_config)

-- Инициализацация паков
function initializator.init_packs()
    for i=#CONTENT_PACKS, 1, -1 do
        table.remove(CONTENT_PACKS, i)
    end

    external_app.reset_content()
    for _, pack in ipairs(pack.get_available()) do
        if table.has(CONFIG.Pinned_packs, pack) then
            external_app.reconfig_packs({pack}, {})
            table.insert(CONTENT_PACKS, pack)
        end
    end

    external_app.reconfig_packs({"quartz"}, {})
    external_app.load_content()
end

-- Патч чтоб звуки не дублировались, ну и может для ещё чего то
function initializator.patch_packs()
    local blacklist = { "audio" }

    local safe_env = {}
    for k, v in pairs(_G) do
        safe_env[k] = v
    end

    for _, lib_name in ipairs(blacklist) do
        logger.log(string.format("patching %s library", lib_name), nil, nil, "init/client.lua")
        safe_env[lib_name] = setmetatable({}, {
            __index = function(t, key)
                return function() end
            end,
            __call = function()
            end
        })
    end

    local function matches_content_pack(key)
        for _, pack in ipairs(CONTENT_PACKS) do
            if string.find(key, pack .. ":", 1, true) then
                return true
            end
        end
        return false
    end

    for event_name, handlers in pairs(events.handlers) do
        if matches_content_pack(event_name) then
            for i, func in ipairs(handlers) do
                setfenv(func, safe_env)
            end
        end
    end
end

-- Инициализация скриптов
function initializator.init_pack_scripts()
    local paths = file.list_all_res("scripts/client/")

    for _, path in ipairs(paths) do
        if file.name(path) == "main.lua" then
            __load_script(path)
        end
    end
end

initializator.init_packs()
initializator.patch_packs()
initializator.init_pack_scripts()
