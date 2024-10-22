ZombieActions = ZombieActions or {}

ZombieActions.Drop = {}
ZombieActions.Drop.onStart = function(zombie, task)
    return true
end

ZombieActions.Drop.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Drop.onComplete = function(zombie, task)
    if BanditUtils.IsController(zombie) then
        local item = InventoryItemFactory.CreateItem(task.itemType)
        if item then
            zombie:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.2, 0.8), ZombRandFloat(0.2, 0.8), 0)
        end
    end
    BanditPlayerBase.UpdateContainer(zombie:getSquare())
    
    return true
end

