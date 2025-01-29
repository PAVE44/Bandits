ZombieActions = ZombieActions or {}

ZombieActions.Unbarricade = {}
ZombieActions.Unbarricade.onStart = function(zombie, task)
    zombie:playSound("BeginRemoveBarricadePlank")
    return true
end

ZombieActions.Unbarricade.onWorking = function(zombie, task)
    zombie:faceLocationF(task.fx, task.fy)

    if task.time <= 0 then return true end

    if zombie:getBumpType() ~= task.anim then 
        zombie:setBumpType(task.anim)
    end
end

ZombieActions.Unbarricade.onComplete = function(zombie, task)

    --zombie:getEmitter():stopAll()
    zombie:getEmitter():stopAll()
    zombie:playSound("RemoveBarricadePlank")

    if BanditUtils.IsController(zombie) then
        local args = {x=task.x, y=task.y, z=task.z, index=task.idx}
        sendClientCommand(getPlayer(), 'Commands', 'Unbarricade', args)
    end

    return true
end