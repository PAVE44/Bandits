ZombieActions = ZombieActions or {}

ZombieActions.Move = {}
ZombieActions.Move.onStart = function(zombie, task)
    if BanditUtils.IsController(zombie) then

        if task.vehiclePartArea then
            local vehicle = getCell():getGridSquare(task.x, task.y, task.z):getVehicleContainer()
            if vehicle then
                zombie:getPathFindBehavior2():pathToVehicleArea(vehicle, task.vehiclePartArea)
            end
        else
            zombie:getPathFindBehavior2():pathToLocation(task.x + 0.5, task.y + 0.5, task.z)
        end
        
        zombie:getPathFindBehavior2():cancel()
        zombie:setPath2(nil)
        -- zombie:setWalkType(task.walkType)
        zombie:setVariable("BanditWalkType", task.walkType)
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
        -- zombie:setWalkType(task.walkType)
        zombie:setVariable("BanditWalkType", task.walkType)

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


