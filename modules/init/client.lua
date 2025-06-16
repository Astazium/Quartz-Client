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
            {name = "Test", port = "1234", address = "123123"}
        }
    }))
end

CONFIG = json.parse(file.read(CONFIG_PATH))