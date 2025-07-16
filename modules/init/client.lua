-- Инициализируем stdmin
require "quartz:std/stdmin"


-- Инициализируем конфиг

if not file.exists(CONFIG_PATH) then
    file.write(CONFIG_PATH, json.tostring({
        Account = {
            name = "Test",
            friends = {}
        },
        Servers = {
        }
    }))
end

CONFIG = json.parse(file.read(CONFIG_PATH))