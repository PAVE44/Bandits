ZombieActions = ZombieActions or {}

ZombieActions.Single = {}
ZombieActions.Single.onStart = function(zombie, task)
    return true
end

ZombieActions.Single.onWorking = function(zombie, task)
    if zombie:getBumpType() ~= task.anim then return true end
    return false
end

ZombieActions.Single.onComplete = function(zombie, task)
    return true
end