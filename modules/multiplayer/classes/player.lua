local Player = {}
local max_id = 0
Player.__index = Player

function Player.new(pid, name, pos, rot, cheats)
    local self = setmetatable({}, Player)

    self.pid = pid
    self.name = name
    self.pos = pos or {0, -10, 0}
    self.rot = rot or {0, 0}
    self.cheats = cheats or {false, false}
    self.active = true
    self.id = max_id

    self.change_flags = {
        pos = false,
        rot = false,
        cheats = false
    }

    max_id = max_id + 1

    return self
end

function Player:is_active()
    return self.active
end

function Player:set_pos(pos)
    if pos == nil then return end

    player.set_pos(self.pid, pos.x, pos.y, pos.z)
    self.change_flags.pos = true
end

function Player:set_rot(rot)
    if rot == nil then return end

    player.set_rot(self.pid, rot.yaw, rot.pitch, 0)
    self.change_flags.rot = true
end

function Player:set_cheats(cheats)
    if cheats == nil then return end

    player.set_noclip(self.pid, cheats.noclip)
    player.set_flight(self.pid, cheats.flight)
    self.change_flags.cheats = true
end

function Player:despawn()
    player.delete(self.pid)
    self.active = false
end

return Player