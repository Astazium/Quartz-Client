-- Инициализируем stdmin
require "quartz:std/stdmin"

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

-- Инициализация пинов
external_app.reset_content()
for _, pack in ipairs(pack.get_available()) do
    if table.has(CONFIG.Pinned_packs, pack) then
        external_app.reconfig_packs({pack}, {})
    end
end

external_app.reconfig_packs({"quartz"}, {})
external_app.load_content()