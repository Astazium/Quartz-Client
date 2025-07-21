local events = start_require "api/v1/events"
local entities = start_require "api/v1/entities"
local env = start_require "api/v1/env"
local sandbox = start_require "api/v1/sandbox"
local rpc = require "api/v1/rpc"
local bson = require "lib/files/bson"

local api = {
    events = events,
    rpc = rpc,
    bson = bson,
    env = env,
    entities = entities,
    sandbox = sandbox
}

return {client = api}