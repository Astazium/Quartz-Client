app.config_packs({ "quartz" })
app.load_content()

gui_util.add_page_dispatcher(function(name, args)
    if name == "pause" then
        name = "quartz_pause"
    end

    return name, args
end)

require "quartz:constants"
require "quartz:std/stdboot"
require "quartz:init/client"
local Client = require "quartz:multiplayer/client/client"

table.insert(CONTENT_PACKS, "quartz")

local client = Client.new()

menu.page = "servers"

local protect_app = {}

for key, val in pairs(app) do
    protect_app[key] = function (...)
        if parse_path(debug.getinfo(2).source) == PACK_ID then
            return val(...)
        end
    end
end

_G["external_app"] = protect_app
_G["/$p"] = table.copy(package.loaded)

local function main()
    while true do
        client:tick()
        app.tick()
    end
end

print(pcall(main))