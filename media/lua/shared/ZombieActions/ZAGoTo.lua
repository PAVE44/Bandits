ZombieActions = ZombieActions or {}

ZombieActions.GoTo = {}
ZombieActions.GoTo.onStart = function(zombie, task)

    if BanditUtils.IsController(zombie) then
        if math.abs(zombie:getX() - task.x) <= 1.0 and math.abs(zombie:getY() - task.y) <= 1.0 and zombie:getZ() == task.z then
            print ("PATH DISTANCE REACHED")
        else
            zombie:pathToLocationF(task.x, task.y, task.z)
            zombie:setVariable("BanditWalkType", task.walkType)
            --zombie:setWalkType(task.walkType)
        end
    end
   
    return true
end

ZombieActions.GoTo.onWorking = function(zombie, task)
    zombie:setVariable("BanditWalkType", task.walkType)
    -- zombie:setWalkType(task.walkType)
    return false
end

ZombieActions.GoTo.onComplete = function(zombie, task)
    return true
end



