ZombieActions = ZombieActions or {}

ZombieActions.Unbarricade = {}
ZombieActions.Unbarricade.onStart = function(zombie, task)
    zombie:playSound("BeginRemoveBarricadePlank")
    return true
end

ZombieActions.Unbarricade.onWorking = function(zombie, task)
    return false
end

ZombieActions.Unbarricade.onComplete = function(zombie, task)

    --zombie:getEmitter():stopAll()
    zombie:getEmitter():stopAll()
    zombie:playSound("RemoveBarricadePlank")
    
    local args = {x=task.x, y=task.y, z=task.z, index=task.idx}
	sendClientCommand(getPlayer(), 'Commands', 'Unbarricade', args)

    return true
end