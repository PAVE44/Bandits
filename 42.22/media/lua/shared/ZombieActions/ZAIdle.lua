ZombieActions = ZombieActions or {}

ZombieActions.Idle = {}
ZombieActions.Idle.onStart = function(zombie, task)
    return true
end

ZombieActions.Idle.onWorking = function(zombie, task)
    return false
end

ZombieActions.Idle.onComplete = function(zombie, task)
    local square = zombie:getCell():getGridSquare(task.x, task.y, task.z)
    return true
end

