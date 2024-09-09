ZombieActions = ZombieActions or {}

ZombieActions.GoTo = {}
ZombieActions.GoTo.onStart = function(zombie, task)

    if BanditUtils.IsController(zombie) then
        local dx = math.abs(zombie:getX() - task.x)
        local dy = math.abs(zombie:getY() - task.y)
        if dx <= 0.3 and dy <= 0.3 and zombie:getZ() == task.z then
            print ("PATH DISTANCE REACHED")
        else
            zombie:pathToLocationF(task.x, task.y, task.z)
            -- zombie:setVariable("BanditWalkType", "WalkAim")
            --zombie:setWalkType(task.walkType)
        end
    end
   
    return true
end

ZombieActions.GoTo.onWorking = function(zombie, task)

    if task.panic then 
        zombie:setVariable("BanditWalkType", "Run")
    else
        local dx = math.abs(zombie:getX() - task.x)
        local dy = math.abs(zombie:getY() - task.y)
        if dx <= 3 and dy <= 3 and zombie:getZ() == task.z then
            zombie:setVariable("BanditWalkType", "WalkAim")
        else
            zombie:setVariable("BanditWalkType", task.walkType)
        end
    end

    -- zombie:setWalkType(task.walkType)
    return false
end

ZombieActions.GoTo.onComplete = function(zombie, task)
    return true
end



