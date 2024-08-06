ZombieActions = ZombieActions or {}

ZombieActions.GoTo = {}
ZombieActions.GoTo.onStart = function(zombie, task)

    if math.abs(zombie:getX() - task.x) <= 1.0 and math.abs(zombie:getY() - task.y) <= 1.0 and zombie:getZ() == task.z then
        print ("PATH DISTANCE REACHED")
    else
        zombie:pathToLocationF(task.x, task.y, task.z)
        zombie:setWalkType(task.walkType)
    end
   
    return true
end

ZombieActions.GoTo.onWorking = function(zombie, task)
    zombie:setWalkType(task.walkType)
    return false
end

ZombieActions.GoTo.onComplete = function(zombie, task)
    return true
end



