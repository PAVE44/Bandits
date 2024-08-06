ZombieActions = ZombieActions or {}

ZombieActions.Die = {}
ZombieActions.Die.onStart = function(zombie, task)

    return true
end

ZombieActions.Die.onWorking = function(zombie, task)
    -- will never finish unless timeout
    return false
end

ZombieActions.Die.onComplete = function(zombie, task)
    zombie:Kill(getCell():getFakeZombieForHit(), true)
    return true
end