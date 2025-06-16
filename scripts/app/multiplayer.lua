app.config_packs({ "quartz" })
app.load_content()

require "quartz:constants"
require "quartz:std/stdboot"
require "quartz:init/client"
local Client = require "quartz:multiplayer/client/client"

local client = Client.new()

menu.page = "servers"

while true do
    client:tick()
    app.tick()
end