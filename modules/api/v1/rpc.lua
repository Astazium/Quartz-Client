local events = start_require "api/v1/events"
local bson = require "lib/files/bson"
local db = require "lib/files/bit_buffer"

local module = {
    emitter = {},
    handler = {}
}

function module.emitter.create_send(pack, event)
    return function (...)
        local buffer = db:new()
        bson.encode(buffer, {...})

        events.send(pack, event, buffer.bytes)
    end
end

return module