ZombieActions = ZombieActions or {}

ZombieActions.Sleep = {}
ZombieActions.Sleep.onStart = function(zombie, task)
    return true
end

ZombieActions.Sleep.onWorking = function(zombie, task)
    zombie:setBumpType(task.anim)
    return false
end

ZombieActions.Sleep.onComplete = function(zombie, task)
    return true
end