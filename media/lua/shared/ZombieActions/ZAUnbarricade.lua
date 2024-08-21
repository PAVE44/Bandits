ZombieActions = ZombieActions or {}

ZombieActions.Unbarricade = {}
ZombieActions.Unbarricade.onStart = function(zombie, task)
    zombie:playSound("BeginRemoveBarricadePlank")
    return true
end

ZombieActions.Unbarricade.onWorking = function(zombie, task)
    if not zombie:getVariableString("BumpAnimFinished") then
        return false
    else
        return true
    end
end

ZombieActions.Unbarricade.onComplete = function(zombie, task)

    --zombie:getEmitter():stopAll()
    if BanditUtils.IsController(zombie) then
        zombie:getEmitter():stopAll()
        zombie:playSound("RemoveBarricadePlank")
        
        local args = {x=task.x, y=task.y, z=task.z, index=task.idx}
        sendClientCommand(getPlayer(), 'Commands', 'Unbarricade', args)
    end

    return true
end