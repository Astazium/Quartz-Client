local Player = {}
local max_id = 0
Player.__index = Player

function Player.new(pid, name, pos, rot, cheats)
    local self = setmetatable({}, Player)

    self.pid = pid
    self.name = name
    self.invid = player.get_inventory(pid)
    self.inv = {}
    self.slot = 0
    self.pos = pos or {0, -10, 0}
    self.rot = rot or {0, 0}
    self.cheats = cheats or {false, false}
    self.active = true
    self.id = max_id

    self.changed_flags = {
        pos = false,
        rot = false,
        cheats = false,
        inv = false,
        slot = false
    }

    max_id = max_id + 1

    return self
end

function Player:is_active()
    return self.active
end

function Player:set_pos(pos, set_flag)
    if pos == nil then return end

    player.set_pos(self.pid, pos.x, pos.y, pos.z)
    if set_flag then self.changed_flags.pos = true end
end

function Player:set_rot(rot, set_flag)
    if rot == nil then return end

    player.set_rot(self.pid, rot.yaw, rot.pitch, 0)
    if set_flag then self.changed_flags.rot = true end
end

function Player:set_cheats(cheats, set_flag)
    if cheats == nil then return end

    player.set_noclip(self.pid, cheats.noclip)
    player.set_flight(self.pid, cheats.flight)
    if set_flag then self.changed_flags.cheats = true end
end

function Player:set_inventory(inv, set_flag)
    set_flag = set_flag or true
    inventory.set_inv(self.invid, inv)

    if set_flag then self.changed_flags.inv = true end
end

function Player:set_slot(slot_id, set_flag)
    player.set_selected_slot(self.pid, slot_id)

    if set_flag then self.changed_flags.slot = true end
end

function Player:despawn()
    player.delete(self.pid)
    self.active = false
end

return Player