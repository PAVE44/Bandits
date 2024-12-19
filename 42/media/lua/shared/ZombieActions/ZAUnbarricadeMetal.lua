ZombieActions = ZombieActions or {}

ZombieActions.UnbarricadeMetal = {}
ZombieActions.UnbarricadeMetal.onStart = function(zombie, task)
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

    return true
end