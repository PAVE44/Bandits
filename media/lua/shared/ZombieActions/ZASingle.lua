ZombieActions = ZombieActions or {}

ZombieActions.Single = {}
ZombieActions.Single.onStart = function(zombie, task)
    return true
end

ZombieActions.Single.onWorking = function(zombie, task)
    -- will finish immediately on first update
    return true
end

ZombieActions.Single.onComplete = function(zombie, task)
    return true
end