app.config_packs({ "quartz" })
app.load_content()

require "quartz:constants"
require "quartz:std/stdboot"
require "quartz:init/client"
local Client = require "quartz:multiplayer/client/client"

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

while true do
    client:tick()
    app.tick()
end