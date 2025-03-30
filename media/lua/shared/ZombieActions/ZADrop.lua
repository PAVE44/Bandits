ZombieActions = ZombieActions or {}

ZombieActions.Drop = {}
ZombieActions.Drop.onStart = function(zombie, task)
    return true
end

ZombieActions.Drop.onWorking = function(zombie, task)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Drop.onComplete = function(zombie, task)
    if BanditUtils.IsController(zombie) then
        local item = BanditCompatibility.InstanceItem(task.itemType)
        local brain = BanditBrain.Get(zombie)
        if item then
            item = BanditWeapons.Modify(item, brain)
            zombie:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
        end
    end
    
    return true
end

