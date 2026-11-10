ZombieActions = ZombieActions or {}

ZombieActions.Rack = {}
ZombieActions.Rack.onStart = function(zombie, task)
    return true
end

ZombieActions.Rack.onWorking = function(zombie, task)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Rack.onComplete = function(zombie, task)

    local brain = BanditBrain.Get(zombie)
    local weapon = brain.weapons[task.slot]
    weapon.racked = true

    return true
end