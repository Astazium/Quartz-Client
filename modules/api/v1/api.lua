local events = start_require "api/v1/events"
local entities = start_require "api/v1/entities"
local env = start_require "api/v1/env"
local rpc = require "api/v1/rpc"
local bson = require "lib/files/bson"

local api = {
    events = events,
    rpc = rpc,
    bson = bson,
    env = env,
    entities = entities
}

return {client = api}