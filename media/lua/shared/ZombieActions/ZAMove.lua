ZombieActions = ZombieActions or {}

ZombieActions.Move = {}
ZombieActions.Move.onStart = function(zombie, task)
    if BanditUtils.IsController(zombie) then
        local x = task.x + 0.5
        local y = task.y + 0.5
        local z = task.z

        zombie:getPathFindBehavior2():pathToLocation(x, y, z)
        zombie:getPathFindBehavior2():cancel()
        zombie:setPath2(nil)
        zombie:setWalkType(task.walkType)
    end
    
    return true
end

ZombieActions.Move.onWorking = function(zombie, task)
    if BanditUtils.IsController(zombie) then
        local cell = getCell()

        if ZombRand(1000) == 1 then
            zombie:getPathFindBehavior2():pathToLocation(task.x+1, task.y+1, task.z)
            zombie:getPathFindBehavior2():cancel()
            zombie:setPath2(nil)
        end
        zombie:setWalkType(task.walkType)

        local result = zombie:getPathFindBehavior2():update()
        if result == BehaviorResult.Failed then
            return true
        end
        if result == BehaviorResult.Succeeded then
            return true
        end
    end

    return false
end

ZombieActions.Move.onComplete = function(zombie, task)
    if BanditUtils.IsController(zombie) then
        zombie:getPathFindBehavior2():cancel()
    end
    return true
end



