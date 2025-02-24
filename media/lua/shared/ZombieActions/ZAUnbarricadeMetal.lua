ZombieActions = ZombieActions or {}

ZombieActions.UnbarricadeMetal = {}
ZombieActions.UnbarricadeMetal.onStart = function(zombie, task)
    if not Bandit.Has(zombie, "Base.BlowTorch") then
        Bandit.AddLoot(zombie, "Base.BlowTorch")
        Bandit.UpdateItemsToSpawnAtDeath(zombie)
    end
    zombie:playSound("BlowTorch")
    return true
end

ZombieActions.UnbarricadeMetal.onWorking = function(zombie, task)
    zombie:faceLocation(task.fx, task.fy)
    
    if task.time <= 0 then return true end

    if zombie:getBumpType() ~= task.anim then 
        zombie:setBumpType(task.anim)
    end

    return false
end

ZombieActions.UnbarricadeMetal.onComplete = function(zombie, task)

    --zombie:getEmitter():stopAll()
    zombie:getEmitter():stopAll()
    zombie:playSound("RemoveBarricadeMetal")

    if BanditUtils.IsController(zombie) then
        local args = {x=task.x, y=task.y, z=task.z, index=task.idx}
        sendClientCommand(getPlayer(), 'Commands', 'Unbarricade', args)
    end

    if BanditUtils.IsController(zombie) then
        local item = BanditCompatibility.InstanceItem("Base.SheetMetal")
        if item then
            zombie:getSquare():AddWorldInventoryItem(item, ZombRandFloat(0.3, 0.7), ZombRandFloat(0.3, 0.7), 0)
        end
    end

    return true
end