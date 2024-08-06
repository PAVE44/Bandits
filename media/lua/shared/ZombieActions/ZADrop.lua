ZombieActions = ZombieActions or {}

ZombieActions.Drop = {}
ZombieActions.Drop.onStart = function(zombie, task)
    return true
end

ZombieActions.Drop.onWorking = function(zombie, task)
    return false
end

ZombieActions.Drop.onComplete = function(zombie, task)
    local item = InventoryItemFactory.CreateItem(task.itemType)
    if item then
         zombie:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
    end
    
    return true
end

