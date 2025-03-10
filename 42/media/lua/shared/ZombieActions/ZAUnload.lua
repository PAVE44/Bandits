ZombieActions = ZombieActions or {}

ZombieActions.Unload = {}
ZombieActions.Unload.onStart = function(zombie, task)
    return true
end

ZombieActions.Unload.onWorking = function(zombie, task)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Unload.onComplete = function(zombie, task)

    local brain = BanditBrain.Get(zombie)
    local weapon = brain.weapons[task.slot]

    if weapon.type == "mag" and weapon.clipIn then
        weapon.clipIn = false
        weapon.racked = false

        if BanditUtils.IsController(zombie) then
            local item = BanditCompatibility.InstanceItem(task.drop)
            if item then
                zombie:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
            end
        end
    end

    return true
end